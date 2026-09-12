# Release Notes — Seattle After Dark: Rainline Run

## v0.5.0 showcase build

**Status:** review build
**Date:** 2026-09-11
**Scope:** playable vertical slice and supporting design package

### Summary

Rainline Run is now a self-contained, replayable downhill time-attack showcase. The build opens with a visual garage, lets the player choose between three differently tuned vehicles, and carries that choice into a complete Rainline Run event with ten ordered checkpoints, sector feedback, boost surfaces, drift rewards, a result card, a personal-best ghost, and local persistence.

This is a vertical-slice milestone rather than a 1.0 release. It proves the handling, route readability, wet-night presentation, retry loop, and save/ghost foundations for Seattle After Dark. It does not yet include a campaign, traffic, rival AI, upgrades, online leaderboards, or multiple events.

## Highlights

### Route and event

- Reworked the showcase route into clearer city beats: Pike Market Descent, Harborfront Sweeper, Blackwater Chicane, tunnel and overpass sections, and the Rainline finish arch.
- Added ten ordered checkpoints with a visible completion strip and route minimap.
- Added split feedback at the authored sector points without stopping or resetting the race clock.
- Added two cyan track boost strips at Harborfront and Blackwater Docks.
- Added road decals before key bends so route guidance remains readable without a large center-screen navigation arrow.
- Added route recovery when the car leaves the driving corridor or remains stuck against world geometry.

### Garage and vehicles

- Added a garage screen with rendered vehicle cards and persistent selection.
- Added three selectable vehicle profiles:
  - **Apex S:** high acceleration and grip for technical driving.
  - **Coastline GT:** the highest top speed for long waterfront sections.
  - **Irontrail X:** the most planted handling and largest boost reserve.
- Added distinct vehicle meshes, preview art, descriptions, stat summaries, and runtime tuning.
- Added chase-view presentation details including wheel motion, brake lights, boost exhaust, and wet-road spray.

### Driving loop

- Added arcade throttle, brake/reverse, steering, handbrake drift, boost, collision scrub, and speed feedback.
- Added a drift-link reward that returns boost after a sustained drift.
- Added boost camera feedback, with a comfort-camera option to disable FOV expansion.
- Added reset-to-safe-position behavior at the last authored recovery point.
- Added immediate retry from the result card.

### Ghosts and saves

- Added local best-time storage for the Rainline Run event.
- Added best-run ghost recording and translucent replay.
- Added handling-version compatibility checks so stale ghosts are not replayed against changed physics.
- Added versioned profile data with a backup file and fallback to a fresh default profile when both files are unavailable or invalid.
- Persisted the selected vehicle, camera mode, comfort-camera setting, graphics preset, best time, and ghost data.

### Presentation and usability

- Added rainy night lighting, fog, glow, wet streetscape materials, landmarks, storefront dressing, and finish lighting.
- Added chase and first-person camera modes with persistence.
- Added Showcase and Performance graphics presets.
- Added audio mute control and lightweight engine, drift, boost, collision, countdown, and tunnel context feedback.
- Added HUD feedback for speed, time, checkpoint progress, route distance, sector splits, ghost comparison, boost amount, and sampled performance counters.

### Documentation and repository hygiene

- Expanded the root README into a player, contributor, architecture, asset-pipeline, save-data, troubleshooting, and verification guide.
- Added this build-specific release note.
- Updated the root ignore rules to exclude local virtual environments, Python cache files, Godot import output, Blender `.blend1` backups, and temporary capture output.
- Preserved the design package covering product direction, story, tracks, architecture, handling, AI/ghosts/traffic, accessibility, content production, integrations, roadmap, QA, telemetry, and community planning.

## Controls

| Action | Keyboard | Controller |
| --- | --- | --- |
| Start / confirm | `Enter` | Right trigger / confirm |
| Throttle | `W` | Right trigger |
| Brake / reverse | `S` | Left trigger |
| Steer | `A` / `D` | Left stick |
| Drift | `Space` | `A` button |
| Boost | `Shift` | `B` button |
| Reset / retry | `R` | `Y` button |
| Pause | `Esc` | Menu / Start |
| Camera | `C` | `X` button |
| Mute | `M` | — |
| Comfort camera | `F` | — |
| Graphics preset | `V` | — |

See [README.md](README.md) for the complete player and contributor guide.

## Event targets

The authored `rainline_run` event currently uses these medal thresholds:

| Medal | Target |
| --- | ---: |
| Gold | 2:35.000 |
| Silver | 3:00.000 |
| Bronze | 3:30.000 |

The thresholds are part of the event resource and may be retuned as route length, handling, and performance are iterated.

## Verification status

The intended review pass is documented in [tests/README.md](tests/README.md). It covers:

- clean launch and rainy title presentation;
- garage previews, vehicle selection, and profile persistence;
- keyboard and controller driving;
- camera switching and comfort mode;
- checkpoint order and HUD progress;
- boost strips and drift-link rewards;
- sector feedback and result medals;
- personal-best ghost recording and replay;
- save backup and corruption recovery;
- 1920×1080 performance inspection.

This repository does not currently contain an automated test runner. The build should be reviewed in a clean Godot import using the manual checklist before it is shared as a playable artifact.

## Known limitations

- Only one event is playable.
- Traffic, rival AI, campaign progression, upgrades, economy, story scenes, and online services are not implemented.
- The route and much of the city are runtime-built showcase geometry; this is not a complete open-world environment.
- There is no finalized Windows or macOS export artifact, signing, notarization, installer, or store metadata in this repository state.
- The target performance profile is a development goal and still needs a hardware matrix pass.
- Audio is generated/lightweight showcase feedback rather than a final soundtrack or production mix.
- Accessibility and input remapping are foundations for future work, not a complete shipping accessibility menu.
- A project license, complete third-party attribution record, and commercial distribution checklist still need to be added before public release.

## Upgrade and compatibility notes

- The current profile schema is version `2`.
- Ghosts are tied to handling version `rainline_v1`.
- A future handling change should either migrate/clear incompatible ghost data or increment the handling version intentionally.
- Save data lives in Godot's per-user `user://` directory and is not stored in the repository.
- Godot `.import` files and editor caches are generated locally and should not be used as release inputs.

## Next recommended work

1. Add automated tests for medal thresholds, checkpoint order, drift/boost math, and save fallback.
2. Establish a reproducible headless import and export check for CI.
3. Capture a hardware performance matrix for Forward+ and Compatibility.
4. Formalize asset attribution, project licensing, and export/signing metadata.
5. Extend the single-event loop only after handling and route readability remain stable.
