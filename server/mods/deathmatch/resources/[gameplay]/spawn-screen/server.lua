-- ==========================================
-- SPAWN SCREEN
-- ==========================================
local waitingPlayers = {}
local fadeTime = 1

function isWaitingForSpawn(player)
    return waitingPlayers[player] ~= nil
end

local function restorePlayer(player, data)
    setElementData(player, "spawnScreen:waiting", false)
    setElementCollisionsEnabled(player, data.collisions)
    setElementAlpha(player, data.alpha)
    setElementFrozen(player, data.frozen)
    setElementPosition(player, data.px, data.py, data.pz)
    toggleAllControls(player, true)
end

function showSpawnScreen(player, x, y, z)
    if not isElement(player) or getElementType(player) ~= "player" or waitingPlayers[player] then
        return false
    end

    local px, py, pz = getElementPosition(player)
    waitingPlayers[player] = {x = x, y = y, z = z, px = px, py = py, pz = pz,
        collisions = getElementCollisionsEnabled(player), alpha = getElementAlpha(player), frozen = isElementFrozen(player)}
    setElementData(player, "spawnScreen:waiting", true)
    setElementFrozen(player, true)
    setElementCollisionsEnabled(player, false)
    setElementAlpha(player, 0)
    setElementPosition(player, x, y, z + 1000)
    toggleAllControls(player, false)
    setCameraMatrix(player, x - 45, y - 25, z + 28, x - 5, y + 5, z)
    fadeCamera(player, true, fadeTime)
    triggerClientEvent(player, "spawnScreenShow", resourceRoot, x, y, z)
    return true
end

addEvent("spawnScreenClientReady", true)
addEventHandler("spawnScreenClientReady", resourceRoot, function()
    if source ~= resourceRoot or not client then return end
    local data = waitingPlayers[client]
    if not data or data.spawning then
        return
    end

    local now = getTickCount()
    if data.lastReady and now - data.lastReady < 2000 then return end
    data.lastReady = now
    triggerClientEvent(client, "spawnScreenShow", resourceRoot, data.x, data.y, data.z)
end)

addEvent("spawnScreenRequest", true)
addEventHandler("spawnScreenRequest", resourceRoot, function()
    if source ~= resourceRoot or not client then return end
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
        restorePlayer(player, data)
        triggerClientEvent(player, "spawnScreenHide", resourceRoot)
        triggerEvent("spawnScreenSpawn", player)
    end, fadeTime * 1000, 1)
end)

addEventHandler("onPlayerCommand", root, function()
    if waitingPlayers[source] then cancelEvent() end
end)
addEventHandler("onPlayerChat", root, function()
    if waitingPlayers[source] then cancelEvent() end
end)
addEventHandler("onVehicleStartEnter", root, function(player)
    if waitingPlayers[player] then cancelEvent() end
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
            restorePlayer(player, data)
            triggerEvent("spawnScreenSpawn", player)
        end
    end
end)
