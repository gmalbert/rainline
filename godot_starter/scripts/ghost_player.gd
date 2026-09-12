class_name GhostPlayer
extends Node3D

@export var ghost_visual: Node3D
var samples: Array = []
var playback_time := 0.0
var active := false
var sample_index := 0

func load_samples(data: Array) -> void:
    samples = data
    playback_time = 0.0
    sample_index = 0

func start() -> void:
    active = samples.size() >= 2
    playback_time = 0.0
    sample_index = 0

func _process(delta: float) -> void:
    if not active:
        return

    playback_time += delta

    while sample_index < samples.size() - 2 and samples[sample_index + 1]["t"] < playback_time:
        sample_index += 1

    var a: Dictionary = samples[sample_index]
    var b: Dictionary = samples[min(sample_index + 1, samples.size() - 1)]
    var span: float = max(0.0001, float(b["t"]) - float(a["t"]))
    var alpha: float = clamp((playback_time - float(a["t"])) / span, 0.0, 1.0)

    var pa := Vector3(a["p"][0], a["p"][1], a["p"][2])
    var pb := Vector3(b["p"][0], b["p"][1], b["p"][2])

    var qa := Quaternion(a["q"][0], a["q"][1], a["q"][2], a["q"][3])
    var qb := Quaternion(b["q"][0], b["q"][1], b["q"][2], b["q"][3])

    ghost_visual.global_position = pa.lerp(pb, alpha)
    ghost_visual.global_transform.basis = Basis(qa.slerp(qb, alpha))

    if playback_time >= float(samples[-1]["t"]):
        active = false
