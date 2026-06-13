-- ==========================================
-- PLAYER SPAWN
-- ==========================================
function playSpawnPlayer(playerElement)
    if not isElement(playerElement) then
        return false
    end

    initPlayerStats(playerElement)

    -- SPAWN POSITION
    spawnPlayer(
    playerElement,
    playerSpawn.x,
    playerSpawn.y,
    playerSpawn.z,
    playerSpawn.rotation,
    playerSpawn.skin,
    0,
    0,
    nil
)

    startPlayerNotifications(playerElement)
    fadeCamera(playerElement, true)
    setCameraTarget(playerElement)
    takeAllWeapons(playerElement)

    -- Force furthest zoom level on spawn (3)
    setTimer(function(targetPlayer)
        if isElement(targetPlayer) then
            -- Loop twice to cycle past bumper/close views to the furthest view
            for i = 1, 2 do
                setControlState(targetPlayer, "change_camera", true)
                setControlState(targetPlayer, "change_camera", false)
            end
        end
    end, 50, 1, playerElement)
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

    local playerRespawnTime = get("playerRespawnTime")

    playerRespawnTime = tonumber(playerRespawnTime) or 500
    playerRespawnTime = math.max(0, playerRespawnTime)

    setTimer(playSpawnPlayer, playerRespawnTime, 1, source)
end

function onPlayerQuit()
    stopPlayerNotifications(source)
    destroyPlayerVehicles(source)
end
