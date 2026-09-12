# 06 — Vehicle Handling and Balance

## Goal

The car should feel heroic, not realistic.

The player is controlling the *idea* of a fast street car:
- responsive;
- heavy enough to feel planted;
- loose enough to drift;
- stable enough that a small input error does not cause a spin.

## Suggested baseline units

Godot physics uses meters.

Initial tuning target:
- 0–100 km/h: ~5.5 s
- top speed: ~210 km/h
- boost top speed: ~235 km/h
- comfortable drift entry: 55–120 km/h

## Steering curve

At low speed:
- high steering authority.

At high speed:
- reduced steering angle;
- stronger yaw damping.

Suggested conceptual curve:
```text
steer_authority = lerp(1.0, 0.45, smoothstep(20 m/s, 55 m/s, speed))
```

## Grip

Use lateral velocity damping rather than real tire force modeling for first playable.

Pseudo:
```text
lateral_velocity = velocity projected on local X axis
correction = -lateral_velocity * grip
```

During drift:
- reduce grip;
- add controlled yaw;
- retain forward velocity.

## Drift quality score

Every physics frame while drifting:

```text
angle_factor = normalized(abs(slip_angle), min_angle, ideal_angle)
speed_factor = normalized(speed, min_speed, target_speed)
proximity_factor = optional wall/traffic bonus
frame_score = angle_factor * speed_factor * proximity_factor * delta
```

A drift chain breaks when:
- speed too low;
- direction reverses unexpectedly;
- collision exceeds threshold;
- car straightens longer than grace period.

## Boost gain

Drift should fill meter more quickly for:
- sustained angle;
- higher speed;
- clean exit.

Avoid rewarding donuts in place.

Therefore boost gain must include meaningful forward speed and route progress.

## Rubber-banding

Prefer light dynamic pace adjustment, not teleporting AI.

Allowed:
- AI target speed ±3–5%;
- fewer mistakes when far behind;
- more conservative behavior when ahead.

Never:
- hidden player slowdown;
- impossible AI acceleration;
- AI clipping through traffic.

## Upgrade balance philosophy

An upgrade should change feel, not simply make every stat larger.

Examples:
### Street Grip Tires
+ lateral grip
+ clean corner exit
- drift boost generation

### Rain Tires
+ wet stability
+ braking consistency
- dry top speed slightly

### Slide Kit
+ drift initiation
+ drift chain forgiveness
- straight-line stability

## Tuning workflow

1. Flat skidpad.
2. Slalom.
3. Hairpin.
4. High-speed sweeper.
5. Rainline Run full route.
6. Keyboard.
7. Controller.
8. 30 FPS stress test.
9. 60+ FPS test.

Never tune only on a single input device.
