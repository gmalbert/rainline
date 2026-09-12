class_name RaceCheckpoint
extends Area3D

@export var checkpoint_index: int = 0
@export var race_manager_path: NodePath

@onready var race_manager: RaceManager = get_node(race_manager_path)

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
    if body is ArcadeCar:
        race_manager.try_checkpoint(checkpoint_index)
