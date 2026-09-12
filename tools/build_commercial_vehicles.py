"""Build the Rainline v2 vehicle lineup: smooth, road-scale original Blender shells."""
import bpy
from pathlib import Path
from math import radians

ROOT = Path(bpy.path.abspath("//"))
OUT = ROOT / "assets" / "meshes"
OUT.mkdir(parents=True, exist_ok=True)


def clear():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def mat(name, color, metallic=0.0, roughness=0.4, emission=None):
    result = bpy.data.materials.new(name)
    result.use_nodes = True
    bsdf = result.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 4.0
    return result


def smooth(obj):
    if obj.type == "MESH":
        for polygon in obj.data.polygons:
            polygon.use_smooth = True
    return obj


def loft(name, stations, material, bevel=0.04, subdivision=2):
    """Create a continuous automotive shell from six-point cross sections.

    stations are (lengthwise_y, half_width, bottom_z, shoulder_z, top_z, top_half_width).
    """
    vertices, faces = [], []
    for y, width, bottom, shoulder, top, top_width in stations:
        vertices.extend([
            (-width, y, bottom), (width, y, bottom), (width, y, shoulder),
            (top_width, y, top), (-top_width, y, top), (-width, y, shoulder),
        ])
    for ring in range(len(stations) - 1):
        for point in range(6):
            next_point = (point + 1) % 6
            faces.append((ring * 6 + point, ring * 6 + next_point, (ring + 1) * 6 + next_point, (ring + 1) * 6 + point))
    faces.append(tuple(range(5, -1, -1)))
    end = (len(stations) - 1) * 6
    faces.append(tuple(end + point for point in range(6)))
    mesh = bpy.data.meshes.new(name + " mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(material)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    smooth(obj)
    bevel_mod = obj.modifiers.new("Panel edge softness", "BEVEL")
    bevel_mod.width = bevel
    bevel_mod.segments = 3
    sub = obj.modifiers.new("Continuous body surface", "SUBSURF")
    sub.levels = subdivision
    sub.render_levels = subdivision
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=bevel_mod.name)
    bpy.ops.object.modifier_apply(modifier=sub.name)
    return obj


def cube(name, location, size, material, bevel=0.04):
    bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material)
    modifier = obj.modifiers.new("Soft edges", "BEVEL")
    modifier.width = bevel
    modifier.segments = 4
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    return smooth(obj)


def wheel(name, x, y, radius, tire, rim, brake):
    bpy.ops.mesh.primitive_torus_add(major_radius=radius * 0.75, minor_radius=radius * 0.25, major_segments=56, minor_segments=16, location=(x, y, radius), rotation=(0, radians(90), 0))
    tire_obj = bpy.context.object; tire_obj.name = name + " performance tire"; tire_obj.data.materials.append(tire); smooth(tire_obj)
    bpy.ops.mesh.primitive_cylinder_add(vertices=56, radius=radius * 0.60, depth=0.14, location=(x * 1.012, y, radius), rotation=(0, radians(90), 0))
    rim_obj = bpy.context.object; rim_obj.name = name + " alloy wheel"; rim_obj.data.materials.append(rim); smooth(rim_obj)
    bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=radius * 0.29, depth=0.155, location=(x * 1.022, y, radius), rotation=(0, radians(90), 0))
    brake_obj = bpy.context.object; brake_obj.name = name + " brake disc"; brake_obj.data.materials.append(brake); smooth(brake_obj)
    for angle in range(0, 360, 45):
        # Spokes rotate in the wheel's Y/Z plane; this reads as a real alloy from the chase camera.
        bpy.ops.mesh.primitive_cube_add(location=(x * 1.032, y, radius), rotation=(radians(angle), 0, 0))
        spoke = bpy.context.object; spoke.name = name + " rim spoke"; spoke.dimensions = (0.06, radius * 0.92, 0.075); bpy.ops.object.transform_apply(location=False, rotation=False, scale=True); spoke.data.materials.append(rim)
    return [tire_obj, rim_obj, brake_obj]


def add_lights(prefix, y, width, z, light_mat, tail=False):
    for x in (-width, width):
        light = cube(prefix + (" tail lamp" if tail else " head lamp"), (x, y, z), (0.46, 0.08, 0.11), light_mat, 0.04)
        light.rotation_euler.x = radians(-5 if not tail else 5)


