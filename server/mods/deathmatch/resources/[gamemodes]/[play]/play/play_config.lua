-- ==========================================
-- PLAY MODE CONFIGURATION
-- ==========================================
-- VEHICLE SPAWNS
vehicleSpawns = {{411, 2149.95, 1677.33, 10.55, 0}, -- Infernus
{411, 1954.80005, 1358.59998, 9.1, 0}, -- INFERNUS AT THE HIGH ROLLER
{411, 2219.80005, 1279.80005, 10.6, 0}, -- INFERNUS AT THE CAMEL'S TOE
{411, 2028, 1934.19995, 12, 270}, -- INFERNUS AT THE VISAGE
{411, 2199.89990, 1856.40002, 10.5, 0}, -- INFERNUS AT THE CLOWN'S POCKET
{539, 2023.4000244141, 1560.5, 10.60000038147, 0}, -- Vortex
{476, 2024, 1431.0999755859, 12.10000038147, 270}, -- Rustler
}

pickupSpawns = {{"health", 2146, 1683.3000488281, 10.800000190735}, -- red health icon near fountain 
{"armor", 2144.3000488281, 1683.3000488281, 13.300000190735}, -- armor icon near fountain
{"loco", 2025.3000488281, 1552.8000488281, 11.39999961853}} -- loco skull at pirates in men's pants

-- PLAYER SPAWN
playerSpawn = {
    x = 2163.10,
    y = 1682.55,
    z = 10.82,
    rotation = 90,
    skin = 303 -- Andre
}

-- HOSPITAL RESPAWNS
hospitalSpawns = {
    {x = 1606.77319, y = 1819.75854, z = 10.82800, rotation = 0},
    {x = 1894.41418, y = 2236.30737, z = 11.12500, rotation = 0},
    {x = -1514.66064, y = 2519.68188, z = 56.04676, rotation = 0},
    {x = -2664.44775, y = 637.55707, z = 14.45312, rotation = 0},
    {x = 1172.85095, y = -1323.72571, z = 15.39980, rotation = 0},
    {x = 2035.82324, y = -1413.52197, z = 16.99219, rotation = 0},
    {x = -2201.26147, y = -2307.73608, z = 30.62500, rotation = 0},
    {x = 1241.80615, y = 327.34695, z = 19.75551, rotation = 0},
    {x = -322.65298, y = 1057.22168, z = 19.74219, rotation = 0}
}

playWorldSettings = {
    gameType = "Custom",
    mapName = "4AM in Las Venturas",
    time = {3, 0},
    minuteDuration = 999999999,
    weather = 18,
    weatherCycle = {18, 9},
    weatherInterval = 3 * 60 * 1000,
    weatherIntervals = {[18] = 5 * 60 * 1000},
    cloudsEnabled = true,
    gravity = 0.008,
    explosionsEnabled = true
}

playSafeZones = {
    -- Example:
    -- {x = 2163.10, y = 1682.55, z = 10.82, radius = 12, name = "Main Spawn"}
}
