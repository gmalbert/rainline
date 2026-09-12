class_name GhostPlayer
extends Node3D

var samples: Array = []
var playback_time := 0.0
var sample_index := 0
var active := false

func load_and_start(data: Array) -> void:
	samples = data; playback_time = 0.0; sample_index = 0; active = samples.size() > 1

func _process(delta: float) -> void:
	if not active: return
	playback_time += delta
	while sample_index < samples.size() - 2 and float(samples[sample_index + 1]["t"]) < playback_time: sample_index += 1
	var a: Dictionary = samples[sample_index]
	var b: Dictionary = samples[min(sample_index + 1, samples.size() - 1)]
	var span: float = maxf(0.0001, float(b["t"]) - float(a["t"]))
	var alpha: float = clampf((playback_time - float(a["t"])) / span, 0.0, 1.0)
	global_position = Vector3(a["p"][0], a["p"][1], a["p"][2]).lerp(Vector3(b["p"][0], b["p"][1], b["p"][2]), alpha)
	global_transform.basis = Basis(Quaternion(a["q"][0], a["q"][1], a["q"][2], a["q"][3]).slerp(Quaternion(b["q"][0], b["q"][1], b["q"][2], b["q"][3]), alpha))
	if playback_time >= float(samples[-1]["t"]): active = false
