# 08 — UI, UX, and Accessibility

## UX goals

The player should spend more time driving than navigating menus.

Primary flow:
```text
Title → Continue → Garage → Event → Race → Results → Retry/Next
```

## HUD

Required:
- speed;
- boost;
- race time;
- checkpoint/lap;
- opponent gap or target delta;
- minimap/route strip;
- position where applicable.

Optional:
- drift score;
- split delta;
- objective status.

HUD should be readable at 1080p from couch distance.

## Results screen

Show:
- finish time;
- medal;
- personal-best delta;
- best sector;
- rewards;
- optional objective;
- `RESTART` as first/highlighted action.

Restart should require one button and load quickly.

## Garage

Tabs:
- Drive
- Car
- Tune
- Style
- Records

Do not build a fake 3D walking garage.

## Accessibility

At minimum:
- full remapping;
- controller and keyboard navigation;
- subtitle controls;
- UI scale;
- colorblind-safe route cues;
- motion blur toggle;
- camera shake slider;
- FOV options where feasible;
- headlight/rain flash intensity option;
- audio channel sliders;
- hold/toggle options;
- automatic steering stabilization;
- drift assist;
- brake assist;
- route guidance strength;
- difficulty independent from assists.

## Motion sensitivity

Options:
- boost FOV effect 0–100%;
- camera roll 0–100%;
- drift camera lag 0–100%;
- impact shake 0–100%;
- disable chromatic aberration;
- disable motion blur.

## Pause

Pause must:
- stop gameplay;
- preserve race state;
- expose restart;
- expose accessibility/settings.

## Failure state

Do not require a loading screen after missing a turn.

Offer:
- quick reset to route;
- rewind if enabled;
- continue with time loss.

## Controller disconnect

Pause safely and display:
“Controller disconnected. Reconnect or press a keyboard key to continue.”
