# BRANDING

Local settings checked 2026-10-06. Solace may differ.
Shared config is connected to spawn and respawn only.
Paths below start at `server/mods/deathmatch/resources/`.

## COLORS AND FONTS

| Use | Value |
| --- | --- |
| Normal messages, accents, markers, interiors, money, full health, Hybrid | #7FFFD4 |
| Warnings, errors, red indicators, low health | #EE1426 |
| Yellow/orange indicators, Sativa, both Truth markers | #FFE66D |
| Indica | #B88CFF |
| Notification messages | #FFE66D |
| Spooky weather warning | #EE1426 |
| Scoreboard | Original fonts/colors and saved player settings; only money is mint |
| Text, panels, borders, shadows | White, black, gray; opacity can vary |
| Normal in-game UI, missions, names, kill feed, speedometer | unifont |
| Spawn and respawn | default-bold; scale 2; mint |
| Browser UI | Existing Share Tech Mono / Orbitron fonts |

All map markers are mint except `ammuNationSpecialClerkMarker`, which is yellow.
The pirate-ship Truth shop marker in `play_bootyLoot.lua` is also yellow.
Infernus paint and headlights are mint for play, map, and F1 spawns.
Player-chosen name/vehicle colors and native game icons keep their own colors.
Other vehicle paint and red/blue sirens keep their existing styles.

Keep current wording. Spawn: `PRESS 'SPACE' TO SPAWN`. Respawn: `PRESS 'SPACE' TO RESPAWN`.
Shop, HUD, mission, marker, and blip details remain in their source files.
CSS overrides and player settings can change the final look.
Scoreboard team/perk colors keep their original values.
H prompts use `PRESS 'H' TO START` or `PRESS 'H' TO OPEN SHOP`.
Enter, exit, and parachute prompts also quote 'H'. Prompts hide while a request
is pending; Emmet's response replaces the start prompt.
F1 shows the active perk countdown, for example `PERKS: Sativa (03:22)`.

## VEHICLES

Map defaults: `pirate-map/vehicles_server.lua`.

| Setting              | Current rule                                                                        |
| -------------------- | ----------------------------------------------------------------------------------- |
| Paint                | Black; paintjob models RGB 219,7,47                                                 |
| Aircraft paint slots | 3,0,0 / 217,5,60 / black / black                                                    |
| Headlights           | RGB 127,255,212                                                                     |
| Fixed paintjobs      | 534: 0; 536: 2; 575: 1; 483: 0; other supported models random                       |
| Wheels               | Paintjob models: 1080; compatible cars except 411 in x 2095-2190, y 1380-1425: 1085 |
| Remington upgrades   | 1086,1124,1180,1179,1010,1100,1127                                                  |
| Sports cars          | maxVelocity 350; engineAcceleration 18; dragCoeff 1.1; nitro 1010                   |
| Cleanup / respawn    | Idle 60 sec; wreck 5 sec; respawn 10 sec                                            |
| Spawn clearance      | Ground 30; aircraft 50                                                              |

Map attributes apply before model rules. Stafford and Huntley have red/blue siren rules.
Play, F1, and mission vehicles have separate creation paths; check each before changing defaults.
Map XML owns placed vehicle positions and rotations.

## EDIT AND APPLY

Edit this guide and ask for the changes to be applied to game files.
Only spawn and respawn read `[gameplay]/pirate-config/config.lua` directly.
Save and upload that config, then run `restart pirate-config` for prompt-only edits.

For this palette update, upload the changed resource files and restart the server
between live tests. Check the scoreboard, both Truth shops, Ammu-Nation doors and
counters, Emmet prompts, weed strains, warnings, and each Infernus spawn.
Source checks do not replace the Solace test. Native HUD and image/model colors
may need separate asset edits.
