# 04 — Technical Architecture

## Architecture goals

- one cross-platform project;
- deterministic-enough race systems for ghosts;
- data-driven events;
- clean separation between vehicle, race rules, presentation, save data, and online services;
- easy replacement of placeholder art;
- testable systems.

## Top-level scene tree

```text
GameRoot
├── Services
│   ├── SaveService
│   ├── AudioService
│   ├── SettingsService
│   ├── TelemetryService
│   └── OnlineService
├── World
│   ├── Environment
│   ├── Track
│   ├── Traffic
│   └── Props
├── Race
│   ├── RaceManager
│   ├── Checkpoints
│   ├── Opponents
│   └── GhostManager
├── Player
│   ├── Vehicle
│   └── Cameras
└── UI
    ├── HUD
    ├── Pause
    └── Results
```

## Autoload candidates

Keep autoloads limited:
- `SaveService`
- `SettingsService`
- `AudioService`
- `SceneRouter`

Avoid turning every system into a singleton.

## Data model

Use Godot `Resource` classes for authored game data.

### VehicleSpec
Fields:
- id
- display_name
- mass
- engine_force
- max_speed
- steering_strength
- grip
- drift_grip
- drift_yaw
- boost_force
- boost_capacity

### RaceEvent
Fields:
- id
- title
- scene_path
- event_type
- target_times
- opponents
- weather_profile
- rewards
- story_gate
- modifiers

### UpgradeSpec
Fields:
- id
- category
- tier
- cost
- stat_modifiers
- compatibility

## Runtime layers

### Input
Transforms device input into normalized driving intentions.

### Vehicle controller
Consumes:
- throttle
- brake
- steering
- handbrake
- boost

Produces:
- vehicle movement;
- drift state;
- speed;
- boost usage;
- collision events.

### Race manager
Owns:
- countdown;
- race clock;
- checkpoint progression;
- lap progression;
- finish state;
- result calculation.

### Ghost system
Samples:
- transform;
- velocity if needed;
- animation state.

Do not attempt full deterministic physics replay initially. Store sampled transforms and interpolate them.

### UI
Subscribes to signals. It should not own gameplay state.

## Signals

Examples:
```text
vehicle.drift_started
vehicle.drift_ended(score)
vehicle.boost_changed(value, max_value)
race.countdown_changed(value)
race.checkpoint_reached(index)
race.finished(result)
ghost.new_personal_best()
```

## Scene ownership rule

A parent owns the lifecycle of its children.

Examples:
- Race scene instantiates Player.
- RaceManager does not search arbitrary scene nodes every frame.
- Vehicle does not directly manipulate HUD labels.

## Save format

Use versioned JSON for player/profile data.

Example:
```json
{
  "schema_version": 1,
  "profile": {
    "credits": 4200,
    "rep": 875
  },
  "unlocks": ["rainline_run", "market_closing"],
  "best_times_ms": {
    "rainline_run": 143882
  }
}
```

Use Godot `user://` path. Never write relative to the application directory.

## Performance target

Baseline target:
- 1920×1080
- 60 FPS
- midrange discrete GPU
- scalable presets for integrated/older GPUs.

CPU budget:
- physics 60 Hz;
- no per-frame global node searches;
- traffic pooled;
- occlusion/frustum-friendly modular city.

GPU budget:
- reflective wet-road look without expensive true planar reflection everywhere;
- screen-space/reflection probes used selectively;
- rain particles aggressively LODed;
- emissive signage atlas.

## Physics tick

Recommended:
- physics: 60 Hz;
- rendering uncapped or vsync-controlled;
- ghost sampling: 20–30 Hz;
- UI updates: event-driven where practical.

## Platform exports

### Windows
- x86_64 primary.
- signed executable for public distribution.
- portable dev builds acceptable internally.

### macOS
- Universal 2 when using official templates.
- signed/notarized public build strongly recommended.
- test on both Apple Silicon and Intel only if Intel support remains a shipping requirement.

## CI

GitHub Actions:
1. lint/check scripts;
2. import project headlessly;
3. run unit/integration tests;
4. build Windows artifact;
5. build macOS artifact where signing strategy permits;
6. publish artifacts for tagged builds.

Secrets:
- signing certificates;
- notarization credentials;
- platform SDK tokens;
- backend keys.

Never commit secrets.
