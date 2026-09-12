extends Node

const SAVE_PATH := "user://profile.json"
const BACKUP_PATH := "user://profile.backup.json"
const SCHEMA_VERSION := 2

func default_data() -> Dictionary:
	return {"schema_version": SCHEMA_VERSION, "best_times_ms": {}, "ghosts": {}, "settings": {"graphics": "showcase", "first_person_camera": false, "comfort_camera": false, "selected_vehicle": 0}}

func load_profile() -> Dictionary:
	var parsed := _read_profile(SAVE_PATH)
	if parsed.is_empty(): parsed = _read_profile(BACKUP_PATH)
	if parsed.is_empty(): return default_data()
	parsed["schema_version"] = SCHEMA_VERSION
	var defaults := default_data()
	parsed.merge(defaults, false)
	var settings: Dictionary = defaults["settings"].duplicate()
	var saved_settings = parsed.get("settings", {})
	if saved_settings is Dictionary: settings.merge(saved_settings, true)
	parsed["settings"] = settings
	return parsed

func _read_profile(path: String) -> Dictionary:
	if not FileAccess.file_exists(path): return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func save_profile(data: Dictionary) -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var old := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
		if old and backup: backup.store_string(old.get_as_text())
	data["schema_version"] = SCHEMA_VERSION
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(data, "\t"))
	return true
