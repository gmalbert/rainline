class_name ArcadeCar
extends CharacterBody3D

## Lightweight arcade vehicle controller.
## This deliberately uses authored forces rather than a wheel-by-wheel simulation.

signal drift_started
signal drift_ended(score: float)
signal boost_changed(value: float, maximum: float)

@export_category("Speed")
@export var acceleration: float = 26.0          # m/s^2
@export var reverse_acceleration: float = 12.0
@export var brake_strength: float = 38.0
@export var max_speed: float = 58.0             # ~209 km/h
@export var boosted_max_speed: float = 66.0     # ~238 km/h
@export var linear_drag: float = 0.45

@export_category("Steering")
@export var steering_rate: float = 1.9           # rad/s at low speed
@export var high_speed_steer_scale: float = 0.42
@export var yaw_damping: float = 3.5

@export_category("Grip / Drift")
@export var normal_lateral_grip: float = 8.0
@export var drift_lateral_grip: float = 2.2
@export var drift_yaw_multiplier: float = 1.55
@export var drift_min_speed: float = 12.0
@export var drift_min_steer: float = 0.35
@export var drift_boost_gain: float = 16.0

@export_category("Boost")
@export var boost_force: float = 34.0
@export var boost_capacity: float = 100.0
@export var boost_drain_per_second: float = 38.0

@export_category("Recovery")
@export var reset_height_offset: float = 0.4

var boost_amount: float = 0.0
var is_drifting: bool = false
var drift_score: float = 0.0
var last_safe_transform: Transform3D

func _ready() -> void:
    last_safe_transform = global_transform
    boost_changed.emit(boost_amount, boost_capacity)

func _physics_process(delta: float) -> void:
    var throttle := Input.get_action_strength("throttle")
    var brake := Input.get_action_strength("brake")
    var steer := Input.get_axis("steer_left", "steer_right")
    var handbrake := Input.is_action_pressed("handbrake")
    var wants_boost := Input.is_action_pressed("boost")

    var forward := -global_transform.basis.z
    var right := global_transform.basis.x
    var forward_speed := velocity.dot(forward)
    var lateral_speed := velocity.dot(right)
    var speed := velocity.length()

    _update_drift_state(speed, abs(steer), handbrake)
    _apply_longitudinal_forces(delta, forward, forward_speed, throttle, brake)
    _apply_lateral_grip(delta, right, lateral_speed)
    _apply_steering(delta, steer, speed)
    _apply_boost(delta, forward, wants_boost)

    velocity *= max(0.0, 1.0 - linear_drag * delta)

    var speed_cap := boosted_max_speed if wants_boost and boost_amount > 0.0 else max_speed
    if velocity.length() > speed_cap:
        velocity = velocity.normalized() * speed_cap

    move_and_slide()

    if is_on_floor() and speed > 3.0:
        last_safe_transform = global_transform

    if is_drifting:
        var speed_factor := clamp((speed - drift_min_speed) / 25.0, 0.0, 1.0)
        var angle_factor := clamp(abs(lateral_speed) / 12.0, 0.0, 1.0)
        var gain := drift_boost_gain * max(0.15, speed_factor) * max(0.2, angle_factor) * delta
        drift_score += gain
        _set_boost(boost_amount + gain)

    if Input.is_action_just_pressed("reset_car"):
        reset_to_safe_position()

func _apply_longitudinal_forces(
    delta: float,
    forward: Vector3,
    forward_speed: float,
    throttle: float,
    brake: float
) -> void:
    if throttle > 0.0:
        velocity += forward * acceleration * throttle * delta

    if brake > 0.0:
        if forward_speed > 1.0:
            velocity = velocity.move_toward(Vector3.ZERO, brake_strength * brake * delta)
        else:
            velocity -= forward * reverse_acceleration * brake * delta

func _apply_lateral_grip(delta: float, right: Vector3, lateral_speed: float) -> void:
    var grip := drift_lateral_grip if is_drifting else normal_lateral_grip
    velocity -= right * lateral_speed * min(1.0, grip * delta)

func _apply_steering(delta: float, steer: float, speed: float) -> void:
    if abs(steer) < 0.001 or speed < 0.5:
        return

    var speed_ratio := clamp(speed / max_speed, 0.0, 1.0)
    var authority := lerp(1.0, high_speed_steer_scale, speed_ratio)
    var drift_scale := drift_yaw_multiplier if is_drifting else 1.0
    var direction_sign := sign(velocity.dot(-global_transform.basis.z))
    if direction_sign == 0.0:
        direction_sign = 1.0

    rotate_y(-steer * steering_rate * authority * drift_scale * direction_sign * delta)

func _apply_boost(delta: float, forward: Vector3, wants_boost: bool) -> void:
    if not wants_boost or boost_amount <= 0.0:
        return
    velocity += forward * boost_force * delta
    _set_boost(boost_amount - boost_drain_per_second * delta)

func _update_drift_state(speed: float, steer_amount: float, handbrake: bool) -> void:
    var should_drift := speed >= drift_min_speed and steer_amount >= drift_min_steer and handbrake

    if should_drift and not is_drifting:
        is_drifting = true
        drift_score = 0.0
        drift_started.emit()
    elif not should_drift and is_drifting:
        is_drifting = false
        drift_ended.emit(drift_score)

func _set_boost(value: float) -> void:
    var new_value := clamp(value, 0.0, boost_capacity)
    if is_equal_approx(new_value, boost_amount):
        return
    boost_amount = new_value
    boost_changed.emit(boost_amount, boost_capacity)

func reset_to_safe_position() -> void:
    velocity = Vector3.ZERO
    global_transform = last_safe_transform
    global_position += Vector3.UP * reset_height_offset
