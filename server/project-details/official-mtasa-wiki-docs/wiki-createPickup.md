# Pickup Inspection & Modification Functions

These functions allow you to inspect and modify existing pickups after they have been created.

Commonly used for:

- Weapon drop systems
- Loot systems
- Money pickups
- Health and armor pickups
- Dynamic pickup behavior
- Inventory systems
- Custom world item systems

---

# getPickupType

## Overview

Retrieves the type of a pickup.

## Syntax

```lua
int getPickupType(pickup thePickup)
```

## Parameters

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| thePickup | pickup | Pickup to inspect. |

## Return Values

| Value | Meaning        |
| ----- | -------------- |
| 0     | Health Pickup  |
| 1     | Armour Pickup  |
| 2     | Weapon Pickup  |
| 3     | Custom Pickup  |
| false | Invalid pickup |

## Typical Usage

```lua
local pickupType = getPickupType(pickup)
```

Used before calling pickup-specific functions such as:

- getPickupAmount()
- getPickupAmmo()
- getPickupWeapon()

Example:

```lua
if getPickupType(pickup) == 2 then
    -- weapon pickup logic
end
```

---

# getPickupAmount

## Overview

Retrieves the amount of health or armor contained in a pickup.

## Syntax

```lua
int getPickupAmount(pickup thePickup)
```

## Parameters

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| thePickup | pickup | Pickup to inspect. |

## Return Values

| Return  | Meaning                        |
| ------- | ------------------------------ |
| Integer | Health/armour amount.          |
| 0       | Not a health or armour pickup. |
| false   | Invalid pickup.                |

## Supported Types

Works with:

- Health pickups (type 0)
- Armour pickups (type 1)

Example:

```lua
local amount = getPickupAmount(pickup)
```

Common use cases:

- Display pickup values.
- Scale rewards.
- Create custom healing systems.
- Modify armor mechanics.

---

# getPickupAmmo

## Overview

Retrieves the amount of ammunition stored in a weapon pickup.

## Syntax

```lua
int getPickupAmmo(pickup thePickup)
```

## Parameters

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| thePickup | pickup | Pickup to inspect. |

## Return Values

| Return  | Meaning                        |
| ------- | ------------------------------ |
| Integer | Ammo amount in the pickup.     |
| 0       | Pickup is not a weapon pickup. |
| false   | Invalid pickup.                |

## Supported Types

Works only with:

- Weapon pickups (type 2)

Example:

```lua
local ammo = getPickupAmmo(pickup)
```

Common use cases:

- Weapon drop systems.
- Loot systems.
- Inventory synchronization.
- Preserving ammunition between drops and pickups.

---

# getPickupWeapon

## Overview

Retrieves the weapon ID stored in a weapon pickup.

## Syntax

```lua
int getPickupWeapon(pickup thePickup)
```

## Parameters

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| thePickup | pickup | Pickup to inspect. |

## Return Values

| Return    | Meaning                         |
| --------- | ------------------------------- |
| Weapon ID | Weapon contained in the pickup. |
| false     | Invalid pickup.                 |

## Supported Types

Works only with:

- Weapon pickups (type 2)

Example:

```lua
local weapon = getPickupWeapon(pickup)
```

Common use cases:

- Weapon-drop systems.
- Loot crates.
- Pickup notifications.
- Inventory conversion.

Example:

```lua
local weapon = getPickupWeapon(pickup)
local ammo = getPickupAmmo(pickup)
```

---

# setPickupType

## Overview

Changes an existing pickup into another pickup type.

Can transform a pickup into:

- Health pickup
- Armour pickup
- Weapon pickup
- Custom pickup

## Syntax

```lua
bool setPickupType(
    pickup thePickup,
    int theType,
    int amountWeaponOrModel,
    [int ammo]
)
```

## Parameters

### thePickup

Pickup to modify.

### theType

| Value | Type          |
| ----- | ------------- |
| 0     | Health Pickup |
| 1     | Armour Pickup |
| 2     | Weapon Pickup |
| 3     | Custom Pickup |

### amountWeaponOrModel

Behavior depends on pickup type.

#### Health Pickup

Amount of health granted.

```lua
setPickupType(pickup, 0, 100)
```

#### Armour Pickup

Amount of armor granted.

```lua
setPickupType(pickup, 1, 100)
```

#### Weapon Pickup

Weapon ID.

```lua
setPickupType(pickup, 2, weaponID, ammo)
```

#### Custom Pickup

Model ID.

```lua
setPickupType(pickup, 3, modelID)
```

### ammo

Required when using a weapon pickup.

Example:

```lua
setPickupType(pickup, 2, 29, 100)
```

Creates an MP5 pickup with 100 ammo.

## Return Values

| Return | Meaning               |
| ------ | --------------------- |
| true   | Successfully changed. |
| false  | Failed.               |

---

## Common Custom Pickup Models

| Model | Description  |
| ----- | ------------ |
| 370   | Jetpack      |
| 1240  | Health Heart |
| 1242  | Armour       |
| 1272  | Blue House   |
| 1273  | Green House  |
| 1274  | Money Symbol |
| 1277  | Save Disk    |

---

# Typical Pickup Inspection Pattern

Most pickup systems follow this workflow:

```lua
local pickupType = getPickupType(pickup)

if pickupType == 0 then
    local health = getPickupAmount(pickup)

elseif pickupType == 1 then
    local armor = getPickupAmount(pickup)

elseif pickupType == 2 then
    local weapon = getPickupWeapon(pickup)
    local ammo = getPickupAmmo(pickup)

elseif pickupType == 3 then
    -- custom pickup logic
end
```

---

# Typical Dynamic Pickup Pattern

Transform pickups dynamically:

```lua
Health
  ↓
Armour
  ↓
Weapon
  ↓
Health
```

Example:

```lua
if getPickupType(pickup) == 0 then
    setPickupType(pickup, 1, 100)

elseif getPickupType(pickup) == 1 then
    setPickupType(pickup, 2, 29, 100)

elseif getPickupType(pickup) == 2 then
    setPickupType(pickup, 0, 100)
end
```

---

# AI Development Notes

When building custom systems:

### Health Pickup

```lua
type = 0
amount = getPickupAmount(pickup)
```

### Armour Pickup

```lua
type = 1
amount = getPickupAmount(pickup)
```

### Weapon Pickup

```lua
type = 2
weapon = getPickupWeapon(pickup)
ammo = getPickupAmmo(pickup)
```

### Custom Pickup

```lua
type = 3
```

Useful for:

- Death drops
- Ground loot
- RPG item systems
- Inventory systems
- Mission rewards
- Dynamic world events
- Persistent pickup systems

Together with `createPickup()`, these functions provide full creation, inspection, and modification control over MTA pickup elements.
