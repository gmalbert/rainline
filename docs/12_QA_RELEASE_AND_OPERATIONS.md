# 12 — QA, Release, and Operations

## Severity

### Blocker
- cannot launch;
- save corruption;
- progression impossible;
- frequent crash;
- input impossible.

### Critical
- major race cannot complete;
- upgrade/economy exploit;
- severe performance on supported hardware.

### Major
- noticeable gameplay/UI defect.

### Minor
- cosmetic/rare issue.

## Test matrix

Windows:
- Windows 11;
- NVIDIA;
- AMD;
- Intel integrated where target supported;
- keyboard;
- Xbox controller;
- PlayStation controller through supported stack.

macOS:
- Apple Silicon;
- Intel if shipping;
- keyboard;
- common Bluetooth controller.

Displays:
- 1920×1080;
- 2560×1440;
- 4K;
- ultrawide if supported;
- high-DPI macOS scaling.

## Core regression run

1. fresh profile;
2. tutorial;
3. start Rainline Run;
4. miss checkpoint;
5. reset;
6. pause;
7. change setting;
8. finish;
9. restart;
10. set PB;
11. exit to garage;
12. buy upgrade;
13. relaunch;
14. verify save.

## Save safety

- atomic write if practical;
- previous save backup;
- schema version;
- migration functions;
- corrupted file recovery.

Never overwrite the only known-good save during migration.

## Build numbering

Example:
`0.4.2+184`

Meaning:
- major.minor.patch;
- CI build number.

Embed:
- commit SHA;
- build timestamp;
- content version;
- handling version.

## Windows release

Public:
- export x86_64;
- code sign;
- package through store or installer;
- test SmartScreen behavior;
- test clean machine.

## macOS release

Public:
- set unique bundle identifier;
- export Universal 2;
- sign;
- notarize;
- staple ticket where applicable;
- test downloaded build on clean Mac.

## Logging

Write rolling log to `user://logs/`.

Include:
- version;
- scene transitions;
- save errors;
- device changes;
- exceptions;
- renderer.

Do not log sensitive user data.

## Support bundle

Add optional “Copy diagnostics” function containing:
- version;
- OS;
- renderer;
- graphics preset;
- log tail;
- controller list.

## Release notes

Every build:
- New
- Changed
- Fixed
- Known issues

Keep technical migration notes separate from player-facing notes.
