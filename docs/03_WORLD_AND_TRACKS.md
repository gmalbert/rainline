# 03 — World and Track Plan

## World strategy

Do not build a seamless open world first.

Build **modular connected districts**. Each event loads one or more district chunks. Later, these chunks can be connected into a free-roam mode if performance and schedule permit.

This gives:
- higher visual density;
- smaller memory footprint;
- faster art iteration;
- easier race scripting;
- fewer empty roads;
- controlled traffic.

## District kit

### 1. Crown Hill Downtown
Visuals:
- steep streets;
- glass office towers;
- parking garages;
- neon storefronts;
- crosswalk reflections.

Driving:
- hairpins;
- elevation changes;
- blind crests.

### 2. Glass Market
Visuals:
- covered market alleys;
- loading zones;
- brick;
- signage;
- tight service lanes.

Driving:
- low speed technical shortcuts.

### 3. Rainline Corridor
Visuals:
- elevated rail;
- tunnels;
- concrete pylons;
- maintenance roads.

Driving:
- fast S bends;
- tunnel acoustics;
- branching underpasses.

### 4. Harborfront
Visuals:
- seawall;
- ferry lights;
- long wet boulevard;
- skyline reflections.

Driving:
- high-speed boost zone.

### 5. Blackwater Docks
Visuals:
- containers;
- cranes;
- warehouses;
- puddles;
- sodium vapor lamps.

Driving:
- jumps;
- gates;
- wide drift corners;
- risky shortcuts.

### 6. Southworks
Visuals:
- rail yards;
- fabrication buildings;
- industrial piping.

Driving:
- mixed-width roads;
- chicanes.

### 7. Beacon Ridge
Visuals:
- residential hillside;
- overlook;
- parks;
- switchbacks.

Driving:
- technical downhill.

### 8. North Cut
Visuals:
- freeway trench;
- retaining walls;
- ramps.

Driving:
- slipstream;
- long sweepers.

### 9. Evergreen Pass
Visuals:
- wet forest;
- rock walls;
- fog;
- mountain lights.

Driving:
- touge-style route;
- guardrails;
- camber.

### 10. Terminal Island
Visuals:
- ferry terminal;
- fuel depot;
- container ship silhouettes.

Driving:
- late-game mixed route and branching.

## Route catalog

| ID | Route | Type | Target time | Primary lesson |
|---|---|---:|---:|---|
| R01 | Rainline Run | Sprint | 2:30 | Core handling |
| R02 | Market Closing | Sprint | 1:50 | Tight shortcuts |
| R03 | Undertrack | Circuit | 3:20 | Rhythm |
| R04 | Blackwater Dash | Sprint | 2:10 | Boost use |
| R05 | Three Bridges | Rival | 3:00 | Pressure |
| R06 | Loading Window | Delivery | 2:40 | Smooth driving |
| R07 | Needle Thread | Sprint | 3:10 | Wet technical |
| R08 | Clean Hands | Rival | 2:50 | Clean line |
| R09 | High Water East | Delivery | 3:30 | Dynamic closure |
| R10 | High Water West | Delivery | 4:00 | Alternate route |
| R11 | North Cut Qualifier | Time Attack | 2:20 | High speed |
| R12 | Equal Rain | Rival | 3:40 | Mastery |
| R13 | Midnight Meridian | Finale | 6:30 | Whole-game exam |

## Rainline Run detailed beat sheet

0:00–0:12
Start under awning/neon. Countdown framed by downtown tower canyon.

0:12–0:35
Uphill false start into immediate crest. Teaches acceleration and steering.

0:35–0:58
First steep descent. Two readable 90-degree bends.

0:58–1:20
Hairpin sequence. Best place to teach drift.

1:20–1:38
Tunnel/undertrack. Audio compresses; boost opportunity.

1:38–1:57
Choice:
- safe boulevard;
- parking garage cut.

1:57–2:18
Waterfront opens visually. Long boost sprint.

2:18–2:35
Dockyard containers. Shortcut gate appears.

2:35–2:45
Final sweeping drift and finish gantry.

## Track readability rules

At race speed, the player should identify the next decision from:
1. road geometry;
2. lighting;
3. barriers;
4. chevrons;
5. signage;
6. HUD arrow only as support.

Never make the minimap the primary navigation method.

Use color/value contrast in-world:
- cool ambient city;
- warm route lamps;
- high-contrast checkpoint emissives.

## Shortcut design rule

Every shortcut must have:
- visible setup cue;
- skill requirement;
- meaningful time gain;
- meaningful failure cost;
- rejoin that does not produce unfair collision.

No hidden wall openings that require memorization from failure.
