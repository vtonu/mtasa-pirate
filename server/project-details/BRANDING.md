# BRANDING

Local settings checked 2026-10-06. Solace may differ.
Shared config is connected to spawn and respawn only.
Paths below start at `server/mods/deathmatch/resources/`.

## COLORS AND FONTS

| Use | Current value | Source |
| --- | --- | --- |
| Play messages | #7FFFD4 | `[gamemodes]/[play]/play/play_messages.lua` |
| Errors / welcome / notices | #FF0000 / #FF69B4 / #FFFA50 | Same file |
| Spawn / respawn | #7FFFD4; default-bold; scale 2 | `[gameplay]/spawn-screen/client.lua`; `[gamemodes]/[play]/play/play_respawn_prompt.lua` |
| Names | White; default-bold; range 30; box 100 x 20 | `[gameplay]/nametags/config.lua` |
| Name health / skull | Full green; low red; skull size 14, gap 4 | Same file |
| Kill names | Name's first #RRGGBB; white fallback | `[gameplay]/killmessages/scripts/client/c.killmessages.lua` |
| Kill feed | default; row 20; gap 5; fallback 5 lines, 10 sec, 1 sec fade | `killmessages/scripts/client/c.ui.lua`; settings can override |
| Speed / nitro | White text; mint nitro; boost RGB 181,234,255 | `[gameplay]/speedometer/client.lua` |
| Weed UI | Share Tech Mono / Orbitron; mint #7FFFD4; amber #FFE66D; red #FF4B6A | `[gameplay]/weed-ui/ui.html` |
| Weed strains | Indica #B88CFF; Sativa #FFE66D; Hybrid #00FF9D | Same file |

Keep current wording. Spawn: `PRESS SPACE TO SPAWN`. Respawn: `PRESS SPACE TO RESPAWN`.
Shop, HUD, mission, marker, and blip details remain in their source files.
CSS overrides and player settings can change the final look.

## VEHICLES

Map defaults: `pirate-map/vehicles_server.lua`.

| Setting | Current rule |
| --- | --- |
| Paint | Black; paintjob models RGB 219,7,47 |
| Aircraft paint slots | 3,0,0 / 217,5,60 / black / black |
| Headlights | RGB 127,255,212 |
| Fixed paintjobs | 534: 0; 536: 2; 575: 1; 483: 0; other supported models random |
| Wheels | Paintjob models: 1080; compatible cars except 411 in x 2095-2190, y 1380-1425: 1085 |
| Remington upgrades | 1086,1124,1180,1179,1010,1100,1127 |
| Sports cars | maxVelocity 350; engineAcceleration 18; dragCoeff 1.2; nitro 1010 |
| Cleanup / respawn | Idle 60 sec; wreck 5 sec; respawn 10 sec |
| Spawn clearance | Ground 30; aircraft 50 |

Map attributes apply before model rules. Stafford and Huntley have red/blue siren rules.
Play, F1, and mission vehicles have separate creation paths; check each before changing defaults.
Map XML owns placed vehicle positions and rotations.

## SHARED CONFIG PLAN

Edit `[gameplay]/pirate-config/config.lua` in VS Code.
Connected keys: `colors.accent`, `fonts.prompt`, `text.spawn`, `text.respawn`,
`ui.prompt.scale`, and `ui.prompt.bottomOffset` (pixels from the bottom).
Color uses RGB plus optional alpha, each 0-255. Scale: 0.1-10. Offset: 0-2000.
Fonts: default, default-bold, clear, arial, sans, pricedown, bankgothic, diploma, beckett.
Invalid values use current defaults. Lua syntax errors must be fixed before starting.

| Group | Settings |
| --- | --- |
| brand | Name, titles, logos |
| colors | accent, text, muted, surface, border, success, warning, danger |
| fonts | Lua fonts/scales; browser fonts/sizes |
| text | Existing labels, prompts, notices, message templates |
| ui | Sizes, gaps, opacity, icons, sounds, display times |
| systems | Spawn, names, kills, HUD, scoreboard, shops, missions, markers, blips |
| vehicles | Paint, headlights, wheels, paintjobs, plates, upgrades; model exceptions |

First keep current values and connect each system. Then merge repeated choices and refine.
Lua and browser UIs both need to read the config. Define startup order, fallbacks,
validation, and restart behavior. Keep secrets and gameplay balance separate.

## SAVE AND APPLY

First install: upload pirate-config and the changed spawn-screen/play files. Run `refresh`,
then `start pirate-config`, `restart spawn-screen`, and `restart play` when ready.
Restarting play can affect active gameplay; do the first install between live tests.
Future edits: save, push, upload config.lua, then `restart pirate-config`.
Both prompts reload their style without a play restart. Confirm this on Solace:
join and spawn; die and respawn; change a style value and restart the config while a prompt is visible.
If the config stops, already running prompts keep their last loaded style.
Other systems are not connected yet. Native HUD and image/model colors may need asset edits.
