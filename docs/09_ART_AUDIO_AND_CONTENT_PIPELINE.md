# 09 — Art, Audio, and Content Pipeline

## Visual identity

Keywords:
- wet;
- reflective;
- electric;
- dense;
- Pacific Northwest;
- industrial;
- cinematic;
- readable.

The world should not be uniformly neon. Neon is an accent against:
- dark concrete;
- wet asphalt;
- fog;
- sodium lamps;
- office windows;
- harbor lights.

## Art strategy

### Modular road kit
Pieces:
- straight;
- 15/30/45/90 degree turns;
- intersections;
- slopes;
- crests;
- retaining walls;
- tunnel;
- ramps;
- curb variations.

### Building kit
- podium;
- midrise;
- tower;
- parking structure;
- industrial warehouse;
- residential block;
- storefront frontage.

### Prop kit
- barriers;
- cones;
- dumpsters;
- street lamps;
- signal cabinets;
- bollards;
- bus shelters;
- loading pallets;
- containers;
- utility boxes.

## Blender conventions

- metric units;
- +Y forward or agreed consistent convention;
- transforms applied before export;
- pivots intentionally placed;
- named LOD meshes;
- collision proxies separate;
- material slots minimized.

## glTF / GLB

Use `.glb` where possible for transport from Blender to Godot.

Keep source `.blend` files in source-art storage or repository if size permits; use Git LFS for large binaries.

## Materials

Master materials:
- wet asphalt;
- painted lane;
- concrete;
- glass;
- brick;
- metal;
- painted metal;
- puddle decal;
- neon emissive;
- foliage.

Avoid unique shaders per prop.

## Wet-road illusion

Layer:
- roughness variation;
- reflection probes / screen-space reflection;
- puddle decals;
- specular street lamps;
- tire spray;
- rain streaks;
- subtle road mist.

Do not rely on expensive full-scene real-time reflections.

## Lighting

Race readability takes precedence over realism.

Use:
- landmark lighting;
- warm checkpoint framing;
- emissive route signage;
- tunnel exposure adaptation carefully;
- headlight effect that does not wash out navigation.

## Audio layers

Vehicle:
- engine RPM loop;
- load layer;
- off-throttle;
- gear/transmission cue;
- tire scrub;
- drift squeal;
- wet tire spray;
- collision body;
- boost.

World:
- rain;
- tunnel reverb;
- distant traffic;
- harbor horn;
- elevated train;
- industrial hum;
- wind.

UI:
- countdown;
- checkpoint;
- medal;
- reward;
- menu movement.

## Music direction

Electronic music with Pacific Northwest nocturnal texture:
- synthwave influence without parody;
- breaks;
- garage;
- downtempo interludes;
- drum and bass for late races;
- instrumental indie-electronic.

Use original or properly licensed tracks.

Adaptive music:
- intro layer during countdown;
- full beat at GO;
- intensity layer during boost/final sector;
- low-pass in pause;
- victory sting at finish.

## Audio middleware

Start with Godot AudioStreamPlayer buses.

Only integrate FMOD/Wwise if the project demonstrably needs:
- advanced adaptive music;
- complex parameterized engine synthesis;
- large audio team workflow.

Middleware adds build and licensing complexity.

## Content naming

Example:
```text
road_downtown_corner_90_a.glb
prop_barrier_plastic_a.glb
mat_asphalt_wet_01.tres
sfx_car_tire_drift_loop_01.wav
music_rainline_run_mix_01.ogg
```
