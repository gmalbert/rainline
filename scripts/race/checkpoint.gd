class_name RaceCheckpoint
extends Area3D

@export var checkpoint_index := 0
var race_manager: RaceManager
var marker_materials: Array[StandardMaterial3D] = []
var gate_light: OmniLight3D
var active := false

func setup(index: int, manager: RaceManager) -> void:
	checkpoint_index = index
	race_manager = manager
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is ArcadeCar and race_manager.try_checkpoint(checkpoint_index):
		queue_free()

func configure_visuals(meshes: Array[MeshInstance3D], light: OmniLight3D) -> void:
	gate_light = light
	for mesh in meshes:
		var material := mesh.material_override as StandardMaterial3D
		if material != null: marker_materials.append(material)
	set_active(false)

func set_active(value: bool) -> void:
	active = value
	for material in marker_materials:
		material.emission = Color("42dfff") if active else Color("ff9d1c")
		material.albedo_color = Color("77eaff") if active else Color("ffb62f")
	if gate_light != null:
		gate_light.light_color = Color("42dfff") if active else Color("ffbd50")
		gate_light.light_energy = 8.0 if active else 2.2
	set_process(active)

func _process(_delta: float) -> void:
	if gate_light != null:
		gate_light.light_energy = 6.5 + sin(Time.get_ticks_msec() * 0.008) * 2.0
