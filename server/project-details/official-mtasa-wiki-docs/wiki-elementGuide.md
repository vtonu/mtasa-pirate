# Element

## Overview

An element is the fundamental object type in MTA:SA. Nearly every in game entity is represented as an element, including players, vehicles, objects, markers, pickups, GUI components, resources, and custom script created elements.

Elements provide a unified API for accessing properties such as position, rotation, model, dimension, interior, health, velocity, parent/child relationships, and custom data. Most scripting functions operate on elements.

---

## Element Hierarchy

All elements exist within a tree structure.

```text
root
├── resource
│   ├── player
│   ├── vehicle
│   ├── object
│   └── marker
└── another_resource
```

Every element has a parent except the root element.

Common parents include:

- Root Element
- Resource Elements
- Map Elements
- Other Elements

This hierarchy is primarily used for organization and scope management.

---

## Built In Element Types

### World Elements

- Player
- Ped
- Vehicle
- Building
- Object
- Pickup
- Marker
- Collision Shape
- Blip
- Radar Area
- Projectile

### Team & Server

- Team
- Server Console

### GUI Elements

- Button
- Checkbox
- Combobox
- Edit Field
- Gridlist
- Memo
- Progress Bar
- Radio Button
- Scrollbar
- Scrollpane
- Static Image
- Tab Panel
- Tab
- Text Label
- Window

### Asset Elements

- TXD
- DFF
- COL

### Rendering Elements

- Material
- Texture
- Shader
- DX Font
- GUI Font

### Media Elements

- Sound
- Browser

### Misc Elements

- Weapon
- Camera
- Effect
- Light
- Searchlight
- Water

---

## Dummy Elements

Custom elements can be created using:

```lua
local element = createElement("mission")
```

These are commonly called dummy elements.

They do not create any physical game entity and are often used for:

- Data storage
- Mission systems
- Resource organization
- Object grouping
- Custom frameworks

---

## Common Element Properties

Most elements support:

- Position
- Rotation
- Velocity
- Alpha
- Dimension
- Interior
- Parent
- Children
- Model
- Health
- Element Data

Example:

```lua
setElementPosition(vehicle, x, y, z)
setElementRotation(vehicle, rx, ry, rz)
setElementHealth(vehicle, 1000)
```

---

## Element Data

Element data allows custom values to be attached to any element.

```lua
setElementData(player, "money", 5000)

local money = getElementData(player, "money")
```

Common uses:

- Player statistics
- Mission progress
- Vehicle ownership
- Faction systems
- Custom metadata

---

## Core Functions

### Creation & Destruction

```lua
createElement
destroyElement
```

### Type & Validation

```lua
isElement
getElementType
getElementsByType
getRootElement
```

### Position & Rotation

```lua
getElementPosition
setElementPosition

getElementRotation
setElementRotation

getElementMatrix
```

### Velocity

```lua
getElementVelocity
setElementVelocity

getElementAngularVelocity
setElementAngularVelocity
```

### Health

```lua
getElementHealth
setElementHealth
```

### Model

```lua
getElementModel
setElementModel
```

### Parent & Children

```lua
getElementParent
setElementParent

getElementChild
getElementChildren
getElementChildrenCount
```

### Data

```lua
setElementData
getElementData
getAllElementData
hasElementData
```

### Interior & Dimension

```lua
setElementInterior
getElementInterior

setElementDimension
getElementDimension
```

### Attachment System

```lua
attachElements
detachElements

getAttachedElements
getElementAttachedTo

setElementAttachedOffsets
getElementAttachedOffsets
```

### Visibility

```lua
setElementAlpha
getElementAlpha

setElementDoubleSided
isElementDoubleSided
```

### Collision

```lua
setElementCollisionsEnabled
getElementCollisionsEnabled

isElementWithinColShape
isElementWithinMarker
```

### State

```lua
setElementFrozen
isElementFrozen

isElementInWater
isElementOnFire
setElementOnFire
```

---

## Streaming Functions

Useful for optimization and large maps.

```lua
isElementStreamedIn
isElementStreamable
setElementStreamable

isElementOnScreen
isElementSyncer
```

---

## Bone Functions

Available for peds and some animated entities.

```lua
getElementBonePosition
setElementBonePosition

getElementBoneRotation
setElementBoneRotation

getElementBoneMatrix
setElementBoneMatrix

getElementBoneQuaternion
setElementBoneQuaternion
```

Common uses:

- Weapon attachments
- Character customization
- Custom animations
- IK systems

---

## Low LOD Functions

```lua
getLowLODElement
setLowLODElement

isElementLowLOD
```

Used to improve rendering performance by assigning distant models.

---

## Best Practices

- Always validate elements using `isElement()`.
- Destroy unused elements to prevent memory leaks.
- Use element data sparingly for frequently updated values.
- Group related entities using parent child relationships.
- Prefer local variables over repeated element lookups.
- Use dimensions and interiors to separate gameplay areas.

---

## Example

```lua
local vehicle = createVehicle(411, 0, 0, 3)

setElementData(vehicle, "owner", "Vic")
setElementFrozen(vehicle, true)

local owner = getElementData(vehicle, "owner")

outputDebugString("Vehicle Owner: " .. owner)
```

This creates a vehicle element, stores custom data on it, freezes it, and retrieves the stored value.
