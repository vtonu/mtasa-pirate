local rooms = {
    royal = {
        entrances = {"royalCasinoMarker", "royalCasinoMarker2", "royalCasinoMarker3", "royalCasinoMarker4"},
        exitID = "royalCasinoExitMarker", interior = 12, dimension = 12012,
        x = 1133.25, y = -15.26, z = 1000.68, spawnX = 1133.25, spawnY = -12.76, rotation = 0,
        blip = "royalCasinoMarker"
    },
    highRoller = {
        entrances = {"theHighRollerMarker"},
        exitID = "highRollerExitMarker", interior = 1, dimension = 12013,
        x = 2233.94, y = 1714.58, z = 1012.39, spawnX = 2233.94, spawnY = 1711.5, rotation = 180,
        blip = "theHighRollerMarker"
    },
    highRollerLounge = {
        entrances = {"markerHighRollerLounge"},
        exitID = "highRollerLoungeExitMarker", interior = 17, dimension = 12014,
        x = 493.39, y = -24.92, z = 1000.68, spawnX = 493.39, spawnY = -21.92, rotation = 0
    },
    caligula = {
        entrances = {"mainCasinoSpawn"},
        exitID = "caligulaExitMarker", interior = 1, dimension = 12015,
        x = 2233.94, y = 1714.58, z = 1012.39, spawnX = 2233.94, spawnY = 1711.5, rotation = 180
    },
    camelToe = {
        entrances = {"markerCamelEntrance"},
        exitID = "camelToeExitMarker", interior = 10, dimension = 12016,
        x = 2018.95, y = 1017.09, z = 996.875, spawnX = 2015.95, spawnY = 1017.09, rotation = 90
    },
    autoBahn = {
        entrances = {"markerAutoBahn"},
        exitID = "autoBahnExitMarker", interior = 3, dimension = 12017,
        x = 614.389, y = -124.099, z = 997.995, spawnX = 614.389, spawnY = -121.099, rotation = 0
    }
}
local returnPoints = {}
local doorCooldowns = {}
local doorTransitions = {}

local function isNearDoor(player, marker)
    if not isElement(marker) or isPedDead(player) or getPedOccupiedVehicle(player) then return false end
    if getElementDimension(player) ~= getElementDimension(marker)
        or getElementInterior(player) ~= getElementInterior(marker) then return false end
    local x, y, z = getElementPosition(player)
    local mx, my, mz = getElementPosition(marker)
    return getDistanceBetweenPoints2D(x, y, mx, my) <= 1.8 and math.abs(z - mz) <= 2
end

local function returnPlayer(player, point)
    setElementInterior(player, point.interior)
    setElementDimension(player, point.dimension)
    setElementPosition(player, point.x, point.y, point.z)
    setElementRotation(player, 0, 0, point.rotation)
end

local function clearDoorTransition(player)
    local transition = doorTransitions[player]
    if not transition then return end
    for _, timer in ipairs(transition.timers) do
        if isTimer(timer) then killTimer(timer) end
    end
    if isElement(player) then
        setElementFrozen(player, transition.frozen)
        fadeCamera(player, true, 0.35)
    end
    doorTransitions[player] = nil
end

-- MOVE WHILE BLACK, THEN GIVE THE ROOM TIME TO LOAD
local function useDoor(player, marker, destination, entering, roomID)
    local x, y, z = getElementPosition(player)
    local _, _, rotation = getElementRotation(player)
    local origin = {
        x = x, y = y, z = z, rotation = rotation,
        interior = getElementInterior(player), dimension = getElementDimension(player), roomID = roomID
    }
    local transition = {timers = {}, frozen = isElementFrozen(player)}
    doorTransitions[player] = transition
    doorCooldowns[player] = getTickCount() + 1500
    setElementFrozen(player, true)
    fadeCamera(player, false, 0.25)
    transition.timers[1] = setTimer(function()
        if doorTransitions[player] ~= transition then return end
        if not isElement(player) or not isNearDoor(player, marker) then
            clearDoorTransition(player)
            return
        end
        returnPlayer(player, destination)
        returnPoints[player] = entering and origin or nil
        transition.timers[2] = setTimer(function()
            if doorTransitions[player] ~= transition then return end
            if not isElement(player) or isPedDead(player) then
                clearDoorTransition(player)
                return
            end
            fadeCamera(player, true, 0.35)
            transition.timers[3] = setTimer(function()
                if doorTransitions[player] ~= transition then return end
                if isElement(player) then setElementFrozen(player, transition.frozen) end
                doorTransitions[player] = nil
            end, 350, 1)
        end, 300, 1)
    end, 250, 1)
end

-- SHARED ROOMS AND EXITS
addEventHandler("onResourceStart", resourceRoot, function()
    for _, room in pairs(rooms) do
        local entrance = room.blip and getElementByID(room.blip)
        if isElement(entrance) then
            local blip = createBlipAttachedTo(entrance, 44, 2, 255, 255, 255, 255, 0, 65535)
            if isElement(blip) then
                setElementInterior(blip, getElementInterior(entrance))
                setElementDimension(blip, getElementDimension(entrance))
            end
        end
        room.exitMarker = createMarker(room.x, room.y, room.z + 0.6, "arrow", 1, 4, 210, 193, 255)
        if isElement(room.exitMarker) then
            setElementID(room.exitMarker, room.exitID)
            setElementInterior(room.exitMarker, room.interior)
            setElementDimension(room.exitMarker, room.dimension)
        end
    end
end)

-- CHECK BOTH DOORS ON THE SERVER
addEvent("royalCasino:useDoor", true)
addEventHandler("royalCasino:useDoor", resourceRoot, function(door, roomID)
    if not client or source ~= resourceRoot then return end
    roomID = roomID or "royal"
    local room = rooms[roomID]
    if not room or not isElement(room.exitMarker) then return end
    local now = getTickCount()
    if doorTransitions[client] or now < (doorCooldowns[client] or 0) then return end
    if door == "enter" then
        local entrance
        for _, id in ipairs(room.entrances) do
            local marker = getElementByID(id)
            if isNearDoor(client, marker) then
                entrance = marker
                break
            end
        end
        if not entrance then return end
        useDoor(client, entrance, {
            x = room.spawnX, y = room.spawnY, z = room.z, rotation = room.rotation,
            interior = room.interior, dimension = room.dimension
        }, true, roomID)
    elseif door == "exit" then
        local point = returnPoints[client]
        if not isNearDoor(client, room.exitMarker) then return end
        if not point or point.roomID ~= roomID then return end
        useDoor(client, room.exitMarker, point, false, roomID)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    clearDoorTransition(source)
    returnPoints[source] = nil
    doorCooldowns[source] = nil
end)

addEventHandler("onPlayerSpawn", root, function()
    clearDoorTransition(source)
    returnPoints[source] = nil
    doorCooldowns[source] = nil
end)

addEventHandler("onPlayerWasted", root, function()
    clearDoorTransition(source)
end)

-- RETURN VISITORS BEFORE THE EXIT IS REMOVED
addEventHandler("onResourceStop", resourceRoot, function()
    for player in pairs(doorTransitions) do clearDoorTransition(player) end
    for player, point in pairs(returnPoints) do
        local room = rooms[point.roomID]
        if isElement(player) and not isPedDead(player)
            and room and getElementInterior(player) == room.interior
            and getElementDimension(player) == room.dimension then
            returnPlayer(player, point)
        end
    end
end)
