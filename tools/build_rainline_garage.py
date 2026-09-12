"""Build two additional original selectable Rainline sports cars in Blender 5.2+."""
import bpy
from pathlib import Path
from math import radians

root = Path(bpy.path.abspath("//"))
output = root / "assets" / "meshes"
output.mkdir(parents=True, exist_ok=True)


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def make_material(name, color, metallic=0.0, roughness=0.45, emission=None):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 4.0
    return mat


def cube(name, location, dimensions, mat, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if bevel:
        modifier = obj.modifiers.new("Panel rounding", "BEVEL")
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
    return obj


def wedge(name, sections, mat, bevel=0.0):
    vertices = []
    for y, low, high, half_width in sections:
        vertices.extend([(-half_width, y, low), (half_width, y, low), (-half_width, y, high), (half_width, y, high)])
    faces = [(0, 1, 3, 2), (len(vertices) - 4, len(vertices) - 2, len(vertices) - 1, len(vertices) - 3)]
    for index in range(len(sections) - 1):
        a, b = index * 4, (index + 1) * 4
        faces.extend([(a, b, b + 1, a + 1), (a + 2, a + 3, b + 3, b + 2), (a, a + 2, b + 2, b), (a + 1, b + 1, b + 3, a + 3)])
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


def build_vehicle(identifier, paint_color, body_sections, canopy_sections, wheel_y, accent_color):
    clear_scene()
    paint = make_material(identifier + "_Paint", paint_color, 0.86, 0.18)
    carbon = make_material(identifier + "_Carbon", (0.008, 0.014, 0.024), 0.72, 0.28)
    glass = make_material(identifier + "_Glass", (0.025, 0.12, 0.20), 0.35, 0.10)
    tire = make_material(identifier + "_Tire", (0.008, 0.01, 0.014), 0.05, 0.72)
    wheel = make_material(identifier + "_Wheel", (0.16, 0.21, 0.27), 0.92, 0.16)
    accent = make_material(identifier + "_Accent", accent_color, 0.15, 0.15, accent_color)
    root_node = bpy.data.objects.new(identifier, None)
    bpy.context.collection.objects.link(root_node)
    def parent(obj): obj.parent = root_node; return obj
    parent(wedge("BodyShell", body_sections, paint, 0.075))
    parent(wedge("GlassCanopy", canopy_sections, glass, 0.035))
    parent(cube("Splitter", (0, min(p[0] for p in body_sections) + 0.13, 0.25), (1.78, 0.35, 0.14), carbon, 0.04))
    parent(cube("Diffuser", (0, max(p[0] for p in body_sections) - 0.12, 0.27), (1.72, 0.28, 0.18), carbon, 0.04))
    for x in (-0.74, 0.74):
        parent(cube("Headlight", (x, min(p[0] for p in body_sections) + 0.02, 0.51), (0.38, 0.06, 0.13), accent, 0.02))
        parent(cube("Taillight", (x, max(p[0] for p in body_sections) - 0.02, 0.51), (0.40, 0.06, 0.12), accent, 0.02))
    for x in (-0.99, 0.99):
        for y in wheel_y:
            parent(cylinder("Tire", (x, y, 0.40), 0.45, 0.28, tire))
            parent(cylinder("Wheel", (x * 1.01, y, 0.40), 0.29, 0.30, wheel))
            parent(cylinder("BrakeDisc", (x * 1.025, y, 0.40), 0.14, 0.31, accent))
    bpy.ops.wm.save_as_mainfile(filepath=str(output / (identifier.lower() + ".blend")))
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=str(output / (identifier.lower() + ".glb")), export_format="GLB", export_materials="EXPORT", export_apply=True)


# Long, planted grand tourer.
build_vehicle("RainlineHarborGT", (0.018, 0.11, 0.42), [
    (-2.28, 0.20, 0.42, 0.65), (-1.58, 0.18, 0.56, 0.94),
    (0.20, 0.18, 0.68, 0.98), (1.55, 0.19, 0.58, 0.92), (2.28, 0.23, 0.46, 0.70),
], [(-0.68, 0.65, 0.82, 0.67), (-0.05, 0.69, 1.24, 0.70), (1.15, 0.66, 1.20, 0.66), (1.45, 0.64, 0.88, 0.60)], (-1.52, 1.55), (0.30, 0.86, 1.0))

# Short, angular wedge with a more upright rear deck.
build_vehicle("RainlineSwitchback", (0.78, 0.20, 0.012), [
    (-1.98, 0.22, 0.43, 0.66), (-1.38, 0.19, 0.60, 0.93),
    (-0.20, 0.18, 0.70, 0.97), (0.98, 0.20, 0.78, 0.92), (1.80, 0.24, 0.54, 0.72),
], [(-0.92, 0.66, 0.82, 0.66), (-0.28, 0.69, 1.31, 0.68), (0.56, 0.72, 1.16, 0.64), (0.94, 0.70, 0.88, 0.60)], (-1.25, 1.26), (1.0, 0.58, 0.06))
