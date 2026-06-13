# Project Details (mtasa-pirate v1.0.6)

## Purpose

- Personal freeroam MTA:SA server focused on experimentation, content creation, and multiplayer gameplay with friends. Public release is optional if development reaches a stable state.

## Core Principles

- Performance first
- Minimal memory usage
- No unnecessary bloat and leak free logic
- Modular and self contained resources
- Server authoritative architecture

## Technical Stack

- GTA San Andreas + MTA:SA 1.6+
- Lua 5.1 & XML
- HTML/CSS/JS (CEF when needed)
- Preferably no database required to play
- DX UI preferred (althought the weed-ui GUI is using CEF & HTML & works fine)

## Resource Structure

resource_name/
├── meta.xml
├── server/
├── client/
├── shared/
├── assets/
└── config/

## Main Project Structure

The main custom work for this project is kept inside `server/mods/deathmatch/resources/`.

```text
resources/
|-- [gamemodes]/[play]/play/
|   |-- meta.xml
|   |-- play.lua
|   |-- play_config.lua
|   |-- play_world.lua
|   |-- play_messages.lua
|   |-- play_stats.lua
|   |-- play_players.lua
|   |-- play_vehicles.lua
|   |-- play_pickups.lua
|   |-- play_loco_mission.lua
|   |-- play_bootyLoot.lua
|   `-- play_weedSystem.lua
|-- [gameplay]/booty-ui/
|-- [gameplay]/weed-ui/
|-- [gameplay]/nametags/
|-- [gameplay]/freeroam/
`-- pirate-map/
```

There are more resources inside the MTA gameplay folder, but most are default, unused, disabled, or only changed when the gamemode requires it. The resources listed above are the ones most relevant to `mtasa-pirate`.

The `pirate-map` resource also contains the full map and its object files. Those files are not listed here because they mainly contain map objects rather than core gameplay logic.

## Architecture Rules

- Every resource must have a valid meta.xml
- Require minimum MTA version 1.6.0
- Keep resources decoupled
- Use exports instead of globals
- Resource names must be lowercase with no spaces

## Meta.xml Standards

Common tags:

- info
- script
- file
- include
- config
- export
- min_mta_version
- aclrequest
- oop
- download_priority_group

Rules:

- Use `cache="false"` for sensitive client files
- Wildcards supported in MTA 1.6+
- Shared scripts run in separate client and server environments

## Gamemode Design

- Follow standard MTA gamemode (play with freeroam) structure
- Load maps dynamically (in my case a map folder named pirate-map in resources that also contains client lua & meta file)
- Keep maps, vehicles, pickups, spawns, missions, shops, and other systems separated

## Play Gamemode Modules

- `meta.xml` - Defines the `play` gamemode, its server scripts, and required supporting resources
- `play.lua` - Main gamemode entry point and event setup
- `play_config.lua` - Gamemode configuration values and gameplay data
- `play_world.lua` - World settings, safe zones, damage protection, and explosion handling
- `play_messages.lua` - Central messages, notifications, colors, and timed player notices
- `play_stats.lua` - Player stat tracking such as kills, deaths, and money earned
- `play_players.lua` - Player spawning, respawning, joining, and cleanup
- `play_vehicles.lua` - Vehicle creation, ownership, timers, cleanup, and respawning
- `play_pickups.lua` - Health, armor, money, and weapon pickup creation and respawning
- `play_loco_mission.lua` - Locomotive mission access, mission vehicles, rewards, failure, and cleanup
- `play_bootyLoot.lua` - Pirate ship Booty Loot weapon shop marker and access logic
- `play_weedSystem.lua` - Weed garden marker and access logic

The gamemode remains server authoritative. The main `play` resource owns gameplay state and uses separate UI resources when client-side interfaces are needed.

## Custom Gameplay Resources

### Booty UI

- CEF and HTML weapon shop interface for the Pirate Booty Desk
- Uses `server.lua`, `client.lua`, and `ui.html`
- Exposes server functions for opening and closing the UI
- Works with `play_bootyLoot.lua` for shop access and purchasing

### Weed UI

- CEF and HTML greenhouse interface for the weed growing system
- Uses `server.lua`, `client.lua`, and `ui.html`
- Exposes server functions for opening, updating, and closing the UI
- Works with `play_weedSystem.lua` for garden access

### Nametags

- Custom client-side nametag system
- Uses a separate config file for display settings

### Freeroam

- Supporting freeroam resource used by the `play` gamemode
- Mostly based on the existing MTA resource and only changed where needed, including the F1 GUI

## Pirate Map

- `pirate-map.map` contains the main pirate-themed map and its placed objects
- `meta.xml` registers the map, map settings, editor scripts, and custom client script
- `client.lua` handles object-specific collision and visibility workarounds
- Selected model IDs can be made walk-through or invisible when required
- Individual objects can also be targeted by their custom map element IDs

This client script is needed because some map objects are used as visual or replacement pieces and need different collision or visibility behavior from their default GTA object models.

## Security

- Never trust client data
- Validate inventory, money, permissions server side & all remote event data
- Add rate limiting to remote events
- Use Luac and cache protection where appropriate
- Enable native anti cheat protections
- cache="false" for meta.xml files

## Coding Standards

- Prefer local variables & splitting large systems into modules
- Reuse UI elements instead of recreating them
- Keep onClientRender lightweight
- Don't come up with new colors for text, unless specified, or words, use the colors from the notifications & messages file

## Utility Functions

### Table

- table.copy
- table.merge
- table.deepmerge
- table.random
- table.size

### Math

- math.clamp
- math.lerp
- math.round

### UI

- centerWindow
- isMouseOnGuiElement

### Execution

- debounce
- isEventHandlerAdded

## Important Server and Client Events

- onResourceStart
- onResourceStop

## Gamemode

- onGamemodeMapStart
- onGamemodeMapStop

## Network

- onClientResourceStart
- onPlayerJoin
- onPlayerQuit

## Client Responsibilities

- Rendering & UI
- Input handling & Local text processing
- Sending requests to server

## Server Responsibilities

- Single source of truth
- Player state management
- Database operations
- Permission validation
- Event throttling
- Secure persistence
