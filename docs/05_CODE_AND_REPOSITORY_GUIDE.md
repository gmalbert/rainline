# 05 — Code and Repository Guide

## Repository layout

```text
/
├── project.godot
├── addons/
├── assets/
│   ├── audio/
│   ├── materials/
│   ├── meshes/
│   ├── textures/
│   └── ui/
├── data/
│   ├── events/
│   ├── upgrades/
│   └── vehicles/
├── scenes/
│   ├── cars/
│   ├── races/
│   ├── world/
│   └── ui/
├── scripts/
│   ├── ai/
│   ├── race/
│   ├── services/
│   ├── ui/
│   └── vehicle/
├── tests/
├── tools/
└── docs/
```

## Style

GDScript:
- `snake_case` functions/variables;
- `PascalCase` classes;
- constants `UPPER_SNAKE_CASE`;
- typed variables when practical;
- one major responsibility per script;
- signals defined near top;
- exported tuning values grouped by category.

## Commenting philosophy

Document:
- why a non-obvious formula exists;
- units;
- tuning assumptions;
- ownership/lifecycle;
- public APIs.

Do not narrate obvious code.

Bad:
```gdscript
speed += 1 # add one to speed
```

Good:
```gdscript
# Steering authority fades with speed so keyboard steering remains controllable
# without making 180 km/h lane changes feel instantaneous.
var steering_scale := lerp(1.0, high_speed_steer_scale, speed_ratio)
```

## Branch model

Small team:
- `main` always playable;
- short-lived feature branches;
- pull requests required;
- tags for milestones.

Suggested labels:
- gameplay
- vehicle
- track
- art
- audio
- ui
- platform
- bug
- performance
- release-blocker

## PR checklist

- Does the build launch?
- Can Rainline Run finish?
- Restart works?
- No new errors in debugger?
- Controller tested?
- Keyboard tested?
- Save migration considered?
- Performance regression?
- New exported parameters documented?
- Assets have source/license metadata?

## Testing

Unit-test pure logic where practical:
- medal thresholds;
- reward calculation;
- save migrations;
- route/checkpoint order;
- boost math.

Integration-test:
- race start → finish;
- wrong checkpoint order;
- restart;
- pause/resume;
- controller disconnect;
- corrupted save fallback.

## Debug tooling to build early

Developer HUD:
- FPS;
- physics time;
- speed;
- slip angle;
- drift state;
- grip multiplier;
- boost;
- current checkpoint;
- AI target speed.

Debug keys:
- teleport to checkpoint;
- reload race;
- toggle rain;
- toggle traffic;
- invulnerability to reset;
- slow motion;
- free camera.

## Error policy

Never silently swallow:
- save failure;
- missing event resource;
- missing checkpoint;
- invalid vehicle spec.

Development builds should fail loudly enough to diagnose.
Shipping builds should show recoverable user messaging where appropriate.
