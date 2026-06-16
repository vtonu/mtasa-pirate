-- ==========================================
-- PLAY MODE CONFIGURATION
-- ==========================================
-- VEHICLE SPAWNS
vehicleSpawns = {{411, 2149.95, 1677.33, 10.55, 0}, -- Infernus
{539, 2023.4000244141, 1560.5, 10.60000038147, 0}, -- Vortex
{457, 2023.7998046875, 1549.2001953125, 10.60000038147, 271.73583984375} -- Caddy
}

pickupSpawns = {{"health", 2146, 1683.3000488281, 10.800000190735}, -- red health icon near fountain 
{"armor", 2144.3000488281, 1683.3000488281, 13.300000190735}, -- armor icon near fountain
{"loco", 2025.3000488281, 1552.8000488281, 11.39999961853}} -- loco skull at pirates in men's pants

-- PLAYER SPAWN FALLBACK
playerSpawn = {
    x = 2163.10,
    y = 1682.55,
    z = 10.82,
    rotation = 90,
    skin = 303 -- Andre
}

-- PLAYER SPAWNS
playerSpawns = {{
    x = 2163.10,
    y = 1682.55,
    z = 10.82,
    rotation = 90,
    name = "Caligula's Palace"
}, {
    x = 1970.145,
    y = 1623.144,
    z = 12.863,
    rotation = 0,
    name = "Pirate in Men's Pants Casino Entrance"
}, {
    x = 2222.357,
    y = 1838.855,
    z = 10.820,
    rotation = 0,
    name = "The Clown's Pocket"
}, {
    x = 2027.691,
    y = 1916.023,
    z = 12.328,
    rotation = 0,
    name = "The Visage"
}, {
    x = 2236.576,
    y = 1285.966,
    z = 10.820,
    rotation = 0,
    name = "The Camel's Toe"
}, {
    x = 1957.339,
    y = 1343.005,
    z = 15.375,
    rotation = 0,
    name = "The High Roller"
}}

playWorldSettings = {
    gameType = "Custom",
    mapName = "4AM in Las Venturas",
    time = {4, 0}, -- 4AM in Las Venturas
    minuteDuration = 999999999,
    weather = 17, -- (Sunny, Scorching Hot)
    cloudsEnabled = true,
    gravity = 0.008,
    explosionsEnabled = true
}

playSafeZones = {
    -- Example:
    -- {x = 2163.10, y = 1682.55, z = 10.82, radius = 12, name = "Main Spawn"}
}
