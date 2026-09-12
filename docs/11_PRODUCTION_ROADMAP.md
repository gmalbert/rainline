# 11 — Production Roadmap

## Team assumptions

Roadmap supports:
- solo developer with contractors, or
- small team of 2–6.

Time ranges are phase gates, not promises.

## Phase 0 — Project foundation

Deliverables:
- repository;
- Godot project;
- input map;
- test scene;
- coding conventions;
- issue tracker;
- build/version scheme.

Exit criteria:
- Windows and macOS development builds launch.

## Phase 1 — Handling prototype

Build:
- one primitive car;
- flat test course;
- throttle/brake/reverse;
- steering;
- chase camera;
- drift;
- boost;
- reset.

No detailed city art.

Exit criteria:
- driving is fun for 10 minutes in a featureless space.

## Phase 2 — Rainline Run greybox

Build:
- full 2–3 minute route;
- checkpoints;
- countdown;
- finish;
- results;
- restart;
- timing;
- personal best;
- greybox lighting.

Exit criteria:
- complete replay loop;
- no progression required.

## Phase 3 — Vertical slice

Add:
- polished wet-road art;
- downtown + waterfront modular kit;
- rain;
- audio;
- HUD;
- one rival or gold ghost;
- basic garage;
- one story intro/outro;
- settings;
- accessibility baseline.

Exit criteria:
- build can be shown publicly;
- stable 60 FPS target;
- representative final quality.

## Phase 4 — Systems production

Parallel tracks:

Gameplay:
- upgrade system;
- AI personalities;
- traffic;
- event types;
- career progression.

Content:
- districts 2–5;
- vehicles;
- props;
- story scenes.

Platform:
- save system;
- achievements;
- cloud;
- CI exports.

Exit criteria:
- full game loop works with placeholder content.

## Phase 5 — Content alpha

All campaign events exist in playable form.

Definition of alpha:
- story start to finish;
- all routes;
- all required vehicles;
- all upgrades;
- all menus;
- saves survive normal use.

Art/audio can still be incomplete.

## Phase 6 — Beta

Focus:
- polish;
- bug fixing;
- optimization;
- difficulty;
- economy;
- accessibility;
- localization;
- controller matrix;
- platform signing.

Content lock near end.

## Phase 7 — Release candidate

Checklist:
- no known blockers;
- clean install tested;
- clean uninstall tested;
- save upgrade tested;
- achievements tested;
- offline tested;
- Steam offline mode tested if applicable;
- macOS notarization validated;
- Windows signing validated;
- credits/licenses complete.

## Phase 8 — Launch

Launch priorities:
1. crash/hang fixes;
2. save corruption;
3. progression blockers;
4. input bugs;
5. severe performance;
6. leaderboard integrity;
7. balance.

## Phase 9 — Postlaunch

Free updates:
- new Rainline trials;
- ghosts;
- reverse routes;
- weather variants.

Paid expansion only if justified:
- new district;
- new story chapter;
- new car set.

Avoid fragmenting leaderboards with pay-to-win vehicles.

## Milestone table

| Milestone | Product proof |
|---|---|
| P0 | Car moves |
| P1 | Car is fun |
| P2 | Race is replayable |
| VS | Game looks real |
| Alpha | Campaign complete |
| Beta | Game stable |
| RC | Ship-ready |
| 1.0 | Public release |

## Scope kill order

If schedule slips, cut in this order:
1. free roam;
2. cockpit interiors;
3. advanced traffic;
4. extra vehicles;
5. photo mode;
6. online cross-platform leaderboards;
7. weather variants;
8. secondary story events.

Do not cut:
- handling quality;
- Rainline Run quality;
- fast restart;
- readable routes;
- stable save;
- accessibility basics.
