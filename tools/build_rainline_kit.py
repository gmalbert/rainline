"""Build a tiny original modular source kit for the Rainline Run prototype.

Run from Blender 5.2+: blender --background --python tools/build_rainline_kit.py
The playable scene intentionally generates equivalent primitives at runtime; this
file is the editable Blender source for replacing them during art iteration.
"""
import bpy
from pathlib import Path

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

root = Path(bpy.path.abspath("//"))
output = root / "assets" / "meshes"
output.mkdir(parents=True, exist_ok=True)

def make_material(name, color, metallic=0.0, roughness=0.5):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1.0)
    material.metallic = metallic
    material.roughness = roughness
    return material

asphalt = make_material("M_WetAsphalt", (0.025, 0.09, 0.15), 0.8, 0.2)
concrete = make_material("M_Concrete", (0.12, 0.15, 0.18), 0.1, 0.7)
orange = make_material("M_RouteBarrier", (0.9, 0.35, 0.05), 0.3, 0.35)

def cube(name, location, scale, material):
    bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material)
    return obj

road = cube("road_straight_40m", (0, 0, 0), (9, 0.5, 20), asphalt)
road["rainline_role"] = "drivable_road"
for side in (-1, 1):
    barrier = cube(f"barrier_40m_{side}", (side * 9.2, 0.4, 0), (0.18, 0.4, 20), orange)
    barrier["rainline_role"] = "route_barrier"
building = cube("building_midrise_a", (26, 10, 0), (8, 10, 10), concrete)
building["rainline_role"] = "background_building"

bpy.ops.wm.save_as_mainfile(filepath=str(output / "rainline_modular_kit.blend"))
bpy.ops.object.select_all(action="SELECT")
bpy.ops.export_scene.gltf(filepath=str(output / "rainline_modular_kit.glb"), export_format="GLB", use_selection=True)
