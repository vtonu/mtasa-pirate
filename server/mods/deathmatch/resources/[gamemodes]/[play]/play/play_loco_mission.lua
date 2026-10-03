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

-- TARGET SPAWNS
local MISSION_TARGET_SPAWNS = {{
    x = 1972.6999511719,
    y = 1558.4000244141,
    z = 10.5,
    rotation = 270
}, {
    x = 1969.8000488281,
    y = 1567.9000244141,
    z = 25.799999237061,
    rotation = 0
}, {
    x = 1908,
    y = 1514.3000488281,
    z = 14.10000038147,
    rotation = 0
}, {
    x = 1971.4000244141,
    y = 1440.0999755859,
    z = 16.89999961853,
    rotation = 0
},
    {x = 1966.03345, y = 1558.66223, z = 10.42952, rotation = 270},
    {x = 1955.70142, y = 1556.81750, z = 10.54303, rotation = 270},
    {x = 1936.82861, y = 1559.64563, z = 10.82031, rotation = 270},
    {x = 1909.17017, y = 1563.96765, z = 10.82031, rotation = 270},
    {x = 2019.42017, y = 1494.60742, z = 10.57590, rotation = 0},
    {x = 1975.62463, y = 1441.14209, z = 10.64909, rotation = 0},
    {x = 1962.58691, y = 1445.77600, z = 10.64898, rotation = 0},
    {x = 1943.02319, y = 1468.93982, z = 10.57814, rotation = 0},
    {x = 2035.35510, y = 1624.16931, z = 10.34069, rotation = 0},
    {x = 2035.17981, y = 1470.13904, z = 10.33864, rotation = 0},
    {x = 1944.16052, y = 1445.17871, z = 10.33863, rotation = 90},
    {x = 1896.74951, y = 1592.18103, z = 10.19048, rotation = 0},
    {x = 1862.28357, y = 1573.97388, z = 10.33864, rotation = 0},
    {x = 2092.10962, y = 1540.20068, z = 10.33864, rotation = 0}
}

-- VEHICLE LIFETIME
local MISSION_VEHICLE_LIFE_MS = 180000 -- 3 min
local MISSION_ACCESS_TIMEOUT_MS = 30000 -- 30 sec

-- VEHICLE MODELS THAT SPAWN
local MISSION_VEHICLE_MODELS = {579, -- Huntley
400, -- Landstalker
404, -- Perenial
489 -- Rancher
}

-- STATE
local activeMissionVehicles = {}
local missionTimers = {}
local spawnTimers = {}
local missionState = {}
local missionCooldown = {}
local accessTimers = {}
local deckBlips = {}
local blinkingBlips = {}
local blinkVisible = true

local function removeDeckBlip(player)
    local blip = deckBlips[player]
    if blip then
        blinkingBlips[blip] = nil
        if isElement(blip) then
            destroyElement(blip)
        end
        deckBlips[player] = nil
    end
end

local spawnMissionVehicle

-- KEEP DELAYED SPAWNS WITH THEIR CURRENT SESSION
local function queueMissionVehicle(player, delay)
    if isTimer(spawnTimers[player]) then return end
    local state = missionState[player]
    spawnTimers[player] = setTimer(function()
        spawnTimers[player] = nil
        if isElement(player) and not isPedDead(player) and missionState[player] == state
            and state and state.active then
            spawnMissionVehicle(player)
        end
    end, delay, 1)
end

