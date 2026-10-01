-- ==========================================
-- SPAWN SCREEN
-- ==========================================
local waitingPlayers = {}
local fadeTime = 1

function showSpawnScreen(player, x, y, z)
    if not isElement(player) then
        return false
    end

    waitingPlayers[player] = {x = x, y = y, z = z}
    toggleAllControls(player, false)
    setCameraMatrix(player, x - 45, y - 25, z + 28, x - 5, y + 5, z)
    fadeCamera(player, true, fadeTime)
    triggerClientEvent(player, "spawnScreenShow", resourceRoot, x, y, z)
    return true
end

addEvent("spawnScreenClientReady", true)
addEventHandler("spawnScreenClientReady", resourceRoot, function()
    local data = waitingPlayers[client]
    if not data or data.spawning then
        return
    end

    triggerClientEvent(client, "spawnScreenShow", resourceRoot, data.x, data.y, data.z)
end)

addEvent("spawnScreenRequest", true)
addEventHandler("spawnScreenRequest", resourceRoot, function()
    local player = client
    local data = waitingPlayers[player]
    if not data or data.spawning then
        return
    end

    data.spawning = true
    fadeCamera(player, false, fadeTime)
    data.timer = setTimer(function()
        if not isElement(player) or waitingPlayers[player] ~= data then
            return
        end

        waitingPlayers[player] = nil
        triggerClientEvent(player, "spawnScreenHide", resourceRoot)
        toggleAllControls(player, true)
        triggerEvent("spawnScreenSpawn", player)
    end, fadeTime * 1000, 1)
end)

addEventHandler("onPlayerQuit", root, function()
    local data = waitingPlayers[source]
    if data and isTimer(data.timer) then
        killTimer(data.timer)
    end
    waitingPlayers[source] = nil
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for player, data in pairs(waitingPlayers) do
        if isTimer(data.timer) then
            killTimer(data.timer)
        end
        if isElement(player) then
            toggleAllControls(player, true)
            triggerEvent("spawnScreenSpawn", player)
        end
    end
end)
