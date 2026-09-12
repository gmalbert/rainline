"""Build a layered storefront kit for Rainline Run with Blender.

The generated facade image is used only as recessed interior detail; windows,
frames, awnings, roof equipment, and side walls are real mesh depth.
"""
import bpy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "meshes" / "rainline_streetfront_v1.glb"
IMAGE = ROOT / "assets" / "textures" / "facade_storefront_district_v1.png"

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

def mat(name, color, metallic=0.0, roughness=0.5, emission=None):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1)
    material.use_nodes = True
    bsdf = material.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1)
        bsdf.inputs["Emission Strength"].default_value = 0.8
    return material

def image_mat():
    material = mat("InteriorFacadeArt", (0.32, 0.42, 0.44), 0.05, 0.42)
    nodes = material.node_tree.nodes
    links = material.node_tree.links
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(str(IMAGE), check_existing=True)
    bsdf = nodes.get("Principled BSDF")
    links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    links.new(tex.outputs["Color"], bsdf.inputs["Emission Color"])
    bsdf.inputs["Emission Strength"].default_value = 0.25
    return material

STRUCT = mat("WetCharcoalStructure", (0.035, 0.055, 0.07), 0.75, 0.3)
CONCRETE = mat("Concrete", (0.10, 0.12, 0.13), 0.15, 0.72)
GLASS = mat("RainGlass", (0.035, 0.18, 0.22), 0.25, 0.18, (0.02, 0.22, 0.26))
AMBER = mat("AwningAmber", (0.55, 0.17, 0.04), 0.3, 0.33, (0.7, 0.12, 0.02))
ART = image_mat()

def cube(name, location, scale, material, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (scale[0] / 2, scale[1] / 2, scale[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = obj.modifiers.new("SoftEdges", "BEVEL")
        mod.width = bevel
        mod.segments = 2
    obj.data.materials.append(material)
    return obj

# Three joined but varied storefront bays with actual depth.
for building, x in enumerate((-10.0, 0.0, 10.0)):
    height = (11.5, 14.0, 9.5)[building]
    width = 9.2
    cube("BuildingShell", (x, height / 2, 1.7), (width, height, 3.8), CONCRETE, 0.08)
    cube("RecessedFacadeArt", (x, height * 0.45, -0.25), (width - 1.0, height * 0.72, 0.08), ART)
    for level in range(3):
        y = 1.8 + level * 2.5
        for bay in range(3):
            bx = x - 2.7 + bay * 2.7
            cube("Window", (bx, y, -0.38), (2.15, 1.75, 0.17), GLASS, 0.03)
            cube("WindowFrame", (bx - 1.14, y, -0.51), (0.12, 2.05, 0.22), STRUCT)
        cube("FloorBand", (x, y + 1.0, -0.54), (width - 0.45, 0.16, 0.24), STRUCT)
    cube("Awning", (x, 4.55, -1.05), (width - 0.55, 0.28, 1.25), AMBER, 0.05)
    cube("EntryCanopy", (x, 2.15, -1.12), (3.0, 0.20, 1.5), STRUCT, 0.04)
    cube("RoofParapet", (x, height + 0.45, 1.7), (width + 0.4, 0.9, 4.2), STRUCT)
    cube("RoofPlant", (x + 2.1, height + 1.15, 1.4), (1.7, 0.75, 1.2), STRUCT, 0.04)

# continuous columns connect the row and avoid billboard edges.
for x in (-14.65, -5.0, 5.0, 14.65):
    cube("StreetColumn", (x, 7.5, -0.72), (0.5, 15.0, 0.6), STRUCT, 0.04)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT / "assets" / "meshes" / "rainline_streetfront_v1.blend"))
bpy.ops.export_scene.gltf(filepath=str(OUT), export_format="GLB", use_selection=True, export_materials="EXPORT")
