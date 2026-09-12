"""Create the original Blender hero car for Rainline Run.

Run with Blender 5.2+ from the repository root:
  blender --background --python tools/build_rainline_car.py
"""
import bpy
from pathlib import Path
from math import radians

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

root = Path(bpy.path.abspath("//"))
output = root / "assets" / "meshes"
output.mkdir(parents=True, exist_ok=True)


def material(name, color, metallic=0.0, roughness=0.45, emission=None):
    value = bpy.data.materials.new(name)
    value.diffuse_color = (*color, 1.0)
    value.metallic = metallic
    value.roughness = roughness
    value.use_nodes = True
    bsdf = value.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 4.0
    return value


paint = material("M_Rainline_Crimson", (0.48, 0.008, 0.04), 0.82, 0.2)
carbon = material("M_Rainline_Carbon", (0.012, 0.018, 0.028), 0.7, 0.28)
glass = material("M_Rainline_Glass", (0.025, 0.13, 0.2), 0.3, 0.08)
tire = material("M_Rainline_Tire", (0.008, 0.01, 0.014), 0.05, 0.7)
wheel = material("M_Rainline_Wheel", (0.15, 0.2, 0.24), 0.9, 0.18)
headlight = material("M_Rainline_Headlight", (0.6, 0.95, 1.0), 0.1, 0.15, (0.25, 0.9, 1.0))
taillight = material("M_Rainline_Taillight", (0.9, 0.01, 0.04), 0.1, 0.15, (1.0, 0.015, 0.06))


def cube(name, location, dimensions, mat, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if bevel:
        modifier = obj.modifiers.new("Soft panel edges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 3
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    return obj


def cylinder(name, location, radius, depth, mat):
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=radius, depth=depth, location=location, rotation=(0, radians(90), 0))
    obj = bpy.context.active_object
    obj.name = name
    obj.data.materials.append(mat)
    bevel = obj.modifiers.new("Tire edge", "BEVEL")
    bevel.width = 0.035
    bevel.segments = 2
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    return obj


def wedge(name, sections, mat, bevel=0.0):
    """Build a low-poly automotive shell from cross-sections along the Y axis."""
    vertices = []
    for y, low, high, half_width in sections:
        vertices.extend([
            (-half_width, y, low), (half_width, y, low),
            (-half_width, y, high), (half_width, y, high),
        ])
    faces = [(0, 1, 3, 2), (len(vertices) - 4, len(vertices) - 2, len(vertices) - 1, len(vertices) - 3)]
    for index in range(len(sections) - 1):
        a = index * 4
        b = (index + 1) * 4
        faces.extend([
            (a, b, b + 1, a + 1),       # underside
            (a + 2, a + 3, b + 3, b + 2), # roof
            (a, a + 2, b + 2, b),         # left flank
            (a + 1, b + 1, b + 3, a + 3), # right flank
        ])
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(mat)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    if bevel:
        modifier = obj.modifiers.new("Panel rounding", "BEVEL")
        modifier.width = bevel
        modifier.segments = 3
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.modifier_apply(modifier=modifier.name)
        obj.select_set(False)
    return obj


car = bpy.data.objects.new("RainlineHeroCar", None)
bpy.context.collection.objects.link(car)


def parent(obj):
    obj.parent = car
    return obj


# Blender's -Y front maps to the Godot car's -Z forward after glTF export.
# The body and canopy use tapered sections rather than boxes, giving the car
# a readable compact-coupe silhouette from chase view.
parent(wedge("BodyShell", [
    (-2.08, 0.20, 0.44, 0.67),
    (-1.55, 0.18, 0.62, 0.94),
    (-0.35, 0.18, 0.74, 0.98),
    (1.20, 0.18, 0.67, 0.94),
    (2.05, 0.22, 0.48, 0.72),
], paint, 0.09))
parent(wedge("GlassCanopy", [
    (-0.92, 0.67, 0.82, 0.67),
    (-0.38, 0.72, 1.28, 0.70),
    (0.68, 0.70, 1.34, 0.68),
    (1.05, 0.68, 0.92, 0.63),
], glass, 0.045))
parent(cube("LowerSplitter", (0, -1.96, 0.25), (1.80, 0.42, 0.15), carbon, 0.05))
parent(cube("RearDiffuser", (0, 1.98, 0.27), (1.74, 0.32, 0.20), carbon, 0.04))
parent(cube("HoodAccent", (0, -1.12, 0.74), (0.26, 1.10, 0.035), carbon, 0.015))
parent(cube("RoofSpine", (0, 0.36, 1.37), (0.12, 0.96, 0.055), carbon, 0.02))
for x in (-0.93, 0.93):
    parent(cube("SideSkirt", (x, 0.12, 0.25), (0.10, 2.65, 0.18), carbon, 0.025))

for x in (-0.72, 0.72):
    parent(cube("Headlight", (x, -2.075, 0.51), (0.40, 0.065, 0.13), headlight, 0.025))
    parent(cube("Taillight", (x, 2.075, 0.51), (0.42, 0.065, 0.12), taillight, 0.025))

for x in (-0.99, 0.99):
    for y in (-1.32, 1.32):
        parent(cylinder("Tire", (x, y, 0.40), 0.46, 0.28, tire))
        parent(cylinder("Wheel", (x * 1.01, y, 0.40), 0.29, 0.295, wheel))
        parent(cylinder("BrakeDisc", (x * 1.022, y, 0.40), 0.16, 0.305, headlight))

# A small interior frame remains visible from the in-car camera.
parent(cube("Dashboard", (0, -0.72, 0.82), (1.3, 0.28, 0.2), carbon, 0.04))
parent(cube("DashDisplay", (0, -0.87, 0.97), (0.54, 0.035, 0.12), headlight, 0.01))

bpy.context.view_layer.objects.active = car
car.select_set(True)
bpy.ops.wm.save_as_mainfile(filepath=str(output / "rainline_hero_car.blend"))
bpy.ops.object.select_all(action="SELECT")
bpy.ops.export_scene.gltf(
    filepath=str(output / "rainline_hero_car.glb"),
    export_format="GLB",
    export_materials="EXPORT",
    export_apply=True,
)
