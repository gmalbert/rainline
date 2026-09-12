extends Node

## Lightweight original placeholder mix. Replace this generator with authored assets later
## without changing the gameplay-facing API.
var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var phase := 0.0
var wind_phase := 0.0
var engine_frequency := 52.0
var target_engine_frequency := 52.0
var cue_frequency := 0.0
var cue_remaining := 0.0
var rain_phase := 0.0
var muted := false
var engine_load := 0.0
var target_engine_load := 0.0
var engine_mix := 0.0
var engine_enabled := false
var tunnel_amount := 0.0
const MIX_RATE := 22050.0

func _ready() -> void:
	player = AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = MIX_RATE
	stream.buffer_length = 0.15
	player.stream = stream
	player.volume_db = -6.0
	add_child(player)
	player.play()
	playback = player.get_stream_playback()

func set_engine_speed(kph: float) -> void:
	# Keep the synthesized fundamental in a believable low engine band. Speed is
	# conveyed by load and wind texture, not by letting the motor become a shrill
	# sine wave at highway pace.
	engine_enabled = true
	var speed_ratio := clampf(kph / 560.0, 0.0, 1.0)
	target_engine_frequency = 42.0 + pow(speed_ratio, 0.68) * 112.0

func set_engine_load(throttle: float, boosting: bool) -> void:
	engine_enabled = true
	target_engine_load = clampf(throttle + (0.35 if boosting else 0.0), 0.0, 1.0)

func set_tunnel_amount(value: float) -> void:
	tunnel_amount = clampf(value, 0.0, 1.0)

func release_engine() -> void:
	# Prevent the synthesized RPM loop from retaining its last driving target across results, menus, or pause.
	engine_enabled = false
	target_engine_frequency = 52.0
	target_engine_load = 0.0
	tunnel_amount = 0.0

func toggle_mute() -> void:
	muted = not muted
	player.volume_db = -80.0 if muted else -6.0

func play_ui(cue: StringName) -> void:
	match cue:
		&"countdown": _cue(480.0, 0.08)
		&"go": _cue(720.0, 0.16)
		&"checkpoint": _cue(620.0, 0.12)
		&"finish": _cue(840.0, 0.35)
		_: _cue(380.0, 0.08)

func play_vehicle(cue: StringName, intensity: float = 1.0) -> void:
	if cue == &"boost": _cue(160.0 + intensity * 90.0, 0.18)
	if cue == &"impact": _cue(90.0, 0.06)
	if cue == &"drift": _cue(260.0 + intensity * 110.0, 0.11)

func _process(delta: float) -> void:
	engine_frequency = lerpf(engine_frequency, target_engine_frequency, clampf(delta * 7.0, 0.0, 1.0))
	engine_load = lerpf(engine_load, target_engine_load, clampf(delta * 8.0, 0.0, 1.0))
	engine_mix = lerpf(engine_mix, 1.0 if engine_enabled else 0.0, clampf(delta * 5.5, 0.0, 1.0))
	if playback == null: return
	var frames: int = min(playback.get_frames_available(), 1024)
	for _frame in frames:
		phase = fmod(phase + engine_frequency / MIX_RATE, 1.0)
		var throttle_weight := 0.035 + engine_load * 0.050
		var rpm_shape: float = (sin(phase * TAU * 0.5) * 0.060 + sin(phase * TAU) * 0.075 + sin(phase * TAU * 2.0) * throttle_weight + sin(phase * TAU * 3.0) * (0.010 + engine_load * 0.012)) * engine_mix
		rain_phase = fmod(rain_phase + 0.173, 1.0)
		var rain: float = (rain_phase - 0.5) * 0.018
		var speed_band := clampf((engine_frequency - 58.0) / 96.0, 0.0, 1.0)
		wind_phase = fmod(wind_phase + (28.0 + speed_band * 54.0) / MIX_RATE, 1.0)
		var wind: float = (sin(wind_phase * TAU) * 0.014 + sin(wind_phase * TAU * 2.13) * 0.008) * speed_band * engine_mix
		var tunnel_resonance: float = sin(phase * TAU * 0.5) * tunnel_amount * 0.026
		var sample: float = rpm_shape + rain + wind + tunnel_resonance
		if cue_remaining > 0.0:
			sample += sin(phase * TAU * cue_frequency / maxf(engine_frequency, 1.0)) * 0.28
			cue_remaining -= 1.0 / MIX_RATE
		playback.push_frame(Vector2(sample, sample))

func _cue(frequency: float, duration: float) -> void:
	cue_frequency = frequency
	cue_remaining = duration
