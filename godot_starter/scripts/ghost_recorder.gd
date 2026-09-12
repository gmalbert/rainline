class_name GhostRecorder
extends Node

## Transform-sampled ghost recorder.
## This avoids requiring deterministic physics across machines/builds.

@export var target: Node3D
@export var sample_hz: float = 25.0

var samples: Array[Dictionary] = []
var recording := false
var elapsed := 0.0
var accumulator := 0.0

func start_recording() -> void:
    samples.clear()
    elapsed = 0.0
    accumulator = 0.0
    recording = true

func stop_recording() -> Array[Dictionary]:
    recording = false
    return samples.duplicate(true)

func _physics_process(delta: float) -> void:
    if not recording or target == null:
        return

    elapsed += delta
    accumulator += delta
    var interval := 1.0 / max(sample_hz, 1.0)

    while accumulator >= interval:
        accumulator -= interval
        samples.append({
            "t": elapsed,
            "p": [
                target.global_position.x,
                target.global_position.y,
                target.global_position.z
            ],
            "q": [
                target.global_transform.basis.get_rotation_quaternion().x,
                target.global_transform.basis.get_rotation_quaternion().y,
                target.global_transform.basis.get_rotation_quaternion().z,
                target.global_transform.basis.get_rotation_quaternion().w
            ]
        })
