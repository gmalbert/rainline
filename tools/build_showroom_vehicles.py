"""Build smooth original showroom vehicles for the Rainline garage in Blender 5.2+."""
import bpy
from pathlib import Path
from math import radians

root = Path(bpy.path.abspath("//"))
output = root / "assets" / "meshes"
output.mkdir(parents=True, exist_ok=True)


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def material(name, color, metallic=0.0, roughness=0.4, emission=None):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    node = mat.node_tree.nodes.get("Principled BSDF")
    node.inputs["Base Color"].default_value = (*color, 1.0)
    node.inputs["Metallic"].default_value = metallic
    node.inputs["Roughness"].default_value = roughness
    if emission:
        node.inputs["Emission Color"].default_value = (*emission, 1.0)
        node.inputs["Emission Strength"].default_value = 3.5
    return mat


def smooth(obj):
    if obj.type == "MESH":
        for polygon in obj.data.polygons:
            polygon.use_smooth = True
    return obj


def rounded_cube(name, location, dimensions, mat, radius=0.08):
    bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    bevel = obj.modifiers.new("Smooth bodywork", "BEVEL")
    bevel.width = radius
    bevel.segments = 5
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    return smooth(obj)


def ellipsoid(name, location, scale, mat):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=48, ring_count=24, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    return smooth(obj)


def wheel(name, x, y, radius, tire_mat, rim_mat, brake_mat):
    bpy.ops.mesh.primitive_torus_add(major_radius=radius * 0.72, minor_radius=radius * 0.28, major_segments=40, minor_segments=12, location=(x, y, radius), rotation=(0, radians(90), 0))
    tire = bpy.context.active_object
    tire.name = name + " Tire"
    tire.data.materials.append(tire_mat)
    smooth(tire)
    bpy.ops.mesh.primitive_cylinder_add(vertices=40, radius=radius * 0.56, depth=0.12, location=(x * 1.025, y, radius), rotation=(0, radians(90), 0))
    rim = bpy.context.active_object
    rim.name = name + " Rim"
    rim.data.materials.append(rim_mat)
    smooth(rim)
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=radius * 0.22, depth=0.13, location=(x * 1.04, y, radius), rotation=(0, radians(90), 0))
    brake = bpy.context.active_object
    brake.name = name + " Brake"
    brake.data.materials.append(brake_mat)
    smooth(brake)
    return tire, rim, brake


def setup_materials(prefix, paint_color, accent_color):
    return {
        "paint": material(prefix + " paint", paint_color, 0.82, 0.16),
        "carbon": material(prefix + " carbon", (0.006, 0.01, 0.018), 0.72, 0.25),
        "glass": material(prefix + " glass", (0.012, 0.09, 0.16), 0.3, 0.12),
        "tire": material(prefix + " tire", (0.004, 0.006, 0.009), 0.02, 0.78),
        "rim": material(prefix + " rim", (0.18, 0.23, 0.30), 0.92, 0.14),
        "accent": material(prefix + " accent", accent_color, 0.2, 0.12, accent_color),
        "red": material(prefix + " brake", (0.7, 0.01, 0.025), 0.15, 0.15, (1.0, 0.01, 0.03)),
    }


def save(identifier):
    bpy.ops.wm.save_as_mainfile(filepath=str(output / (identifier + ".blend")))
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=str(output / (identifier + ".glb")), export_format="GLB", export_materials="EXPORT", export_apply=True)


def apex_s():
    clear_scene()
    m = setup_materials("Apex", (0.68, 0.012, 0.045), (0.35, 0.9, 1.0))
    root_node = bpy.data.objects.new("Rainline Apex S", None); bpy.context.collection.objects.link(root_node)
    def p(obj): obj.parent = root_node; return obj
    p(ellipsoid("Apex smooth body", (0, 0, 0.47), (1.02, 2.16, 0.46), m["paint"]))
    p(rounded_cube("Apex lower body", (0, 0.10, 0.38), (1.93, 3.92, 0.45), m["paint"], 0.18))
    p(ellipsoid("Apex glass canopy", (0, 0.33, 0.88), (0.75, 1.08, 0.47), m["glass"]))
    p(rounded_cube("Apex front splitter", (0, -1.94, 0.22), (1.78, 0.34, 0.14), m["carbon"], 0.05))
    p(rounded_cube("Apex rear diffuser", (0, 1.94, 0.24), (1.74, 0.28, 0.16), m["carbon"], 0.05))
    for x in (-0.72, 0.72):
        p(rounded_cube("Apex headlight", (x, -1.90, 0.58), (0.42, 0.10, 0.11), m["accent"], 0.045))
        p(rounded_cube("Apex taillight", (x, 1.92, 0.57), (0.42, 0.08, 0.10), m["red"], 0.04))
    for x in (-1.00, 1.00):
        for y in (-1.35, 1.35):
            for obj in wheel("Apex wheel", x, y, 0.46, m["tire"], m["rim"], m["accent"]): p(obj)
    save("rainline_apex_s")


