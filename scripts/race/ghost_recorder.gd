class_name GhostRecorder
extends Node

@export var target: Node3D
@export var sample_hz := 20.0
var samples: Array[Dictionary] = []
var recording := false
var elapsed := 0.0
var accumulator := 0.0

func start_recording() -> void:
	samples.clear(); elapsed = 0.0; accumulator = 0.0; recording = true

func stop_recording() -> Array[Dictionary]:
	recording = false
	return samples.duplicate(true)

func _physics_process(delta: float) -> void:
	if not recording or target == null: return
	elapsed += delta; accumulator += delta
	var interval := 1.0 / sample_hz
	while accumulator >= interval:
		accumulator -= interval
		var q := target.global_transform.basis.get_rotation_quaternion()
		samples.append({"t": elapsed, "p": [target.global_position.x, target.global_position.y, target.global_position.z], "q": [q.x, q.y, q.z, q.w]})
