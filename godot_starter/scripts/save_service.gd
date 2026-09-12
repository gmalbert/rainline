class_name SaveService
extends Node

const SAVE_PATH := "user://profile.json"
const BACKUP_PATH := "user://profile.backup.json"
const SCHEMA_VERSION := 1

func default_data() -> Dictionary:
    return {
        "schema_version": SCHEMA_VERSION,
        "profile": {"credits": 0, "rep": 0},
        "unlocks": ["rainline_run"],
        "best_times_ms": {}
    }

func load_profile() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return default_data()

    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_error("Could not open save file.")
        return default_data()

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Save file is corrupt; using default profile.")
        return default_data()

    return _migrate(parsed)

func save_profile(data: Dictionary) -> bool:
    if FileAccess.file_exists(SAVE_PATH):
        var existing := FileAccess.open(SAVE_PATH, FileAccess.READ)
        if existing:
            var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
            if backup:
                backup.store_string(existing.get_as_text())

    data["schema_version"] = SCHEMA_VERSION
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        push_error("Could not write save file.")
        return false

    file.store_string(JSON.stringify(data, "\t"))
    return true

func _migrate(data: Dictionary) -> Dictionary:
    var version := int(data.get("schema_version", 0))
    # Add explicit migrations here as the schema evolves.
    if version < 1:
        data["schema_version"] = 1
    return data