def fender_arch(name, x, y, base_z, radius, material):
    """A rounded painted wheel arch; the visual anchor that stops the shell reading as a toy."""
    curve = bpy.data.curves.new(name + " curve", "CURVE")
    curve.dimensions = "3D"
    curve.resolution_u = 16
    curve.bevel_depth = 0.075
    curve.bevel_resolution = 4
    spline = curve.splines.new("POLY")
    point_count = 17
    spline.points.add(point_count - 1)
    for index in range(point_count):
        angle = radians(180.0 * index / (point_count - 1))
        spline.points[index].co = (x, y + radius * __import__("math").cos(angle), base_z + radius * __import__("math").sin(angle), 1)
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(material)
    return obj


def panel_seams(prefix, x, y, material, height=0.52):
    for offset in (-0.44, 0.44):
        cube(prefix + " door seam", (x, y + offset, 0.70), (0.022, 0.024, height), material, 0.005)


def common_materials(paint, accent):
    return {
        "paint": mat("Metallic paint", paint, 0.86, 0.16),
        "carbon": mat("Carbon trim", (0.006, 0.009, 0.014), 0.65, 0.24),
        "glass": mat("Smoked glass", (0.01, 0.055, 0.095), 0.25, 0.08),
        "tire": mat("Performance rubber", (0.004, 0.005, 0.008), 0.0, 0.74),
        "rim": mat("Machined alloy", (0.20, 0.25, 0.32), 0.92, 0.12),
        "brake": mat("Brake caliper", accent, 0.25, 0.22, accent),
        "head": mat("LED headlamp", (0.30, 0.85, 1.0), 0.2, 0.08, (0.30, 0.85, 1.0)),
        "tail": mat("LED tail lamp", (1.0, 0.015, 0.035), 0.2, 0.10, (1.0, 0.015, 0.035)),
    }


def export(name):
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT / f"{name}.blend"))
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=str(OUT / f"{name}.glb"), export_format="GLB", export_materials="EXPORT", export_apply=True)


def apex_s():
    clear(); m = common_materials((0.70, 0.008, 0.035), (0.20, 0.82, 1.0))
    root = bpy.data.objects.new("Rainline Apex S v2", None); bpy.context.collection.objects.link(root)
    body = loft("Apex sculpted body", [(-2.34,.67,.23,.39,.52,.42),(-1.92,.98,.22,.57,.72,.70),(-.66,1.05,.23,.68,.79,.84),(.78,1.04,.24,.66,.76,.78),(1.78,.99,.24,.54,.65,.64),(2.24,.77,.25,.42,.53,.48)], m["paint"])
    canopy = loft("Apex glass canopy", [(-.92,.59,.73,.80,1.00,.47),(-.38,.70,.77,1.12,1.30,.55),(.46,.70,.77,1.12,1.31,.56),(1.12,.59,.72,.85,1.01,.46)], m["glass"], .025, 2)
    for obj in (body, canopy): obj.parent = root
    cube("Apex front splitter", (0,-2.25,.22), (1.55,.30,.10), m["carbon"], .035).parent = root
    cube("Apex rear diffuser", (0,2.18,.24), (1.52,.25,.12), m["carbon"], .035).parent = root
    add_lights("Apex", -2.22, .64, .55, m["head"]); add_lights("Apex", 2.21, .66, .57, m["tail"], True)
    for x in (-1.02, 1.02):
        for y in (-1.46, 1.46):
            for obj in wheel("Apex", x, y, .47, m["tire"], m["rim"], m["brake"]): obj.parent = root
    for x in (-1.065, 1.065):
        for y in (-1.46, 1.46): fender_arch("Apex painted fender", x, y, .47, .56, m["paint"]).parent = root
        panel_seams("Apex", x, 0.02, m["carbon"])
    cube("Apex rear lamp bar", (0,2.225,.57), (1.48,.065,.09), m["tail"], .025).parent = root
    export("rainline_apex_s_v3")


