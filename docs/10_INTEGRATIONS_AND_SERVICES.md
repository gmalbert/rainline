# 10 — Integrations and Services

## Principle

The game must remain playable offline.

Online services are enhancements, not required infrastructure.

## 1. Steam

Potential integrations:
- achievements;
- cloud saves;
- leaderboards;
- rich presence;
- Steam Input;
- build distribution;
- optional Workshop much later.

Recommendation:
implement behind an `OnlineService` interface so non-Steam builds remain functional.

Example API:
```text
submit_time(event_id, time_ms)
unlock_achievement(id)
set_presence(state)
sync_cloud_save()
```

## 2. Leaderboards

Phase 1:
- local best times only.

Phase 2:
- Steam leaderboard.

Phase 3 optional:
- cross-store leaderboard backend.

Security:
Never trust client-submitted times blindly for a serious global leaderboard.
At minimum store:
- event version;
- handling version;
- vehicle;
- checksums / checkpoint splits;
- impossible-time filters.

## 3. Discord

Optional:
- Rich Presence;
- invite link/community surface.

Do not require Discord SDK for core functionality.

## 4. Analytics

Use opt-in/consent-appropriate telemetry.

Useful anonymous events:
- race_started;
- race_finished;
- race_restarted;
- checkpoint_split;
- crash_hotspot;
- assist_changed;
- graphics_preset;
- quit_after_event.

Never collect more than needed.

## 5. Crash reporting

Options:
- Sentry or similar;
- platform-native crash reporting.

Capture:
- game version;
- platform;
- stack trace;
- graphics renderer;
- anonymized hardware class.

## 6. GitHub

Development integration:
- source control;
- issue templates;
- PR checks;
- Actions CI;
- release artifacts;
- changelog generation.

## 7. Blender

Create export presets/scripts:
- validate scale;
- apply transforms;
- export selected collection to GLB;
- naming checks.

## 8. Localization

Keep all player-facing strings in translation resources from the beginning.

Avoid hardcoded UI text.

Potential launch:
- English first;
- architecture ready for localization.

## 9. Platform APIs

### Windows
- native export;
- optional code signing;
- Steam/Epic/GOG depending release.

### macOS
- Universal 2;
- code signing;
- notarization;
- optional Mac App Store later.

## 10. Save cloud strategy

Local canonical save:
`user://profile.json`

Cloud sync should move that save, not create a separate game-state model.

Conflict UI:
- local newer;
- cloud newer;
- choose;
- retain backup.

## 11. Mods

Not launch scope.

If desired later:
- cosmetic decal packs;
- custom time-trial route definitions;
- ghost exchange.

Do not expose arbitrary script execution casually.
