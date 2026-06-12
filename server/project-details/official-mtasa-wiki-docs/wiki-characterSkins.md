# Character Skins (MTA)

## Overview

Character skins are GTA:SA ped models that can be used for:

- Players
- NPCs (peds)
- Custom character systems
- Spawn systems
- Faction/job skins

---

## Valid Skin IDs

**Valid skin IDs range from:**

```lua
0 - 312
```

**Last valid skin ID:**

```lua
312
```

---

## Unused / Invalid Skin IDs

These IDs do not have valid skin models:

```lua
74
149
208
```

Avoid using them in character systems.

---

## Getting All Valid Skins

MTA provides a built-in function:

```lua
local skins = getValidPedModels()
```

Returns a table containing all valid ped model IDs.

Recommended over manually maintaining skin lists.

---

## Male & Female Skin Lists

The MTA wiki provides predefined tables containing:

```lua
maleSkins = {...}
femaleSkins = {...}
```

Useful for:

- Gender-based character creation
- Random skin selection
- Roleplay character systems

However, storing the full lists locally is usually unnecessary unless your gamemode specifically separates skins by gender.

---

## Common Functions

### Get Current Skin

```lua
local skin = getElementModel(player)
```

Returns the player's current skin/model ID.

---

### Set Player Skin

```lua
setElementModel(player, skinID)
```

Changes a player's skin.

Example:

```lua
setElementModel(player, 7)
```

---

### Get All Valid Skins

```lua
local skins = getValidPedModels()
```

Returns all valid skin IDs.

---

## Common Use Cases

### Random Spawn Skin

```lua
local skins = getValidPedModels()
local skin = skins[math.random(#skins)]

setElementModel(player, skin)
```

---

### Job/Faction Skin

```lua
setElementModel(player, 280) -- Police
```

---

### Character Selection

Store selected skin ID in:

- Account data
- Database
- Character table

Then restore on login/spawn:

```lua
setElementModel(player, savedSkin)
```

---

## Notes

- Skin IDs are GTA:SA model IDs.
- Most servers store only the skin ID and reapply it on spawn/login.
- Validate custom skin IDs before using them.
- Avoid invalid IDs: `74`, `149`, `208`.
- `getValidPedModels()` is the preferred way to obtain usable skin IDs.

---

## Related Functions

```lua
getElementModel
setElementModel
getValidPedModels
```