-- SKIP VEHICLES AND PLAYERS AT EACH SPAWN
local function getClearTargetSpawn()
    local nearbyElements = getElementsByType("vehicle")
    for _, player in ipairs(getElementsByType("player")) do
        nearbyElements[#nearbyElements + 1] = player
    end
    local clearSpawns = {}
    for _, spot in ipairs(MISSION_TARGET_SPAWNS) do
        local clear = true
        for _, element in ipairs(nearbyElements) do
            if getElementInterior(element) == 0 and getElementDimension(element) == 0 then
                local x, y, z = getElementPosition(element)
                if math.abs(z - spot.z) < 4 and getDistanceBetweenPoints2D(x, y, spot.x, spot.y) < 6 then
                    clear = false
                    break
                end
            end
        end
        if clear then clearSpawns[#clearSpawns + 1] = spot end
    end
    if #clearSpawns > 0 then return clearSpawns[math.random(#clearSpawns)] end
end

function refreshLocoMissionAccess(player)
    if not isElement(player) then
        return false
    end

    setElementData(player, "locoMissionActive", true)

    if not (missionState[player] and missionState[player].active) and not isElement(deckBlips[player]) then
        local blip = createBlip(MARKER_X, MARKER_Y, MARKER_Z, 0, 2, 127, 255, 212, 255, 0, 16383, player)
        if blip then
            deckBlips[player] = blip
            blinkingBlips[blip] = true
        end
    end

    if accessTimers[player] and isTimer(accessTimers[player]) then
        killTimer(accessTimers[player])
    end

    accessTimers[player] = setTimer(function(p)
        if isElement(p) then
            setElementData(p, "locoMissionActive", false)
        end

        accessTimers[p] = nil
        removeDeckBlip(p)
    end, MISSION_ACCESS_TIMEOUT_MS, 1, player)

    return true
end

local function clearLocoMissionAccess(player)
    if not isElement(player) then
        return false
    end

    setElementData(player, "locoMissionActive", false)
    removeDeckBlip(player)

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
        blinkingBlips[blip] = nil
        destroyElement(blip)
    end

    if isElement(vehicle) then
        destroyElement(vehicle)
    end
end

local function clearMission(player)
    if isTimer(spawnTimers[player]) then killTimer(spawnTimers[player]) end
    spawnTimers[player] = nil
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

    queueMissionVehicle(player, 2000)
end

-- SPAWN (HARD GATE INSIDE)
spawnMissionVehicle = function(player)

    if not isElement(player) or isPedDead(player) then
        return
    end

    -- CHECK COOLDOWN
    if missionCooldown[player] and getTickCount() < missionCooldown[player] then
        playMessage(player, "locoCooldown")
        return
    end

    if missionState[player] and missionState[player].active then
        if activeMissionVehicles[player] or isTimer(spawnTimers[player]) then
            return
        end
        if getTickCount() >= missionState[player].expiresAt then
            failMission(player)
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
            expiresAt = getTickCount() + MISSION_VEHICLE_LIFE_MS,
            targetCount = 0
        }

        missionTimers[player] = setTimer(function(p)
            if isElement(p) then
                playMessage(p, "locoCooldown")
                failMission(p)
            end
        end, MISSION_VEHICLE_LIFE_MS, 1, player)
    end

    local model = MISSION_VEHICLE_MODELS[math.random(#MISSION_VEHICLE_MODELS)]
    local spawnData = getClearTargetSpawn()
    if not spawnData then
        queueMissionVehicle(player, 1000)
        return
    end

    local vehicle = createVehicle(model, spawnData.x, spawnData.y, spawnData.z, 0, 0, spawnData.rotation)
    if not vehicle then
        queueMissionVehicle(player, 1000)
        return
    end

    setElementFrozen(vehicle, false)
    setElementVelocity(vehicle, 0, 0, -0.04)
    setVehicleColor(vehicle, 0, 0, 0)

    local blip = createBlipAttachedTo(vehicle, 0, 1, 127, 255, 212, 255, 0, 16383, player)

    activeMissionVehicles[player] = {
        vehicle = vehicle,
        blip = blip
    }
    if blip then
        blinkingBlips[blip] = true
    end
    removeDeckBlip(player)

    local state = missionState[player]
    state.targetCount = (state.targetCount or 0) + 1

    if state.targetCount == 1 then
        playMessage(player, "locoTargetSpawned")
    else
        playMessage(player, "locoNewTargetSpawned")
    end
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
            playSoundFrontEnd(player, 46)
        end
    end
end)

-- CLEANUP
addEventHandler("onPlayerWasted", root, function()
    missionCooldown[source] = nil
    clearLocoMissionAccess(source)
    clearMission(source)
end)

addEventHandler("onPlayerQuit", root, function()
    missionCooldown[source] = nil
    clearLocoMissionAccess(source)
    clearMission(source)
end)

-- START
addEventHandler("onResourceStart", resourceRoot, function()

    setTimer(function()
        blinkVisible = not blinkVisible
        for blip in pairs(blinkingBlips) do
            if isElement(blip) then
                setBlipVisibleDistance(blip, blinkVisible and 16383 or 0)
            else
                blinkingBlips[blip] = nil
            end
        end
    end, 600, 0)

    createMarker(MARKER_X, MARKER_Y, MARKER_Z, "cylinder", MARKER_RADIUS, 127, 255, 212, 150)

    missionCol = createColSphere(MARKER_X, MARKER_Y, MARKER_Z, MISSION_COL_RADIUS)

    addEventHandler("onColShapeHit", missionCol, onColHit)
end)
