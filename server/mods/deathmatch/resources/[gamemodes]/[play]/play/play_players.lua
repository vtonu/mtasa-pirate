-- ==========================================
-- PLAYER SPAWN
-- ==========================================
local PLAYER_RESPAWN_DELAY_MS = 5000
local PLAYER_RESPAWN_AUTO_DELAY_MS = 60000
local PLAYER_SPAWN_FREEZE_MS = 1000
local PLAYER_FADE_TIME_SECONDS = 1
local pendingPlayerRespawns = {}

local function getRandomPlayerSpawn()
    if type(playerSpawns) == "table" and #playerSpawns > 0 then
        return playerSpawns[math.random(#playerSpawns)]
    end

    return playerSpawn
end

local function getNearestPlayerSpawn(posX, posY, posZ)
    if type(playerSpawns) ~= "table" or #playerSpawns == 0 then
        return playerSpawn
    end

    local nearestSpawn = playerSpawns[1]
    local nearestDistance = false

    for i = 1, #playerSpawns do
        local spawnData = playerSpawns[i]
        local distance = getDistanceBetweenPoints3D(posX, posY, posZ, spawnData.x, spawnData.y, spawnData.z)

        if not nearestDistance or distance < nearestDistance then
            nearestDistance = distance
            nearestSpawn = spawnData
        end
    end

    return nearestSpawn
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

    spawnData = spawnData or getRandomPlayerSpawn()

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

    local spawnData = pendingRespawn.spawnData

    clearPendingPlayerRespawn(playerElement, true)
    playSpawnPlayer(playerElement, spawnData)
end

local function showPlayerRespawnPrompt(playerElement, spawnData)
    if not isElement(playerElement) then
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
    initPlayerStats(source)
    playMessage(source, "joinWelcome")
    playMessage(source, "joinHelp")
    playSpawnPlayer(source, playerSpawn)
end

function onPlayerWasted(totalAmmo, killerElement)
    onPlayerStatsWasted(killerElement)
    clearPendingPlayerRespawn(source, true)

    local posX, posY, posZ = getElementPosition(source)
    local nearestSpawn = getNearestPlayerSpawn(posX, posY, posZ)

    setTimer(showPlayerRespawnPrompt, PLAYER_RESPAWN_DELAY_MS, 1, source, nearestSpawn)
end

function onPlayerRespawnRequest()
    finishPendingPlayerRespawn(client)
end

function onPlayerQuit()
    clearPendingPlayerRespawn(source, false)
    stopPlayerNotifications(source)
    destroyPlayerVehicles(source)
end
