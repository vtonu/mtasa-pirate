-- ==========================================
-- PLAY MODE CONFIGURATION
-- ==========================================

-- Infernus spawn in front of player
vehicleSpawns = {
    {411, 2149.95, 1677.33, 10.55, 0}
}

pickupSpawns = {
    -- red health icon
    {"health", 2147.12, 1684.12, 11.35},
    -- armor icon
    {"armor", 2089.38, 1684.12, 11.35},
    -- loco skull icon
    {"loco", 2029.12, 1554.12, 11.12},
     -- pirate ship rock launcher
    {"minigun", 2000.08, 1521.74, 17.07},
    -- pirate ship rpg
    {"cannon", 2000.39, 1552.91, 14.10},
}

-- PLAYER SPAWN
-- Caligula's Palace, Las Venturas
playerSpawn = {
    x = 2163.10,
    y = 1682.55,
    z = 10.82,
    rotation = 90,
    skin = 33 -- Undertaker
}

playWorldSettings = {
    gameType = "Custom",
    mapName = "Las Venturas Freeroam",
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
