# Godot Starter — Start Here

This folder is a code architecture seed.

## First task

1. Open `project.godot` in a current Godot 4.x editor.
2. Create a large StaticBody3D floor with collision.
3. Add a visible mesh under `Car`.
4. Run the scene.
5. Tune `ArcadeCar` values until basic steering is enjoyable.
6. Build a downhill greybox.
7. Only then add detailed assets.

## Important

The prototype `CharacterBody3D` controller is intentionally simple.

It is appropriate for:
- proving feel;
- iterating quickly;
- building the vertical slice.

It may later be replaced or expanded with:
- suspension visuals;
- raycast wheels;
- more advanced collision;
- surface-specific grip;
- controller rumble;
- traction assists.

Do not replace it merely because it is not a “real” car simulation. Replace it only when a specific desired game feel cannot be achieved cleanly.
