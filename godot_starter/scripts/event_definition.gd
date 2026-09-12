class_name RaceEventDefinition
extends Resource

@export var event_id: StringName
@export var display_name: String
@export_file("*.tscn") var scene_path: String
@export_enum("Sprint", "Circuit", "Rival", "Time Attack", "Delivery", "Trial") var event_type: String = "Sprint"
@export var bronze_time_ms: int = 180000
@export var silver_time_ms: int = 165000
@export var gold_time_ms: int = 150000
@export var credit_reward: int = 500
@export var rep_reward: int = 100
