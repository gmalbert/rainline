class_name RaceEventDefinition
extends Resource

@export var event_id: StringName
@export var display_name := "Rainline Run"
@export_file("*.tscn") var scene_path: String
@export_enum("Sprint", "Circuit", "Rival", "Time Attack", "Delivery", "Trial") var event_type := "Time Attack"
@export var bronze_time_ms := 210000
@export var silver_time_ms := 180000
@export var gold_time_ms := 155000
@export var weather_profile := "drizzle_night"
@export var handling_version := "rainline_v1"
