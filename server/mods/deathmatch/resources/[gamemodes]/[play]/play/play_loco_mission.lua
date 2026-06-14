-- ==========================================
-- LOCO SKULL MISSION SYSTEM
-- ==========================================

-- REWARD SETTINGS
local REWARD_MONEY = 10000
local REWARD_POINTS = 1

-- MARKER POSITION (Default pirate ship on top of ramp facing the pool)
local MARKER_X, MARKER_Y, MARKER_Z = 1996.3, 1543.7, 14.3
local MARKER_RADIUS = 0.8
local MISSION_COL_RADIUS = 1.1

-- TARGET AREA (Across the board of the ship, corner of a building & water)
local MISSION_TARGET_X, MISSION_TARGET_Y, MISSION_TARGET_Z = 1977, 1559, 11
local MISSION_TARGET_RADIUS = 5.5

-- VEHICLE LIFETIME
local MISSION_VEHICLE_LIFE_MS = 100000
local MISSION_ACCESS_TIMEOUT_MS = 30000
local MOLOTOV_EXPLOSION_TYPE = 1
local MOLOTOV_MATCH_RADIUS = 30
local MOLOTOV_MATCH_TIME_MS = 30000

-- VEHICLE MODELS THAT SPAWN
local MISSION_VEHICLE_MODELS = {
    579, -- Huntley
    400, -- Landstalker
    404, -- Perenial
    489  -- Rancher
}

-- STATE
local activeMissionVehicles = {}
local missionCompleted = {}
local vehicleTimers = {}
local missionState = {}
local missionCooldown = {}
local accessTimers = {}
local missionVehicleMolotovUntil = {}

function refreshLocoMissionAccess(player)
    if not isElement(player) then
        return false
    end

    setElementData(player, "locoMissionActive", true)

    if accessTimers[player] and isTimer(accessTimers[player]) then
        killTimer(accessTimers[player])
    end

    accessTimers[player] = setTimer(function(p)
        if isElement(p) then
            setElementData(p, "locoMissionActive", false)
        end

        accessTimers[p] = nil
    end, MISSION_ACCESS_TIMEOUT_MS, 1, player)

    return true
end

local function clearLocoMissionAccess(player)
    if not isElement(player) then
        return false
    end

    setElementData(player, "locoMissionActive", false)

    if accessTimers[player] and isTimer(accessTimers[player]) then
        killTimer(accessTimers[player])
    end

    accessTimers[player] = nil

    return true
end

-- REWARD
local function rewardPlayer(player)
    addPlayerMoneyEarned(player, REWARD_MONEY)
    addPlayerPlayStat(player, "locoPoints", REWARD_POINTS)
    addPlayerPlayStat(player, "missionCompletions", 1)
end

-- CLEANUP
local function destroyMissionVehicle(player)

    local data = activeMissionVehicles[player]
    if not data then return end

    local vehicle = data.vehicle
    local blip = data.blip

    activeMissionVehicles[player] = nil
    missionCompleted[player] = nil
    missionState[player] = nil

    if isElement(blip) then destroyElement(blip) end

    if vehicleTimers[vehicle] and isTimer(vehicleTimers[vehicle]) then
        killTimer(vehicleTimers[vehicle])
    end

    vehicleTimers[vehicle] = nil
    missionVehicleMolotovUntil[vehicle] = nil

    if isElement(vehicle) then destroyElement(vehicle) end
end

local function failMission(player)
    if not isElement(player) then
        return false
    end

    clearLocoMissionAccess(player)
    missionCooldown[player] = getTickCount() + 30000
    destroyMissionVehicle(player)

    return true
end

-- COMPLETE
local function completeMission(player, vehicle, reason, keepAccess)

    if missionCompleted[player] then return end
    missionCompleted[player] = true

    rewardPlayer(player)
    playMessage(player, "locoReward", REWARD_MONEY)

    if keepAccess then
        refreshLocoMissionAccess(player)
    else
        clearLocoMissionAccess(player)
    end

    missionCooldown[player] = nil

    setTimer(function()
        destroyMissionVehicle(player)
    end, 2000, 1)
end

-- SPAWN (HARD GATE INSIDE)
local function spawnMissionVehicle(player)

    if not isElement(player) then return end

    -- CHECK COOLDOWN
    if missionCooldown[player] and getTickCount() < missionCooldown[player] then
        playMessage(player, "locoCooldown")
        return
    end

    if getElementData(player, "locoMissionActive") ~= true then
        playMessage(player, "locoRequired")
        return
    end

    refreshLocoMissionAccess(player)

    if missionState[player] and missionState[player].active then
        return
    end

    local model = MISSION_VEHICLE_MODELS[math.random(#MISSION_VEHICLE_MODELS)]

    local angle = math.rad(math.random(0, 360))
    local dist = math.random(4, MISSION_TARGET_RADIUS)

    local x = MISSION_TARGET_X + math.cos(angle) * dist
    local y = MISSION_TARGET_Y + math.sin(angle) * dist
    local z = MISSION_TARGET_Z

    local vehicle = createVehicle(model, x, y, z)
    if not vehicle then return end

    setVehicleColor(vehicle, 0, 0, 0)

    local blip = createBlipAttachedTo(vehicle, 0, 1, 127, 255, 212, 255)

    activeMissionVehicles[player] = {
        vehicle = vehicle,
        blip = blip
    }

    missionState[player] = {
        active = true
    }

    playMessage(player, "locoTargetSpawned")

    vehicleTimers[vehicle] = setTimer(function(p)
        if isElement(p) then
            failMission(p)
        end
    end, MISSION_VEHICLE_LIFE_MS, 1, player)
end

-- COL TRIGGER (NO LOGIC, ONLY CALL)
local function onColHit(hitElement, matchingDimension)

    if not matchingDimension then return end
    if getElementType(hitElement) ~= "player" then return end

    spawnMissionVehicle(hitElement)
end

-- VEHICLE EXPLODE
addEventHandler("onVehicleExplode", root, function()
    for player, data in pairs(activeMissionVehicles) do
        if data.vehicle == source then
            local molotovUntil = missionVehicleMolotovUntil[source]
            local keepAccess = molotovUntil and getTickCount() <= molotovUntil

            completeMission(player, source, "explosion", keepAccess)
        end
    end
end)

addEventHandler("onExplosion", root, function(explosionX, explosionY, explosionZ, explosionType)
    if explosionType ~= MOLOTOV_EXPLOSION_TYPE then
        return
    end

    for _, data in pairs(activeMissionVehicles) do
        local vehicle = data.vehicle

        if isElement(vehicle) then
            local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicle)
            local distance = getDistanceBetweenPoints3D(
                explosionX,
                explosionY,
                explosionZ,
                vehicleX,
                vehicleY,
                vehicleZ
            )

            if distance <= MOLOTOV_MATCH_RADIUS then
                missionVehicleMolotovUntil[vehicle] = getTickCount() + MOLOTOV_MATCH_TIME_MS
            end
        end
    end
end)

-- CLEANUP
addEventHandler("onPlayerQuit", root, function()
    missionCooldown[source] = nil
    clearLocoMissionAccess(source)
    destroyMissionVehicle(source)
end)

-- START
addEventHandler("onResourceStart", resourceRoot, function()

    createMarker(
        MARKER_X, MARKER_Y, MARKER_Z,
        "cylinder",
        MARKER_RADIUS,
        127, 255, 212, 150
    )

    missionCol = createColSphere(
        MARKER_X, MARKER_Y, MARKER_Z,
        MISSION_COL_RADIUS
    )

    addEventHandler("onColShapeHit", missionCol, onColHit)
end)
