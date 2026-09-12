# 14 — Telemetry and Playtesting

## Why telemetry matters

Arcade handling is tuned by observed behavior, not theory alone.

## Local developer telemetry

Record per run:
- event;
- total time;
- checkpoint splits;
- speed samples;
- collisions;
- reset count;
- drift time;
- boost earned/spent;
- route branch;
- restart action.

Output CSV/JSON in development builds.

## Heatmaps

Useful maps:
- crash positions;
- reset positions;
- low-speed zones;
- off-route positions;
- drift initiation.

A crash hotspot can indicate:
- bad handling;
- bad readability;
- geometry snag;
- intentionally difficult corner.

Telemetry cannot tell which by itself.

## Playtest questionnaire

After first 3 runs:
1. Was steering too sensitive, too slow, or about right?
2. Did drift feel intentional?
3. Did you know where to go?
4. Did collisions stop the fun?
5. Did boost feel earned?
6. Which corner was best?
7. Which corner felt unfair?
8. Did you want to restart?
9. What did you think the game wanted you to get better at?

## Vertical slice KPIs

Qualitative:
- handling enjoyment;
- readability;
- sense of speed;
- visual identity.

Behavioral:
- voluntary restarts;
- PB improvement;
- completion;
- reset frequency.

## Tuning experiment method

Change one dimension at a time.

Example:
A: high steering response
B: medium steering response

Do not simultaneously change:
- steering;
- camera;
- grip;
- course geometry.

Otherwise feedback is ambiguous.

## Ghost comparison

Developer ghost should expose:
- delta at checkpoint;
- optional live ghost;
- best sector.

Use ghost opacity option for visibility/accessibility.

## Analytics privacy

If external telemetry is shipped:
- disclose collection;
- minimize identifiers;
- provide opt-out where appropriate;
- do not collect raw personal content.
