"""Render a studio preview for one Rainline Blender vehicle.

Usage:
  blender --background --python tools/render_garage_preview.py -- input.blend output.png
"""
import bpy
import sys
from mathutils import Vector
from pathlib import Path

args = sys.argv[sys.argv.index("--") + 1:]
if len(args) != 2:
    raise SystemExit("Expected input blend and output png")

workspace = Path(__file__).resolve().parent.parent
output_path = Path(args[1])
if not output_path.is_absolute():
    output_path = workspace / output_path
output_path.parent.mkdir(parents=True, exist_ok=True)

bpy.ops.wm.open_mainfile(filepath=args[0])
scene = bpy.context.scene
scene.render.engine = "BLENDER_EEVEE"
scene.render.resolution_x = 960
scene.render.resolution_y = 540
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = str(output_path)
scene.world.color = (0.004, 0.012, 0.028)

for obj in list(bpy.data.objects):
    if obj.type == "LIGHT" or obj.type == "CAMERA":
        bpy.data.objects.remove(obj, do_unlink=True)

bpy.ops.mesh.primitive_plane_add(size=30, location=(0, 0, -0.08))
floor = bpy.context.active_object
floor.name = "GarageFloor"
mat = bpy.data.materials.new("GarageFloorMat")
mat.diffuse_color = (0.012, 0.035, 0.07, 1.0)
mat.metallic = 0.75
mat.roughness = 0.22
floor.data.materials.append(mat)

def light(name, location, color, energy, size):
    data = bpy.data.lights.new(name, "AREA")
    data.color = color
    data.energy = energy
    data.shape = "DISK"
    data.size = size
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.location = location
    obj.rotation_euler = (0.6, 0, 0)
    return obj

light("Key", (4, -5, 6), (0.35, 0.82, 1.0), 950, 5)
light("Rim", (-4, 3, 4), (1.0, 0.26, 0.08), 700, 4)
light("Fill", (0, -1, 7), (0.4, 0.5, 1.0), 500, 5)

camera_data = bpy.data.cameras.new("GarageCamera")
camera = bpy.data.objects.new("GarageCamera", camera_data)
bpy.context.collection.objects.link(camera)
camera.location = (5.6, -7.5, 3.25)
target = Vector((0, 0, 0.65))
camera.rotation_euler = (target - camera.location).to_track_quat("-Z", "Y").to_euler()
camera_data.lens = 52
scene.camera = camera

bpy.ops.render.render(write_still=True)
