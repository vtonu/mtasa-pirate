-- ==========================================
-- MARKERS
-- ==========================================

-- Creates a 3D marker in the world.
-- Common uses:
-- Missions
-- Objectives
-- Entrances
-- Teleports
-- Interactive locations

-- MARKER TYPES
-- "checkpoint" = Race checkpoint pillar
-- "ring"       = Circular ring
-- "cylinder"   = Ground marker
-- "arrow"      = Downward arrow
-- "corona"     = Glowing light sphere

-- IMPORTANT NOTES
-- Arrow markers may have positioning issues.
-- Place arrow markers at least 1 unit above the ground.

-- Cylinder marker collisions are slightly larger
-- than the visible marker texture.

-- VISIBILITY LIMITS
-- Coronas: 32
-- Checkpoints, Rings, Cylinders, Arrows: 32 combined

-- SERVER SYNTAX
-- createMarker(
--     x, y, z,
--     markerType,
--     size,
--     r, g, b, a,
--     visibleTo,
--     ignoreAlphaLimits
-- )

-- CLIENT SYNTAX
-- createMarker(
--     x, y, z,
--     markerType,
--     size,
--     r, g, b, a,
--     ignoreAlphaLimits
-- )

-- REQUIRED ARGUMENTS
-- x = X position
-- y = Y position
-- z = Z position

-- OPTIONAL ARGUMENTS
-- markerType = "checkpoint"
-- size = 4.0
-- r = 0
-- g = 0
-- b = 255
-- a = 255

-- IGNORE ALPHA LIMITS
-- Works only on:
-- checkpoint
-- arrow

-- false:
-- checkpoint alpha = 128
-- arrow alpha = 255

-- true:
-- alpha can be customized

-- RETURN VALUE
-- Success = marker element
-- Failure = false

-- EXAMPLE

local marker = createMarker(
    2163.10,
    1682.55,
    10.82,
    "cylinder",
    1.5,
    255,
    255,
    0,
    170
)

-- USEFUL FUNCTIONS
-- getMarkerColor()
-- getMarkerSize()
-- getMarkerType()
-- getMarkerIcon()
-- getMarkerTarget()

-- setMarkerColor()
-- setMarkerSize()
-- setMarkerType()
-- setMarkerIcon()
-- setMarkerTarget()