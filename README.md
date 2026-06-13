# Project Details Guide (mtasa-pirate v1.0.2)

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
- Lua 5.1
- XML
- HTML/CSS/JS (CEF when needed)
- SQLite, MySQL, or Supabase
- DX UI preferred (althought the weed-ui GUI is using CEF & HTML & works fine)

## Resource Structure

resource_name/
├── meta.xml
├── server/
├── client/
├── shared/
├── assets/
└── config/

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
- Keep maps, vehicles, pickups, and spawns separated (in my case for the play gamemode I have play_messages, play_players, play, play_pickups, play_config, play_world, play_stats, play_vehicles, play_loco_mission lua files, meta.xml, play_weedSystem.lua, play_bootyLooty.lua shop system on pirate ship etc)

## Security

- Never trust client data
- Validate inventory, money, permissions server side & all remote event data
- Add rate limiting to remote events
- Use Luac and cache protection where appropriate
- Enable native anti cheat protections
- cache="false" for meta.xml files

## Coding Standards

- Prefer local variables
- Split large systems into modules
- Reuse UI elements instead of recreating them
- Keep onClientRender lightweight
- Don't come up with new colors or words for text, unless specifcied, use the colors from the notifications & messages file

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

- Rendering
- UI
- Input handling
- Local text processing
- Sending requests to server

## Server Responsibilities

- Single source of truth
- Player state management
- Database operations
- Permission validation
- Event throttling
- Secure persistence
