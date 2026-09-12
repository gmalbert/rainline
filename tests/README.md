# Rainline Run verification

Run these checks from a clean Godot import before sharing a build:

1. Launch the root project and confirm the title prompt, rainy night lighting, road, and car are visible.
2. From the title card, press `Enter` / RT to open the garage. Verify each vehicle has a rendered preview, select with `A` / `D` or the left stick, start the run, and confirm the chase-view body changes and the choice persists after relaunch.
3. Compare the three selectable handling profiles: Apex S should turn and accelerate most aggressively, Coastline GT should carry the highest speed, and Irontrail X should feel notably planted with a larger boost meter.
4. Confirm the live route map follows the car and advances its cyan checkpoint marker. Cross the two cyan BOOST strips (Harborfront and Blackwater Docks) and verify an immediate speed surge plus feedback. Hold a sustained handbrake drift and verify a DRIFT LINK boost award when it ends.
5. Check sector feedback at checkpoints 3, 6, and 8; each should show a sector time without interrupting the race timer.
3. Start with both keyboard and controller; verify throttle, brake/reverse, steering, drift, boost, reset, and pause.
4. While driving, press `C` / controller X repeatedly. Confirm chase and first-person views switch immediately, the vehicle remains controllable, and the selected view persists after relaunch.
5. Complete all checkpoints in order. Confirm a wrong-order gate does not advance the race.
6. Confirm the checkpoint strip fills one light per valid gate; once a personal best exists, verify the ghost indicator and translucent ghost agree on its recorded time.
7. Finish, verify a medal and result time, press `R`, and complete a faster second run.
8. Restart the project; verify the stored personal best and translucent ghost replay.
9. Replace or corrupt `user://profile.json`; verify the game recovers from `user://profile.backup.json` when available, otherwise starts with a fresh profile without crashing.
10. Profile at 1920×1080 on the target Windows GPU. The showcase target is 60 FPS.
