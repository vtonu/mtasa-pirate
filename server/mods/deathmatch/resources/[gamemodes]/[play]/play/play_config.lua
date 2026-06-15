-- ==========================================
-- PLAY MODE CONFIGURATION
-- ==========================================

-- VEHICLE SPAWNS
vehicleSpawns = {
    {411, 2149.95, 1677.33, 10.55, 0},
    {539, 2023.4000244141, 1560.5, 10.60000038147, 0}
}

pickupSpawns = {
    -- red health icon
    {"health", 2147.12, 1684.12, 11.35},
    -- armor icon
    {"armor", 2089.38, 1684.12, 11.35},
    -- loco skull icon
    {"loco", 2029.12, 1554.12, 11.12},
}

-- PLAYER SPAWN
-- Caligula's Palace, Las Venturas
playerSpawn = {
    x = 2163.10,
    y = 1682.55,
    z = 10.82,
    rotation = 90,
    skin = 303 -- Andre
}

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
