class_name ArcadeCar
extends CharacterBody3D

signal drift_started
signal drift_ended(score: float)
signal boost_changed(value: float, maximum: float)
signal speed_changed(kph: float)
signal recovered
signal collision_feedback(impact: float)
signal boost_started
signal boost_ended
signal track_boosted(power: float)

@export_category("Speed")
@export var acceleration := 30.0
@export var brake_strength := 58.0
@export var max_speed := 145.0
@export var boosted_max_speed := 180.0
@export var overspeed_drag := 0.025
@export_category("Handling")
@export var steering_rate := 1.85
@export var normal_lateral_grip := 8.5
@export var drift_lateral_grip := 2.4
@export var drift_min_speed := 12.0
@export var high_speed_grip_bonus := 3.5
@export_category("Boost")
@export var boost_capacity := 100.0
@export var boost_drain_per_second := 18.0

var boost_amount := 65.0
var is_drifting := false
var drift_score := 0.0
var last_safe_transform: Transform3D
var can_drive := false
var is_boosting := false
var gravity := 28.0
var recovery_floor_y := -45.0
var stalled_contact_seconds := 0.0

func _ready() -> void:
	last_safe_transform = global_transform
	boost_changed.emit(boost_amount, boost_capacity)

func _physics_process(delta: float) -> void:
	if global_position.y < recovery_floor_y:
		reset_to_safe_position()
		return
	if not is_on_floor(): velocity.y -= gravity * delta
	else: velocity.y = -0.2
	if Input.is_action_just_pressed("reset_car"): reset_to_safe_position()
	if not can_drive:
		move_and_slide()
		return
	var steer := Input.get_axis("steer_left", "steer_right")
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	var forward_speed := velocity.dot(forward)
	var lateral_speed := velocity.dot(right)
	var flat_speed := Vector2(velocity.x, velocity.z).length()
	var handbrake := Input.is_action_pressed("handbrake")
	var should_drift: bool = flat_speed >= drift_min_speed and abs(steer) > 0.3 and handbrake
	_set_drift(should_drift)
	if Input.is_action_pressed("throttle"):
		velocity += forward * acceleration * delta
	if Input.is_action_pressed("brake"):
		if forward_speed > 1.0: velocity = velocity.move_toward(Vector3.UP * velocity.y, brake_strength * delta)
		else: velocity -= forward * acceleration * 0.35 * delta
	var speed_ratio: float = clampf(flat_speed / 120.0, 0.0, 1.0)
	var grip := drift_lateral_grip if is_drifting else normal_lateral_grip + high_speed_grip_bonus * speed_ratio
	velocity -= right * lateral_speed * min(1.0, grip * delta)
	if flat_speed > 0.7:
		var authority: float = lerpf(1.0, 0.36, clampf(flat_speed / max_speed, 0.0, 1.0))
		rotate_y(-steer * steering_rate * authority * (1.32 if is_drifting else 1.0) * delta)
	var boosting := Input.is_action_pressed("boost") and boost_amount > 0.0
	if boosting != is_boosting:
		is_boosting = boosting
		if is_boosting: boost_started.emit()
		else: boost_ended.emit()
	if boosting:
		velocity += forward * 37.0 * delta
		_set_boost(boost_amount - boost_drain_per_second * delta)
	# Wet-road drag remains present, but no longer creates an artificial sub-300 mph ceiling.
	velocity.x *= 1.0 - 0.15 * delta
	velocity.z *= 1.0 - 0.15 * delta
	_apply_overspeed_resistance(delta, flat_speed, boosting)
	move_and_slide()
	_apply_collision_scrub()
	_recover_if_stalled(delta)
	# Recovery points are authored by the route/checkpoints, never sampled at a road edge.
	if is_drifting:
		drift_score += 12.0 * clamp(flat_speed / max_speed, 0.2, 1.0) * delta
		_set_boost(boost_amount + 10.0 * clamp(abs(lateral_speed) / 10.0, 0.15, 1.0) * delta)
	speed_changed.emit(flat_speed * 3.6)

func _set_drift(value: bool) -> void:
	if value == is_drifting: return
	is_drifting = value
	if value:
		drift_score = 0.0; drift_started.emit()
	else: drift_ended.emit(drift_score)

func _apply_collision_scrub() -> void:
	for index in get_slide_collision_count():
		var contact := get_slide_collision(index)
		var impact: float = absf(velocity.dot(contact.get_normal()))
		if impact < 2.0: continue
		# A glancing scrape remains driveable; a head-on hit costs more momentum.
		var retention: float = lerpf(0.9, 0.52, clampf(impact / 32.0, 0.0, 1.0))
		velocity = velocity.slide(contact.get_normal()) * retention
		collision_feedback.emit(impact)

func _recover_if_stalled(delta: float) -> void:
	# A low-speed push into world geometry should never strand the run indefinitely.
	var trying_to_drive := Input.is_action_pressed("throttle") or Input.is_action_pressed("brake")
	var near_stationary := Vector2(velocity.x, velocity.z).length() < 1.2
	if get_slide_collision_count() > 0 and trying_to_drive and near_stationary:
		stalled_contact_seconds += delta
		if stalled_contact_seconds > 1.15:
			reset_to_safe_position()
			stalled_contact_seconds = 0.0
	else:
		stalled_contact_seconds = maxf(0.0, stalled_contact_seconds - delta * 2.0)

func _apply_overspeed_resistance(delta: float, flat_speed: float, boosting: bool) -> void:
	# No artificial top-speed wall: drag grows quadratically beyond the authored cruise speed.
	var cruise_speed: float = boosted_max_speed if boosting else max_speed
	if flat_speed <= cruise_speed: return
	var excess: float = flat_speed - cruise_speed
	var flat_velocity := Vector3(velocity.x, 0, velocity.z)
	velocity -= flat_velocity.normalized() * excess * excess * overspeed_drag * delta

func _set_boost(value: float) -> void:
	var clamped: float = clampf(value, 0.0, boost_capacity)
	if is_equal_approx(clamped, boost_amount): return
	boost_amount = clamped
	boost_changed.emit(boost_amount, boost_capacity)

func award_boost(amount: float) -> void:
	_set_boost(boost_amount + amount)

func apply_track_boost(power: float) -> void:
	# Track strips are a forward impulse, not a teleport or a speed-cap bypass.
	velocity += -global_transform.basis.z * power
	_set_boost(boost_amount + power * 0.25)
	track_boosted.emit(power)

func current_speed_mps() -> float:
	return Vector2(velocity.x, velocity.z).length()

func reset_to_safe_position() -> void:
	velocity = Vector3.ZERO
	is_boosting = false
	global_transform = last_safe_transform
	global_position += Vector3.UP * 0.8
	recovered.emit()

func set_recovery_transform(value: Transform3D) -> void:
	last_safe_transform = value
