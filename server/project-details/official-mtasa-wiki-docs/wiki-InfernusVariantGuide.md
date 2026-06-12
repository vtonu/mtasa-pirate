# MTA:SA Vehicle Variants & Custom Infernus Guide

This document explains how vehicle variants work in MTA:SA and how to create a custom Infernus with upgrade style features similar to those found on modded RP servers.

## 1. What Vehicle Variants Are

In MTA:SA, vehicle variants are built into GTA:SA vehicle models and are used to toggle optional model parts.

Variants are controlled using:

```lua
createVehicle(modelID, x, y, z, rx, ry, rz, plate, variant1, variant2)
```

```lua
setVehicleVariant(vehicle, variant1, variant2)
```

Each variant uses a numerical index that enables specific pre modeled parts within the vehicle.

If an invalid variant is selected, GTA:SA typically falls back to the default vehicle appearance.

## 2. How Variants Work Internally

Variants only function if the vehicle DFF contains extra model objects.

Example structure:

```text
vehicle_root
└── chassis_dummy
    ├── extra1
    ├── extra2
    ├── extra3
    ├── extra4
    └── extra5
```

Each `extraX` object:

- Is a separate mesh inside the DFF
- Can be enabled or disabled through variant IDs
- Is handled directly by the GTA engine without per frame scripting

## 3. Rules for Custom Variants

### Requirements

- Extras must be named exactly:
  - `extra1`
  - `extra2`
  - `extra3`
  - etc.

- All extras must be parented to:
  - `chassis_dummy`

- Geometry should be correctly aligned before exporting.

### Avoid

- Parenting extras to wheels, doors, steering components, or other moving parts
- Using incorrect names such as:
  - `Extra_1`
  - `extra01`
  - `EXTRA1`

- Breaking the hierarchy during export

## 4. Creating a Custom Infernus Variant

### Target Vehicle

- Infernus (Vehicle ID 411)

### Step 1: Open the Model

Recommended tools:

- ZModeler 2
- 3ds Max with GTA plugins/scripts

Import:

```text
infernus.dff
```

### Step 2: Add Custom Parts

Examples:

- Spoiler A
- Spoiler B
- Custom front bumper
- Hood vents
- Roof scoop
- Interior trim pieces

### Step 3: Assign Extras

Example setup:

```text
extra1 = Spoiler Type 1
extra2 = Spoiler Type 2
extra3 = Widebody Kit Piece
extra4 = Roof Scoop
extra5 = Interior Detail
```

### Step 4: Configure Hierarchy

All extras must be placed under:

```text
chassis_dummy
```

This allows GTA:SA to recognize them as vehicle variants.

### Step 5: Export

Export the finished model as:

```text
infernus_custom.dff
```

Optional updates:

- `.txd` for textures
- `.col` for collision changes

## 5. Using Variants in MTA:SA

### Spawn a Vehicle with Variants

```lua
local vehicle = createVehicle(411, x, y, z, 0, 0, 0, "", 0, 1)
```

### Change Variants Dynamically

```lua
setVehicleVariant(vehicle, 1, 0)
```

## 6. Building a Modded Server Style Customization System

To achieve customization similar to advanced RP servers, combine multiple systems.

### A. Variants (DFF Extras)

Best for:

- Spoilers
- Bumpers
- Body kits
- Roof accessories

### B. Attached Objects

Best for:

- Stickers
- Neon lights
- Interior props
- Antennas
- Decorative accessories

Example:

```lua
attachElements(object, vehicle)
```

### C. Shaders

Best for:

- Paint customization
- Window tint
- Neon glow
- Tire smoke color
- Headlight effects

### D. Scripted Tuning Systems

Common features include:

#### Visual

- Wheel selection
- RGB paint
- Pearlescent paint
- Window tint
- Neon underglow
- Headlight colors
- License plate styles

#### Cosmetic

- Spoilers
- Bumpers
- Exhaust tips
- Stickers
- Liveries
- Roof accessories

## 7. Example Upgrade Plan for the Infernus

### Performance Layer

Optional scripted upgrades:

- Engine tuning
- Handling adjustments
- Top speed modifications
- Acceleration improvements

### Visual Layer

- Custom paint system
- Wheel swapping
- Window tint
- Neon underglow

### Model Layer (DFF Variants)

- Spoiler packages
- Bumper packages
- Roof modifications
- Widebody kits

### Add On Layer

- Stickers
- Decals
- LED lighting
- Custom brake lights

## 8. Notes and Best Practices

- Variants are limited and should be reserved for static body parts.
- Modern tuning systems typically combine:
  - DFF extras
  - Shaders
  - Object attachments
  - Scripted customization systems

- Keep the system modular so additional upgrades can be added later.
- Plan customization categories separately to make future expansion easier.

## Goal

Create a custom Infernus system that supports:

- Visual customization
- Modular body kits
- Dynamic paint options
- Lighting customization
- Expandable tuning features

The result is a modern vehicle customization system similar to those found on popular RP servers while remaining optimized for a local MTA:SA environment.

### Vehicle Component Manipulation

MTA:SA supports per vehicle component manipulation, allowing individual model parts to be moved, rotated, hidden, or shown independently without affecting the rest of the vehicle. Components are identified by their model names and must be parented under `chassis_dummy` to function correctly. Hidden by default components can be created by prefixing their names with `#` in the DFF, making them ideal for optional features such as body kits, custom doors, hidden weapons, spoilers, lights, or other accessories that can be revealed through scripting. This system enables advanced customization and animations including custom wheel setups, scissor or gullwing doors, retractable panels, transforming vehicle parts, and even fully transformable vehicles. Since hidden components are not rendered, large numbers of optional parts can be included in a model with minimal performance impact, making the system highly flexible for modern tuning and RP server vehicle customization.
