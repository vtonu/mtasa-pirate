-- ==========================================
-- LOCO SKULL MISSION SYSTEM
-- ==========================================
-- REWARD SETTINGS
local REWARD_MONEY = 15000 -- $15Kf
local REWARD_POINTS = 1

-- MARKER POSITION (Default pirate ship on top of ramp facing the pool)
local MARKER_X, MARKER_Y, MARKER_Z = 1996.3, 1543.7, 14.3
local MARKER_RADIUS = 0.8
local MISSION_COL_RADIUS = 1.1

-- TARGET AREA (Middle of lagoon)
local MISSION_TARGET_X, MISSION_TARGET_Y, MISSION_TARGET_Z = 1943.6999511719, 1528.0999755859, 28.5
local MISSION_TARGET_RADIUS = 15

-- VEHICLE LIFETIME
local MISSION_VEHICLE_LIFE_MS = 180000 -- 3 min
local MISSION_ACCESS_TIMEOUT_MS = 10000 -- 10 sec

-- VEHICLE MODELS THAT SPAWN
local MISSION_VEHICLE_MODELS = {579, -- Huntley
400, -- Landstalker
404, -- Perenial
489 -- Rancher
}

-- STATE
local activeMissionVehicles = {}
local missionTimers = {}
local missionState = {}
local missionCooldown = {}
local accessTimers = {}

local spawnMissionVehicle

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
    if not data then
        return
    end

    local vehicle = data.vehicle
    local blip = data.blip

    activeMissionVehicles[player] = nil

    if isElement(blip) then
        destroyElement(blip)
    end

    if isElement(vehicle) then
        destroyElement(vehicle)
    end
end

local function clearMission(player)
    destroyMissionVehicle(player)

    if missionTimers[player] and isTimer(missionTimers[player]) then
        killTimer(missionTimers[player])
    end

    missionTimers[player] = nil
    missionState[player] = nil
end

local function failMission(player)
    if not isElement(player) then
        return false
    end

    clearLocoMissionAccess(player)
    missionCooldown[player] = getTickCount() + 30000
    clearMission(player)

    return true
end

-- COMPLETE TARGET
local function completeMissionTarget(player)
    local state = missionState[player]

    if not state or not state.active then
        return
    end

    rewardPlayer(player)
    playMessage(player, "locoReward", REWARD_MONEY)
    destroyMissionVehicle(player)

    if getTickCount() >= state.expiresAt then
        clearMission(player)
        clearLocoMissionAccess(player)
        return
    end

    setTimer(function()
        if isElement(player) and missionState[player] and missionState[player].active then
            spawnMissionVehicle(player)
        end
    end, 2000, 1)
end

-- SPAWN (HARD GATE INSIDE)
spawnMissionVehicle = function(player)

    if not isElement(player) then
        return
    end

    -- CHECK COOLDOWN
    if missionCooldown[player] and getTickCount() < missionCooldown[player] then
        playMessage(player, "locoCooldown")
        return
    end

    if missionState[player] and missionState[player].active then
        if activeMissionVehicles[player] then
            return
        end
    else
        if getElementData(player, "locoMissionActive") ~= true then
            playMessage(player, "locoRequired")
            return
        end

        refreshLocoMissionAccess(player)

        missionState[player] = {
            active = true,
            expiresAt = getTickCount() + MISSION_VEHICLE_LIFE_MS
        }

        missionTimers[player] = setTimer(function(p)
            if isElement(p) then
                playMessage(p, "locoCooldown")
                failMission(p)
            end
        end, MISSION_VEHICLE_LIFE_MS, 1, player)
    end

    local model = MISSION_VEHICLE_MODELS[math.random(#MISSION_VEHICLE_MODELS)]

    local angle = math.rad(math.random(0, 360))
    local dist = math.random(4, MISSION_TARGET_RADIUS)

    local x = MISSION_TARGET_X + math.cos(angle) * dist
    local y = MISSION_TARGET_Y + math.sin(angle) * dist
    local z = MISSION_TARGET_Z

    local vehicle = createVehicle(model, x, y, z)
    if not vehicle then
        return
    end

    setVehicleColor(vehicle, 0, 0, 0)

    local blip = createBlipAttachedTo(vehicle, 0, 1, 127, 255, 212, 255)

    activeMissionVehicles[player] = {
        vehicle = vehicle,
        blip = blip
    }

    playMessage(player, "locoTargetSpawned")
end

-- COL TRIGGER (NO LOGIC, ONLY CALL)
local function onColHit(hitElement, matchingDimension)

    if not matchingDimension then
        return
    end
    if getElementType(hitElement) ~= "player" then
        return
    end

    spawnMissionVehicle(hitElement)
end

-- VEHICLE EXPLODE
addEventHandler("onVehicleExplode", root, function()
    for player, data in pairs(activeMissionVehicles) do
        if data.vehicle == source then
            completeMissionTarget(player)
        end
    end
end)

-- CLEANUP
addEventHandler("onPlayerQuit", root, function()
    missionCooldown[source] = nil
    clearLocoMissionAccess(source)
    clearMission(source)
end)

-- START
addEventHandler("onResourceStart", resourceRoot, function()

    createMarker(MARKER_X, MARKER_Y, MARKER_Z, "cylinder", MARKER_RADIUS, 127, 255, 212, 150)

    missionCol = createColSphere(MARKER_X, MARKER_Y, MARKER_Z, MISSION_COL_RADIUS)

    addEventHandler("onColShapeHit", missionCol, onColHit)
end)
