-- projectiles.lua
-- GTA San Andreas / MTA:SA Projectile Reference
-- Used with createProjectile and getProjectileType

--[[
INTRODUCTION
This file contains all projectile IDs and descriptions.
You can use these IDs with the following functions:
    - createProjectile
    - getProjectileType
    - getProjectileCounter
    - getProjectileCreator
    - getProjectileForce
    - getProjectileTarget
    - setProjectileCounter
    - detonateSatchels (shared)

Example usage:
    createProjectile(player, 16, x, y, z) -- Creates a grenade at position
]]

local projectiles = {

    -- Grenades
    [16] = "Grenade",
    [17] = "Tear Gas Grenade",
    [18] = "Molotov",

    -- Rockets
    [19] = "Rocket (simple)",
    [20] = "Rocket (heat seeking)",

    -- Explosives
    [21] = "Air Bomb",
    [39] = "Satchel Charge",

    -- Special
    [58] = "Hydra flare"
}

-- Optional utility functions for easier scripting
local projectileUtils = {}

-- Get projectile name by ID
function projectileUtils.getName(id)
    return projectiles[id] or "Unknown Projectile"
end

-- Get projectile ID by name
function projectileUtils.getID(name)
    for id, n in pairs(projectiles) do
        if n == name then return id end
    end
    return nil
end

return {
    projectiles = projectiles,
    utils = projectileUtils
}