def coastline_gt():
    clear(); m = common_materials((0.008, 0.08, 0.38), (0.20, 0.86, 1.0))
    root = bpy.data.objects.new("Rainline Coastline GT v2", None); bpy.context.collection.objects.link(root)
    body = loft("Coastline fastback body", [(-2.64,.68,.25,.42,.56,.46),(-2.18,1.00,.24,.60,.77,.73),(-.78,1.08,.24,.70,.86,.90),(.72,1.07,.24,.68,.83,.84),(1.90,1.00,.25,.57,.71,.70),(2.50,.76,.26,.43,.55,.49)], m["paint"])
    canopy = loft("Coastline fastback glass", [(-1.16,.60,.78,.86,1.06,.48),(-.48,.74,.83,1.20,1.38,.58),(.62,.72,.80,1.16,1.32,.56),(1.48,.58,.72,.88,1.04,.45)], m["glass"], .025, 2)
    for obj in (body, canopy): obj.parent = root
    cube("Coastline grille", (0,-2.54,.44), (1.16,.08,.20), m["carbon"], .025).parent = root
    cube("Coastline deck spoiler", (0,2.15,.88), (1.34,.15,.07), m["carbon"], .025).parent = root
    add_lights("Coastline", -2.49, .69, .61, m["head"]); add_lights("Coastline", 2.47, .70, .62, m["tail"], True)
    for x in (-1.05, 1.05):
        for y in (-1.64, 1.64):
            for obj in wheel("Coastline", x, y, .49, m["tire"], m["rim"], m["brake"]): obj.parent = root
    for x in (-1.095, 1.095):
        for y in (-1.64, 1.64): fender_arch("Coastline painted fender", x, y, .49, .58, m["paint"]).parent = root
        panel_seams("Coastline", x, 0.04, m["carbon"], .56)
    cube("Coastline rear lamp bar", (0,2.505,.62), (1.58,.065,.09), m["tail"], .025).parent = root
    export("rainline_coastline_gt_v3")


def irontrail_x():
    clear(); m = common_materials((0.095, 0.11, 0.14), (1.0, 0.40, 0.04))
    root = bpy.data.objects.new("Rainline Irontrail X v2", None); bpy.context.collection.objects.link(root)
    # Deliberately taller and squarer than the coupes: this has to read as a pickup from behind.
    chassis = loft("Irontrail broad chassis", [(-2.78,.92,.49,.66,.86,.78),(-2.34,1.28,.50,.86,1.12,1.08),(-.78,1.31,.52,.90,1.18,1.12),(.52,1.29,.53,.89,1.16,1.10),(1.96,1.27,.53,.82,1.07,1.06),(2.68,1.02,.53,.69,.87,.82)], m["paint"], .08, 1)
    cab = loft("Irontrail tall crew cab", [(-1.82,.97,1.02,1.18,1.70,.84),(-1.30,1.04,1.04,1.65,2.14,.88),(-.15,1.04,1.06,1.76,2.22,.89),(.55,.99,1.04,1.42,1.87,.82)], m["paint"], .07, 2)
    glass = loft("Irontrail upright glass", [(-1.62,.80,1.44,1.57,1.88,.68),(-1.12,.86,1.65,1.95,2.13,.72),(-.18,.86,1.69,2.00,2.18,.73),(.38,.80,1.43,1.68,1.91,.67)], m["glass"], .02, 1)
    bed = cube("Irontrail open cargo bed", (0,1.50,1.17), (2.30,1.82,.26), m["carbon"], .04)
    for obj in (chassis,cab,glass,bed): obj.parent = root
    # Raised side panels, tailgate and bed rails create a visible pickup box in the rear chase view.
    for x in (-1.22, 1.22):
        cube("Irontrail cargo-bed side", (x,1.52,1.48), (.15,1.96,.78), m["paint"], .05).parent = root
        cube("Irontrail bed rail", (x,1.52,1.91), (.18,2.02,.10), m["carbon"], .025).parent = root
    cube("Irontrail tall tailgate", (0,2.62,1.48), (2.38,.16,.84), m["paint"], .055).parent = root
    cube("Irontrail tailgate trim", (0,2.715,1.43), (1.80,.04,.12), m["carbon"], .018).parent = root
    cube("Irontrail bumper", (0,2.76,.69), (2.42,.25,.26), m["carbon"], .05).parent = root
    cube("Irontrail grille", (0,-2.76,.88), (1.60,.10,.34), m["carbon"], .025).parent = root
    add_lights("Irontrail", -2.74, .88, 1.10, m["head"]); add_lights("Irontrail", 2.72, .90, 1.30, m["tail"], True)
    for x in (-1.34, 1.34):
        for y in (-1.78, 1.78):
            for obj in wheel("Irontrail", x, y, .80, m["tire"], m["rim"], m["brake"]): obj.parent = root
    for x in (-1.41, 1.41):
        for y in (-1.78, 1.78): fender_arch("Irontrail painted fender", x, y, .80, .89, m["paint"]).parent = root
        panel_seams("Irontrail", x, -0.42, m["carbon"], .68)
    cube("Irontrail tail lamp bar", (0,2.72,1.30), (1.88,.065,.13), m["tail"], .025).parent = root
    export("rainline_irontrail_x_v4")


apex_s(); coastline_gt(); irontrail_x()
