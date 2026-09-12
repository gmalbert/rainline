"""Build three mesh-based landmark kits for Rainline Run."""
import bpy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MESH = ROOT / "assets" / "meshes"
TEX = ROOT / "assets" / "textures"

def clear():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

def material(name, color, metallic=0.0, roughness=0.5, emission=None):
    m=bpy.data.materials.new(name); m.use_nodes=True
    p=m.node_tree.nodes.get("Principled BSDF"); p.inputs["Base Color"].default_value=(*color,1); p.inputs["Metallic"].default_value=metallic; p.inputs["Roughness"].default_value=roughness
    if emission: p.inputs["Emission Color"].default_value=(*emission,1); p.inputs["Emission Strength"].default_value=.7
    return m

def image_material(name, image):
    m=material(name,(.25,.32,.34),.05,.4); n=m.node_tree.nodes; t=n.new("ShaderNodeTexImage"); t.image=bpy.data.images.load(str(image),check_existing=True); p=n.get("Principled BSDF"); m.node_tree.links.new(t.outputs["Color"],p.inputs["Base Color"]); m.node_tree.links.new(t.outputs["Color"],p.inputs["Emission Color"]); p.inputs["Emission Strength"].default_value=.18; return m

def cube(name, pos, size, m):
    bpy.ops.mesh.primitive_cube_add(location=pos); o=bpy.context.object; o.name=name; o.scale=(size[0]/2,size[1]/2,size[2]/2); bpy.ops.object.transform_apply(location=False,rotation=False,scale=True); o.data.materials.append(m); bevel=o.modifiers.new("EdgeSoftness","BEVEL"); bevel.width=.05; bevel.segments=2; return o

def export(name):
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=str(MESH/name),export_format="GLB",use_selection=True,export_materials="EXPORT")

dark=material("Charcoal",(.035,.05,.06),.7,.32); brick=material("RainBrick",(.18,.075,.055),.1,.72); glass=material("WindowGlow",(.03,.18,.21),.25,.16,(.02,.24,.3)); amber=material("WarmTrim",(.62,.20,.04),.22,.38,(.8,.14,.02)); steel=material("Steel",(.14,.2,.23),.8,.28)

# Historic market: layered hall, actual awnings, window bays, roof sign frame.
clear(); art=image_material("MarketInterior",TEX/"landmark_market_hall_v1.png")
cube("MarketHall",(0,6,2),(28,12,6),brick); cube("MarketArtRecess",(0,6,-1.05),(24,8.8,.08),art)
for x in (-10,-5,0,5,10):
    cube("MarketWindow",(x,6,-1.2),(3.7,6.2,.16),glass); cube("MarketMullion",(x-2,6,-1.34),(.16,7,.22),dark); cube("MarketAwning",(x,3.2,-2),(4.1,.28,1.35),amber)
cube("MarketCornice",(0,10.4,-1.35),(27,.35,.3),dark); cube("MarketRoof",(0,12.5,2),(30,1,7),steel); cube("MarketSignFrame",(0,13.3,-1.6),(16,2.4,.25),dark)
export("rainline_market_block_v1.glb")

# Cultural pavilion: layered angular halls and transparent display bays.
clear(); art=image_material("CulturalInterior",TEX/"landmark_cultural_district_v1.png")
for x,z,w,h,d in [(-6,0,13,10,12),(5,1,16,13,14),(0,-5,25,7,5)]: cube("CulturalWing",(x,h/2,z),(w,h,d),steel)
cube("CulturalArtRecess",(0,7,-6.6),(22,11,.08),art)
for x in (-8,-4,0,4,8): cube("GalleryBay",(x,5,-6.8),(3.1,7,.18),glass)
cube("PavilionCanopy",(0,11.6,-7.5),(27,.38,2.0),amber); cube("PavilionSpire",(8,16,2),(.45,7,.45),dark)
export("rainline_cultural_pavilion_v1.glb")

# Waterfront civic complex: wheel frame, stadium-style canopy, pier building.
clear(); art=image_material("WaterfrontInterior",TEX/"landmark_waterfront_civic_v1.png")
cube("WaterfrontHall",(0,5,2),(32,10,7),steel); cube("WaterfrontArtRecess",(0,5,-1.6),(28,7.8,.08),art)
for x in (-11,-5,1,7,13): cube("WaterfrontWindow",(x,5,-1.78),(4.4,5.8,.18),glass)
bpy.ops.mesh.primitive_torus_add(major_radius=8,minor_radius=.45,location=(13,14,3),rotation=(1.5708,0,0)); bpy.context.object.name="ObservationWheel"; bpy.context.object.data.materials.append(amber)
cube("WheelSupport",(13,6,3),(.7,12,.7),dark); cube("CivicCanopy",(-10,11,2),(18,.8,12),dark); cube("Pier",(0,.6,8),(38,1.2,16),brick)
export("rainline_waterfront_civic_v1.glb")