def coastline_gt():
    clear_scene()
    m = setup_materials("Coast", (0.015, 0.14, 0.56), (0.16, 0.88, 1.0))
    root_node = bpy.data.objects.new("Rainline Coastline GT", None); bpy.context.collection.objects.link(root_node)
    def p(obj): obj.parent = root_node; return obj
    p(ellipsoid("Coast smooth body", (0, 0.03, 0.49), (1.03, 2.42, 0.47), m["paint"]))
    p(rounded_cube("Coast lower body", (0, 0.06, 0.40), (1.96, 4.40, 0.45), m["paint"], 0.20))
    p(ellipsoid("Coast glass canopy", (0, 0.45, 0.91), (0.76, 1.16, 0.46), m["glass"]))
    p(rounded_cube("Coast grille", (0, -2.13, 0.42), (1.14, 0.08, 0.19), m["carbon"], 0.04))
    p(rounded_cube("Coast spoiler", (0, 1.95, 0.96), (1.34, 0.18, 0.08), m["carbon"], 0.03))
    for x in (-0.74, 0.74):
        p(rounded_cube("Coast headlight", (x, -2.08, 0.59), (0.46, 0.10, 0.10), m["accent"], 0.04))
        p(rounded_cube("Coast taillight", (x, 2.10, 0.58), (0.45, 0.08, 0.10), m["red"], 0.04))
    for x in (-1.01, 1.01):
        for y in (-1.58, 1.58):
            for obj in wheel("Coast wheel", x, y, 0.47, m["tire"], m["rim"], m["accent"]): p(obj)
    save("rainline_coastline_gt")


def irontrail_x():
    clear_scene()
    m = setup_materials("Irontrail", (0.11, 0.13, 0.16), (1.0, 0.52, 0.07))
    root_node = bpy.data.objects.new("Rainline Irontrail X", None); bpy.context.collection.objects.link(root_node)
    def p(obj): obj.parent = root_node; return obj
    p(rounded_cube("Irontrail frame", (0, 0, 0.53), (2.16, 4.72, 0.70), m["paint"], 0.20))
    p(rounded_cube("Irontrail cab", (0, -0.74, 1.15), (1.96, 2.04, 1.25), m["paint"], 0.22))
    p(rounded_cube("Irontrail windshield", (0, -1.24, 1.34), (1.66, 0.06, 0.68), m["glass"], 0.03))
    p(rounded_cube("Irontrail bed floor", (0, 1.22, 0.96), (1.98, 1.74, 0.16), m["carbon"], 0.04))
    for x in (-0.94, 0.94):
        p(rounded_cube("Irontrail bed rail", (x, 1.22, 1.28), (0.10, 1.80, 0.54), m["paint"], 0.04))
    p(rounded_cube("Irontrail tailgate", (0, 2.08, 1.25), (2.0, 0.10, 0.62), m["paint"], 0.05))
    p(rounded_cube("Irontrail bumper", (0, 2.38, 0.51), (2.10, 0.22, 0.20), m["carbon"], 0.05))
    for x in (-0.76, 0.76):
        p(rounded_cube("Irontrail headlight", (x, -2.30, 0.82), (0.42, 0.10, 0.16), m["accent"], 0.04))
        p(rounded_cube("Irontrail taillight", (x, 2.42, 0.80), (0.34, 0.08, 0.18), m["red"], 0.04))
    for x in (-1.14, 1.14):
        for y in (-1.55, 1.55):
            for obj in wheel("Irontrail wheel", x, y, 0.62, m["tire"], m["rim"], m["accent"]): p(obj)
    save("rainline_irontrail_x")


apex_s()
coastline_gt()
irontrail_x()
