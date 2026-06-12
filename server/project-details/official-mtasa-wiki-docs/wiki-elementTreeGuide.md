## Element Tree

### Overview

MTA stores every element in a hierarchical structure called the Element Tree. Every element on the server or client belongs somewhere within this tree and has exactly one parent element.

A useful way to think about it is as a family tree:

- Every element has a parent.
- Elements can have many children.
- The root element sits at the very top.
- Destroying a parent usually destroys all of its children.

This system is heavily tied to resources, maps, and runtime created elements.

---

### Basic Tree Structure

```text
root
├── console
├── player
├── player
├── resource: freeroam
│   └── map: dynamic
│       ├── vehicle
│       ├── marker
│       └── object
├── resource: race
│   └── map: race.map
│       ├── spawnpoint
│       ├── checkpoint
│       └── object
```

Every element eventually traces back to the root element.

---

### Root Element

The root element is the top level parent of the entire server.

```lua
local root = getRootElement()
```

Everything ultimately exists beneath it.

Examples:

- Players
- Vehicles
- Resources
- Markers
- Objects
- Teams
- Blips

---

### Resource Elements

Each running resource automatically gets its own resource root.

```lua
local resourceRoot = getResourceRootElement(getThisResource())
```

Resources use their root element to organize everything they create.

Example:

```text
resource
├── dynamic map
├── vehicle
├── marker
└── object
```

When a resource stops, its elements are usually removed automatically.

---

### Map Elements

Every resource contains at least one map element.

#### Dynamic Map

Stores elements created through scripts.

```text
resource
└── dynamic
    ├── vehicle
    ├── marker
    └── object
```

#### File Based Maps

Stores elements loaded from .map files.

```text
resource
└── race.map
    ├── spawnpoint
    ├── checkpoint
    └── object
```

---

### Parent Child Relationships

Every element can contain child elements.

```lua
setElementParent(childElement, parentElement)
```

Retrieve a parent:

```lua
local parent = getElementParent(element)
```

Retrieve children:

```lua
local children = getElementChildren(element)
```

Example:

```text
vehicle
├── neon_left
├── neon_right
├── spoiler
└── exhaust
```

This allows custom systems to be grouped together logically.

---

### Why The Element Tree Matters

The tree makes it easy to:

- Organize resources
- Group related elements
- Access map data
- Destroy large groups of elements
- Apply changes to multiple elements

Example:

```lua
destroyElement(resourceRoot)
```

This can remove an entire collection of child elements at once.

---

### Element Data In The Tree

Any element can store custom data.

```lua
setElementData(player, "Level", 25)
```

```lua
local level = getElementData(player, "Level")
```

Because every entity is an element, data can be attached to:

- Players
- Vehicles
- Objects
- Teams
- Custom elements

---

### Resource Based Map Systems

Many gamemodes rely on the element tree to load map information.

Example:

```text
resource
└── farm.map
    ├── spawngroup
    ├── spawnarea
    ├── objective
    └── pickup
```

The gamemode can read these elements using:

```lua
getElementsByType()
getElementData()
getElementChildren()
```

This allows map creators to define gameplay directly through XML.

---

### Applying Functions To Entire Branches

Many MTA functions can operate on an element and all of its descendants.

Example:

```lua
setMarkerSize(root, 2.5)
```

This affects every marker below the root element.

The same principle applies when targeting:

- Resource roots
- Map elements
- Custom parent elements

This makes bulk operations very powerful.

---

### Custom Element Systems

Dummy elements are often used as folders.

Example:

```lua
local garage = createElement("garage")
```

Tree structure:

```text
garage
├── vehicle
├── vehicle
├── marker
└── blip
```

Benefits:

- Easy cleanup
- Easy lookups
- Better organization
- Modular systems

---

### Element Browser

MTA includes an Element Browser resource that lets developers inspect the live element tree.

Useful for:

- Debugging
- Tracking leaks
- Viewing parent relationships
- Finding unexpected elements
- Monitoring resource activity

The Element Browser provides a real time view of the server's internal element hierarchy.

---

### Best Practices

- Keep related elements under a common parent.
- Use resource roots for automatic cleanup.
- Destroy temporary parent elements when finished.
- Avoid attaching excessive data to the root element.
- Use custom dummy elements as logical folders.
- Think of the element tree as the backbone of MTA's object system.

Understanding the Element Tree is essential for building scalable gamemodes, mission systems, vehicle systems, housing systems, and large multiplayer frameworks.
