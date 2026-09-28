# Project Details (mtasa-pirate v1.2.3)

<img width="1280" height="720" alt="1" src="https://github.com/user-attachments/assets/5a245b9f-1597-4cc4-826b-91315d174452" />

## Purpose

- Personal freeroam MTA:SA server focused on experimentation, content creation, and multiplayer gameplay with friends. Public release is optional if development reaches a stable state.

## Gameplay

- Custom pirate map in Las Venturas, with the time held near 3 AM.
- Weather switches between 18 and 9 every three minutes. Weather 9 starts the storm infected event.
- New players spawn near Caligula's Palace. After death, players return to the nearest of six spawn points.
- The respawn prompt appears after five seconds. Press Space to respawn, or wait one minute after the prompt for automatic respawn.
- Passive mode is enabled on spawn and can be changed in F1. It blocks combat and changes player and vehicle collisions. Infected do not target passive players.
- Placed vehicles have cleanup and replacement rules. Health, armor, and Loco skull pickups respawn after use.
- Players drop their weapons and ammo on death. Unclaimed drops expire after 60 seconds.
- The scoreboard shows Money, Team, and K/D. Team shows the active weed perk or N/A. Kills include players and storm infected.

## Missions and Shops

### Loco Skull Mission

1. Collect the Loco skull to receive Molotovs and ten seconds of mission access.
2. Enter the mission marker on the pirate ship to start a three-minute session.
3. Destroy each marked vehicle to earn $15,000 and one Loco point. A new target follows until the session ends.
4. When the timer expires, wait through the 30-second cooldown and collect the skull again.

### Airyard Route

1. Press H at the ship capsule to start the route and mark the Rustler loot box.
2. Reach the loot box on foot and press H to equip a parachute.
3. A black Hunter spawns at the Emerald Isle rooftop, with a radar blip attached to it.

The Hunter blip clears when the Hunter is destroyed. Death resets the player's route and removes their tracked Hunter. Automatic Hunter replacement is not currently wired up.

### Booty Desk

- Press F6 at the desk to open the weapon shop.
- The server handles prices, money checks, and weapon grants.

### Fog of War Garden

- Press F5 at the garden to choose a strain and package.
- Indica favors armor regeneration and higher gravity.
- Sativa gives balanced health and armor regeneration with normal gravity.
- Hybrid favors health regeneration and lower gravity.
- Each type also sets a walking style. Perks expire after 5, 10, 20, or 30 minutes, based on the package, and clear on death.
- HARVEST gives spray-can ammo. It is not a crop-growing or cash-reward system.

### Storm Infected

- Weather 9 enables infected spawning and pursuit, with a red warning when the storm starts.
- Infected use varied movement and melee weapons. Spawn checks use nearby ground and building surfaces.
- Infected pause outside the storm. Cleanup removes distant or stuck chasers.

## Controls

| Key   | Action                                                                   |
| ----- | ------------------------------------------------------------------------ |
| F1    | Player options, perk and mode display, vehicle options, and passive mode |
| F5    | Garden shop while at the garden                                          |
| F6    | Weapon shop while at the Booty Desk                                      |
| H     | Start Airyard at the capsule or equip the parachute at the loot box      |
| Space | Respawn while the death prompt is shown                                  |

F1 includes vehicle repair, flip, upgrades, colors, and paintjobs. Rustler bombing uses the vehicle fire control.

## Main Files

Custom resources are under `server/mods/deathmatch/resources/`. Startup resources are listed in `server/mods/deathmatch/mtaserver.conf`.

### Play Gamemode

`[gamemodes]/[play]/play/` contains the main server logic:

| File                      | Role                                                       |
| ------------------------- | ---------------------------------------------------------- |
| `meta.xml`                | Loads scripts and supporting resources                     |
| `play.lua`                | Starts the gamemode and connects events                    |
| `play_config.lua`         | Spawn points, placed vehicles, pickups, and world settings |
| `play_world.lua`          | Time, weather, explosions, and safe-zone support           |
| `play_messages.lua`       | Shared messages, colors, and timed notices                 |
| `play_players.lua`        | Joining, spawning, respawning, and player cleanup          |
| `play_respawn_prompt.lua` | Client respawn prompt and Space input                      |
| `play_stats.lua`          | Kills, deaths, money earned, and mission stats             |
| `play_scoreboard.lua`     | Money, Team, and K/D columns                               |
| `play_vehicles.lua`       | Placed vehicles, ownership, cleanup, and replacements      |
| `play_pickups.lua`        | Health, armor, and Loco skull pickups                      |
| `play_loco_mission.lua`   | Vehicle targets, rewards, timer, and cleanup               |
| `play_bootyLoot.lua`      | Booty Desk marker and shop access                          |
| `play_weedSystem.lua`     | Garden marker and shop access                              |

### Other Resources

| Resource                      | Role                                                                                                                  |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `pirate-map`                  | Map objects, collision fixes in `walkthrough.lua`, and Airyard logic in `capsule_marker.lua` and `mission_client.lua` |
| `[gameplay]/freeroam`         | F1 menu, vehicle options, and passive mode                                                                            |
| `[gameplay]/booty-ui`         | Weapon shop server, client, and HTML UI                                                                               |
| `[gameplay]/weed-ui`          | Strain shop, timed perks, and HTML UI                                                                                 |
| `[gameplay]/new-zombies-zday` | Storm infected spawning and pursuit                                                                                   |
| `[gameplay]/scoreboard`       | Scoreboard display                                                                                                    |
| `[gameplay]/nametags`         | Custom player nametags                                                                                                |
| `[gameplay]/deathpickups`     | Weapon and ammo drops on death                                                                                        |
| `[gameplay]/rustlerbombs`     | Rustler bomb controls                                                                                                 |
| `[gameplay]/parachute`        | Parachute support                                                                                                     |
| `[gameplay]/blur`             | Removes screen blur                                                                                                   |

Other startup resources include admin tools, speedometer, GPS, fastrope, headshots, death messages, join/quit messages, and player colors. A folder being present does not mean its resource is enabled.

## Development Notes

- GTA San Andreas + MTA:SA 1.6+, Lua 5.1, and XML. Shop UIs use HTML/CSS/JS through CEF.
- Keep resources small and split systems by role. Use exports between resources where needed.
- Keep gameplay checks and rewards on the server. Validate client requests and add rate limits where needed.
- Reuse the current message colors and UI style. Keep render work light and clear timers and elements when no longer needed.
- Custom play stats use player element data; the stats module has no save/load system.
- Safe-zone support exists, but no zones are set in the current config.
- Code review does not replace in-game and multiplayer testing.
