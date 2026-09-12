# 01 — Game Design Document

## 1. High concept

**Seattle After Dark** is a compact single-player arcade racing game about earning a place in an underground nighttime racing network called **The Rainline**.

Players race through a Seattle-inspired city of steep downtown streets, wet waterfront avenues, ferry approaches, industrial yards, tunnels, elevated infrastructure, forested outskirts, and sodium-lit mountain roads.

The game emphasizes:
1. momentum over simulation;
2. readable high-speed routes;
3. drift as a deliberate tactical tool;
4. risk/reward shortcuts;
5. fast restarts and mastery;
6. strong sense of place.

## 2. Player fantasy

The player should routinely feel:
- “I barely held that corner.”
- “I know where I lost two seconds.”
- “That shortcut was reckless and it worked.”
- “The rain makes this city look incredible.”
- “I can beat that ghost.”
- “One more run.”

## 3. Audience

Primary:
- players who enjoyed Burnout, Need for Speed Underground-era games, Ridge Racer, Split/Second, Midnight Club, OutRun 2006, or Horizon arcade driving;
- players who like compact mastery loops rather than hundred-hour open worlds.

Secondary:
- time-trial players;
- controller-first PC players;
- Steam Deck/handheld PC users if performance permits.

## 4. Core loop

**Garage → choose event → race → earn Rep/Credits → unlock parts/cosmetics/routes → tune car → retry or advance**

Moment-to-moment:
**accelerate → read route → set up corner → brake/flick → drift → exit cleanly → spend boost → choose safe line or shortcut**

## 5. Controls

Default controller:
- RT / R2: throttle
- LT / L2: brake / reverse
- Left stick: steer
- A / Cross: handbrake/drift modifier
- B / Circle: boost
- X / Square: look back
- Y / Triangle: camera
- D-pad: quick music / HUD functions
- Menu: pause

Keyboard:
- W/S throttle/brake
- A/D steer
- Space handbrake
- Shift boost
- C camera
- R reset
- Esc pause

All bindings must be remappable.

## 6. Vehicle classes

Launch scope: one broad street-performance class with meaningful builds rather than many simulation classes.

Archetypes:
- **Grip** — stable, high corner exit speed.
- **Drift** — easier yaw initiation, higher drift boost generation.
- **Sprint** — top speed and boost efficiency.
- **Balanced** — forgiving default.

Later vehicles can differ by:
- mass;
- wheelbase feel;
- steering response;
- acceleration;
- top speed;
- lateral grip;
- drift stability;
- boost capacity.

Avoid licensed real-world vehicles unless budget/licensing explicitly supports them.

## 7. Driving model

The handling model should be authored rather than simulated.

### Normal state
- strong forward acceleration;
- speed-sensitive steering;
- mild traction loss;
- generous collision recovery;
- subtle downforce/stability assist.

### Drift state
A drift begins when:
- speed exceeds minimum threshold;
- player applies steering above threshold;
- handbrake or brake-flick condition occurs.

While drifting:
- rear grip reduces;
- yaw response increases;
- car receives stabilizing counter-force;
- player retains strong steering authority;
- drift score/boost charge rises based on angle, speed, duration, and proximity.

Drift must be:
- easy to start;
- hard to optimize;
- difficult to spin accidentally.

## 8. Boost

Boost is earned, not passively regenerated.

Sources:
- sustained drift;
- near miss;
- clean sector;
- shortcut completion;
- slipstream;
- perfect launch;
- optional destructible gate/skill object.

Boost effect:
- temporary acceleration multiplier;
- higher top-speed cap;
- FOV kick;
- intensified engine/audio mix;
- rain streak enhancement;
- taillight/neon trail treatment.

Prevent boost spam with a meter divided into 2–3 segments.

## 9. Collision philosophy

Collisions should punish time, not fun.

- walls scrub speed;
- shallow wall contacts can become “scrapes” rather than full stops;
- head-on collisions produce a strong penalty but fast recovery;
- traffic impacts should avoid long physics chaos;
- optional auto-reset after vehicle becomes stuck.

## 10. Race types

### Sprint
Point-to-point. Signature mode.

### Circuit
2–4 laps around a compact route.

### Rival
One-on-one story duel.

### Time Attack
Beat bronze/silver/gold developer times.

### Rainline Trial
Technical drift/route challenge.

### Pursuit Run
Reach extraction before a countdown, with roadblocks/traffic pressure rather than weaponized police combat.

### Delivery
Maintain cargo integrity while racing a deadline.

### Crew Relay
Story event with vehicle or route handoff between narrative characters.

## 11. Progression

Two currencies:

### Rep
Narrative/progression reputation.
Earned from:
- placements;
- target times;
- optional objectives;
- crew challenges.

### Credits
Used for:
- performance packages;
- visual customization;
- garage expansion;
- alternate vehicles.

No purchasable real-money currency.

## 12. Upgrade structure

Performance should use packages rather than granular simulation parts at first.

Categories:
- Engine
- Drivetrain
- Tires
- Suspension
- Brakes
- Boost system

Each has 3–4 tiers plus sidegrades.

Example:
**Tires II**
- Street Grip: +grip, -drift generation
- Rain Compound: +wet stability
- Slide Compound: +drift initiation, -straight stability

## 13. Difficulty

Separate:
- AI difficulty;
- handling assists.

Assists:
- steering stabilization;
- brake assist;
- drift assist;
- route arrows;
- rewind (optional accessibility feature);
- collision recovery strength.

AI difficulty changes pace and mistake frequency, not hidden horsepower.

## 14. Session rhythm

Ideal:
- 2–5 minute events;
- <10 seconds from finish screen to restart;
- <20 seconds from garage to active driving;
- 20–40 minute story chapters;
- 8–12 hour first campaign target;
- longer for mastery, medals, unlocks, ghosts.

## 15. Definition of “fun enough to continue”

Vertical slice should not advance to full production until:
- 80%+ testers rate handling 4/5 or better;
- median tester restarts Rainline Run voluntarily at least twice;
- no common corner feels random;
- controller latency feels immediate;
- 60 FPS target is maintained on target hardware;
- route is understandable at speed without constant minimap dependence.
