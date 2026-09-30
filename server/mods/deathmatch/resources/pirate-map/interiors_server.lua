local CASINO_INTERIOR = 12
local CASINO_DIMENSION = 12012
local EXIT_X, EXIT_Y, EXIT_Z = 1133.25, -15.26, 1000.68
local returnPoints = {}
local doorCooldowns = {}
local doorTransitions = {}
local exitMarker

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
local function useDoor(player, marker, destination, entering)
    local x, y, z = getElementPosition(player)
    local _, _, rotation = getElementRotation(player)
    local origin = {
        x = x, y = y, z = z, rotation = rotation,
        interior = getElementInterior(player), dimension = getElementDimension(player)
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

-- SHARED CASINO ROOM AND EXIT
addEventHandler("onResourceStart", resourceRoot, function()
    exitMarker = createMarker(EXIT_X, EXIT_Y, EXIT_Z + 0.6, "arrow", 1, 4, 210, 193, 255)
    if not isElement(exitMarker) then return end
    setElementID(exitMarker, "royalCasinoExitMarker")
    setElementInterior(exitMarker, CASINO_INTERIOR)
    setElementDimension(exitMarker, CASINO_DIMENSION)
end)

-- CHECK BOTH DOORS ON THE SERVER
addEvent("royalCasino:useDoor", true)
addEventHandler("royalCasino:useDoor", resourceRoot, function(door)
    if not client or source ~= resourceRoot then return end
    local now = getTickCount()
    if doorTransitions[client] or now < (doorCooldowns[client] or 0) then return end
    if door == "enter" then
        local entrance = getElementByID("royalCasinoMarker")
        if not isNearDoor(client, entrance) then return end
        useDoor(client, entrance, {
            x = EXIT_X, y = EXIT_Y + 2.5, z = EXIT_Z, rotation = 0,
            interior = CASINO_INTERIOR, dimension = CASINO_DIMENSION
        }, true)
    elseif door == "exit" then
        local point = returnPoints[client]
        if not isNearDoor(client, exitMarker) then return end
        if not point then return end
        useDoor(client, exitMarker, point, false)
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
        if isElement(player) and not isPedDead(player)
            and getElementInterior(player) == CASINO_INTERIOR
            and getElementDimension(player) == CASINO_DIMENSION then
            returnPlayer(player, point)
        end
    end
end)
