-- ==========================================
-- PLAYER SPAWN
-- ==========================================
local PLAYER_RESPAWN_DELAY_MS = 5000
local PLAYER_RESPAWN_AUTO_DELAY_MS = 60000
local PLAYER_SPAWN_FREEZE_MS = 1000
local PLAYER_FADE_TIME_SECONDS = 1
local pendingPlayerRespawns = {}
local hospitalReservations = {}

local function isHospitalSpawnClear(spawnData, playerElement)
    local reservedUntil = hospitalReservations[spawnData]
    if reservedUntil and reservedUntil > getTickCount() then
        return false
    end

    for _, elementType in ipairs({"vehicle", "player", "ped"}) do
        for _, element in ipairs(getElementsByType(elementType)) do
            if element ~= playerElement and getElementInterior(element) == 0 and getElementDimension(element) == 0 then
                local x, y, z = getElementPosition(element)
                local clearance = elementType == "vehicle" and 8 or 3
                if math.abs(z - spawnData.z) < 5 and
                    (x - spawnData.x)^2 + (y - spawnData.y)^2 < clearance^2 then
                    return false
                end
            end
        end
    end
    return true
end

local function getHospitalRespawn(deathPosition, playerElement)
    local nearestSpawn
    local nearestDistance
    for _, spawnData in ipairs(hospitalSpawns) do
        local distance = (spawnData.x - deathPosition.x)^2 + (spawnData.y - deathPosition.y)^2
        if (not nearestDistance or distance < nearestDistance) and isHospitalSpawnClear(spawnData, playerElement) then
            nearestSpawn = spawnData
            nearestDistance = distance
        end
    end
    if nearestSpawn then
        hospitalReservations[nearestSpawn] = getTickCount() + 3000
    end
    return nearestSpawn or playerSpawn
end

local function setPlayerSpawnProtection(playerElement, state)
    setElementFrozen(playerElement, state)

    local freeroamResource = getResourceFromName("freeroam")

    if freeroamResource and getResourceState(freeroamResource) == "running" then
        call(freeroamResource, "setPlayerPassiveMode", playerElement, state)
    end
end

function playSpawnPlayer(playerElement, spawnData)
    if not isElement(playerElement) then
        return false
    end

    initPlayerStats(playerElement)
    fadeCamera(playerElement, false, PLAYER_FADE_TIME_SECONDS)

    spawnData = spawnData or playerSpawn

    -- SPAWN POSITION
    spawnPlayer(playerElement, spawnData.x, spawnData.y, spawnData.z, spawnData.rotation or playerSpawn.rotation,
        spawnData.skin or playerSpawn.skin, 0, 0, nil)

    startPlayerNotifications(playerElement)
    setCameraTarget(playerElement)
    setPlayerSpawnProtection(playerElement, true)
    takeAllWeapons(playerElement)

    setTimer(function(spawnedPlayer)
        if not isElement(spawnedPlayer) then
            return
        end

        fadeCamera(spawnedPlayer, true, PLAYER_FADE_TIME_SECONDS)

        setTimer(function(protectedPlayer)
            if isElement(protectedPlayer) then
                setElementFrozen(protectedPlayer, false)
            end
        end, PLAYER_SPAWN_FREEZE_MS, 1, spawnedPlayer)
    end, 250, 1, playerElement)
end

local function clearPendingPlayerRespawn(playerElement, hidePrompt)
    local pendingRespawn = pendingPlayerRespawns[playerElement]

    if not pendingRespawn then
        return
    end

    if isTimer(pendingRespawn.timer) then
        killTimer(pendingRespawn.timer)
    end

    pendingPlayerRespawns[playerElement] = nil

    if hidePrompt and isElement(playerElement) then
        triggerClientEvent(playerElement, "playHideRespawnPrompt", resourceRoot)
    end
end

local function finishPendingPlayerRespawn(playerElement)
    local pendingRespawn = pendingPlayerRespawns[playerElement]

    if not pendingRespawn or not isElement(playerElement) then
        return
    end

    if not isPedDead(playerElement) then
        clearPendingPlayerRespawn(playerElement, true)
        return
    end

    local spawnData = pendingRespawn.spawnData
    if spawnData.hospitalRespawn then
        spawnData = getHospitalRespawn(spawnData, playerElement)
    end

    clearPendingPlayerRespawn(playerElement, true)
    playSpawnPlayer(playerElement, spawnData)
end

local function showPlayerRespawnPrompt(playerElement, spawnData)
    if not isElement(playerElement) or not isPedDead(playerElement) then
        return
    end

    pendingPlayerRespawns[playerElement] = {
        spawnData = spawnData
    }

    triggerClientEvent(playerElement, "playShowRespawnPrompt", resourceRoot)

    pendingPlayerRespawns[playerElement].timer = setTimer(finishPendingPlayerRespawn,
        PLAYER_RESPAWN_AUTO_DELAY_MS, 1, playerElement)
end

-- ==========================================
-- PLAYER EVENTS
-- ==========================================
function onPlayerJoin()
    givePlayerMoney(source, 100000)
    initPlayerStats(source)
    playMessage(source, "joinWelcome")
    playMessage(source, "joinHelp")
    local screenResource = getResourceFromName("spawn-screen")
    if screenResource and getResourceState(screenResource) == "running" then
        if call(screenResource, "showSpawnScreen", source, playerSpawn.x, playerSpawn.y, playerSpawn.z) then
            return
        end
    end

    playSpawnPlayer(source, playerSpawn)
end

addEvent("spawnScreenSpawn", false)
addEventHandler("spawnScreenSpawn", root, function()
    if getElementType(source) == "player" then
        playSpawnPlayer(source, playerSpawn)
    end
end)

function onPlayerWasted(totalAmmo, killerElement)
    onPlayerStatsWasted(killerElement)
    clearPendingPlayerRespawn(source, true)

    local spawnData = playerSpawn
    if getElementInterior(source) == 0 and getElementDimension(source) == 0 then
        local x, y = getElementPosition(source)
        spawnData = {x = x, y = y, hospitalRespawn = true}
    end
    setTimer(showPlayerRespawnPrompt, PLAYER_RESPAWN_DELAY_MS, 1, source, spawnData)
end

function onPlayerRespawnRequest()
    finishPendingPlayerRespawn(client)
end

function onPlayerQuit()
    clearPendingPlayerRespawn(source, false)
    stopPlayerNotifications(source)
    destroyPlayerVehicles(source)
end
