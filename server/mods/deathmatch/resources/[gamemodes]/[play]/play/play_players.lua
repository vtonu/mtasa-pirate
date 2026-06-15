-- ==========================================
-- PLAYER SPAWN
-- ==========================================
local PLAYER_RESPAWN_DELAY_MS = 5000
local PLAYER_SPAWN_FREEZE_MS = 1000
local PLAYER_FADE_TIME_SECONDS = 1

local function getRandomPlayerSpawn()
    if type(playerSpawns) == "table" and #playerSpawns > 0 then
        return playerSpawns[math.random(#playerSpawns)]
    end

    return playerSpawn
end

local function setPlayerSpawnProtection(playerElement, state)
    setElementFrozen(playerElement, state)

    local freeroamResource = getResourceFromName("freeroam")

    if freeroamResource and getResourceState(freeroamResource) == "running" then
        call(freeroamResource, "setPlayerPassiveMode", playerElement, state)
    end
end

function playSpawnPlayer(playerElement)
    if not isElement(playerElement) then
        return false
    end

    initPlayerStats(playerElement)
    fadeCamera(playerElement, false, PLAYER_FADE_TIME_SECONDS)

    local spawnData = getRandomPlayerSpawn()

    -- SPAWN POSITION
    spawnPlayer(
        playerElement,
        spawnData.x,
        spawnData.y,
        spawnData.z,
        spawnData.rotation or playerSpawn.rotation,
        spawnData.skin or playerSpawn.skin,
        0,
        0,
        nil
    )

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

-- ==========================================
-- PLAYER EVENTS
-- ==========================================
function onPlayerJoin()
    initPlayerStats(source)
    playMessage(source, "joinWelcome")
    playMessage(source, "joinHelp")
    playSpawnPlayer(source)
end

function onPlayerWasted(totalAmmo, killerElement)
    onPlayerStatsWasted(killerElement)
    setTimer(playSpawnPlayer, PLAYER_RESPAWN_DELAY_MS, 1, source)
end

function onPlayerQuit()
    stopPlayerNotifications(source)
    destroyPlayerVehicles(source)
end
