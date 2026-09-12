# 07 — AI, Ghosts, and Traffic

## Development order

1. Player car feels good.
2. Ghost replay.
3. Spline rival AI.
4. Traffic.
5. Multi-rival races.

A ghost is lower-risk than full AI and gives immediate competitive value.

## Ghost system

Record at 20–30 Hz:
- timestamp;
- position;
- rotation;
- optional wheel/steering visual state.

Playback:
- find samples around current race time;
- interpolate transform;
- disable collision.

Store:
- local personal best;
- developer gold ghost;
- story-character ghosts.

Ghost file header:
```json
{
  "version": 1,
  "event_id": "rainline_run",
  "vehicle_id": "nightshift_01",
  "time_ms": 143882,
  "physics_version": "handling_v3"
}
```

Invalidate or label old ghosts when handling changes materially.

## Rival AI

Route is authored as racing-line nodes.

Node metadata:
- target speed;
- lane width;
- overtake allowed;
- drift preferred;
- braking point;
- hazard weight;
- shortcut branch.

AI loop:
1. choose look-ahead target;
2. compute steering;
3. compare speed to target;
4. throttle/brake;
5. optional recovery behavior.

Mistakes are authored probabilistically:
- brake late;
- wide exit;
- conservative shortcut;
- minor wall scrape.

## AI personality

### Mara
- fastest clean line;
- low mistake rate;
- rarely takes desperate shortcut.

### Luis
- aggressive;
- shortcut-heavy;
- wider drift angle.

### Sora
- precise;
- consistent sectors;
- low collision.

### Jules
- adaptive;
- unusual route branches.

## Traffic

Traffic is a moving obstacle layer, not a city simulation.

Rules:
- spawn ahead, not visibly;
- despawn behind;
- simple lane splines;
- low counts;
- prevent impossible roadblocks;
- deterministic seed for leaderboard events where fairness matters.

## Fairness

For competitive time attack:
- use static traffic layout or no traffic;
- use deterministic weather;
- same shortcut state.

For story races:
- controlled variability is acceptable.

## Recovery

AI recovery states:
- normal;
- stuck;
- reverse;
- reset.

If AI is off-route for N seconds:
- fade/teleport only when off-camera if possible;
- apply time penalty so reset is not advantageous.
