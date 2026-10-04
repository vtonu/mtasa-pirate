local rooms = {
    ammuBlueberry = {
        entrances = {"ammuNationRedCounty", "ammuNationRedCounty2", "ammuNationRedCounty3", "ammuNationRedCounty4"},
        exitID = "ammuBlueberryExitMarker", interior = 6, dimension = 12029,
        x = 296.95419, y = -111.67903, z = 1001.51562, spawnX = 297.446, spawnY = -107.468, rotation = 0,
        blip = "ammuNationRedCounty", blipIcon = 6
    },
    ammuPalomino = {
        entrances = {"palaminoAmmuFront", "palaminoAmmuBackdoor"},
        exitID = "ammuPalominoExitMarker", interior = 6, dimension = 12030,
        x = 296.77710, y = -111.76501, z = 1001.51562, spawnX = 297.446, spawnY = -107.468, rotation = 0,
        blip = "palaminoAmmuFront", blipIcon = 6
    },
    ammuMC = {
        entrances = {"ammuNationMC", "ammuNationMC2"},
        exitID = "ammuMCExitMarker", interior = 6, dimension = 12028,
        x = 296.81174, y = -111.54875, z = 1001.51562, spawnX = 297.446, spawnY = -107.468, rotation = 0,
        blip = "ammuNationMC", blipIcon = 6
    },
    ammuNorthLV = {
        entrances = {"ammuNationNorthLV", "ammuNationNorthLV2", "ammuNationNorthLV3"},
        exitID = "ammuNorthLVExitMarker", interior = 6, dimension = 12027,
        x = 296.83090, y = -111.87682, z = 1001.51562, spawnX = 297.446, spawnY = -107.468, rotation = 0,
        blip = "ammuNationNorthLV", blipIcon = 6
    },
    ammuOld = {
        entrances = {"markerAmmuOld", "markerAmmuOld2", "markerAmmuOld3"},
        exitID = "ammuOldExitMarker", interior = 6, dimension = 12020,
        x = 297.446, y = -109.968, z = 1001.516, spawnX = 297.446, spawnY = -107.468, rotation = 0,
        blip = "markerAmmuOld", blipIcon = 6
    },
    ammuLS = {
        entrances = {"ammuNationLSOG"},
        exitID = "ammuLSExitMarker", interior = 6, dimension = 12021,
        x = 296.81174, y = -111.54875, z = 1001.51562, spawnX = 297.446, spawnY = -107.468, rotation = 0,
        blip = "ammuNationLSOG", blipIcon = 6
    },
    ammuSouthLS = {
        entrances = {"ammuNationSouthLS"},
        exitID = "ammuSouthLSExitMarker", interior = 1, dimension = 12022,
        x = 285.73962, y = -41.18461, z = 1001.51562, spawnX = 285.73962, spawnY = -39.68461, rotation = 0,
        blip = "ammuNationSouthLS", blipIcon = 6
    },
    ammuSouthLSRange = {
        entrances = {"ammuSouthLSRangeEntrance"}, exitID = "ammuSouthLSRangeExit",
        interior = 1, dimension = 12022, internal = true,
        entranceX = 286.12119, entranceY = -30.32537, entranceZ = 1001.51562,
        x = 286.12119, y = -28.32537, z = 1001.51562,
        spawnX = 286.12119, spawnY = -27.32537, rotation = 0,
        returnPoint = {x = 286.12119, y = -31.32537, z = 1001.51562,
            rotation = 180, interior = 1, dimension = 12022}
    },
    ammuSouthLSFloor = {
        entrances = {"ammuSouthLSFloorEntrance"}, exitID = "ammuSouthLSFloorExit",
        interior = 1, dimension = 12022, internal = true,
        entranceX = 285.95078, entranceY = -24.79792, entranceZ = 1001.51562,
        x = 286.11548, y = -23.34547, z = 1001.52295,
        spawnX = 286.11548, spawnY = -22.34547, rotation = 0,
        returnPoint = {x = 286.18500, y = -26.52018, z = 1001.51562,
            rotation = 180, interior = 1, dimension = 12022}
    },
    ammuTRRange = {
        entrances = {"ammuTRRangeEntrance"}, exitID = "ammuTRRangeExit",
        interior = 1, dimension = 12024, internal = true,
        entranceX = 286.12119, entranceY = -30.32537, entranceZ = 1001.51562,
        x = 286.12119, y = -28.32537, z = 1001.51562,
        spawnX = 286.12119, spawnY = -27.32537, rotation = 0,
        returnPoint = {x = 286.12119, y = -31.32537, z = 1001.51562,
            rotation = 180, interior = 1, dimension = 12024}
    },
    ammuTRFloor = {
        entrances = {"ammuTRFloorEntrance"}, exitID = "ammuTRFloorExit",
        interior = 1, dimension = 12024, internal = true,
        entranceX = 285.95078, entranceY = -24.79792, entranceZ = 1001.51562,
        x = 286.11548, y = -23.34547, z = 1001.52295,
        spawnX = 286.11548, spawnY = -22.34547, rotation = 0,
        returnPoint = {x = 286.18500, y = -26.52018, z = 1001.51562,
            rotation = 180, interior = 1, dimension = 12024}
    },
    ammuSF = {
        entrances = {"ammuNationSF"},
        exitID = "ammuSFExitMarker", interior = 6, dimension = 12023,
        x = 296.98688, y = -111.82021, z = 1001.51562, spawnX = 297.446, spawnY = -107.468, rotation = 0,
        blip = "ammuNationSF", blipIcon = 6
    },
    ammuTR = {
        entrances = {"ammuNationTR"},
        exitID = "ammuTRExitMarker", interior = 1, dimension = 12024,
        x = 285.73962, y = -41.18461, z = 1001.51562, spawnX = 285.73962, spawnY = -39.68461, rotation = 0,
        blip = "ammuNationTR", blipIcon = 6
    },
    ammuBC = {
        entrances = {"ammuNationBCEntrance", "ammuNationBCBackdoor"},
        exitID = "ammuBCExitMarker", interior = 7, dimension = 12025,
        x = 315.83853, y = -143.35983, z = 999.60156, spawnX = 315.385, spawnY = -139.742, rotation = 0,
        blip = "ammuNationBCEntrance", blipIcon = 6
    },
    ammuBCRange = {
        entrances = {"ammuBCRangeEntrance"}, exitID = "ammuBCRangeExit",
        interior = 7, dimension = 12025, internal = true,
        entranceX = 305.58911, entranceY = -141.97321, entranceZ = 1004.06250,
        x = 304.31448, y = -141.94641, z = 1004.06250,
        spawnX = 301.5, spawnY = -141.97321, rotation = 90,
        returnPoint = {x = 306.5, y = -141.97321, z = 1004.06250,
            rotation = 270, interior = 7, dimension = 12025}
    },
    ammuBCFloor = {
        entrances = {"ammuBCFloorEntrance"}, exitID = "ammuBCFloorExit",
        interior = 7, dimension = 12025, internal = true,
        entranceX = 299.94708, entranceY = -141.97240, entranceZ = 1004.06250,
        x = 298.44708, y = -141.97240, z = 1004.06250,
        spawnX = 294.94708, spawnY = -141.97240, rotation = 90,
        returnPoint = {x = 300.74708, y = -141.97240, z = 1004.06250,
            rotation = 270, interior = 7, dimension = 12025}
    },
    ammuEastBC = {
        entrances = {"ammuNationEastBCFront", "ammuNationEastBCBackdoor"},
        exitID = "ammuEastBCExitMarker", interior = 6, dimension = 12026,
        x = 316.48804, y = -170.08716, z = 999.59375, spawnX = 317.238, spawnY = -165.552, rotation = 0,
        blip = "ammuNationEastBCFront", blipIcon = 6
    },
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
        x = 2018.95, y = 1017.09, z = 996.875, spawnX = 2015.95, spawnY = 1017.09, rotation = 90,
        blip = "markerCamelEntrance"
    },
    autoBahn = {
        entrances = {"markerAutoBahn"},
        exitID = "autoBahnExitMarker", interior = 3, dimension = 12017,
        x = 620.06232, y = -120.61650, z = 998.84753, spawnX = 617.06232, spawnY = -120.61650, rotation = 90
    },
    cjHouse = {
        entrances = {"markerCJHouse"},
        exitID = "cjHouseExitMarker", interior = 3, dimension = 12019,
        x = 2496.05, y = -1692.73, z = 1014.75, spawnX = 2496.05, spawnY = -1695.73, rotation = 180,
        blip = "markerCJHouse", blipIcon = 15
    },
    covealot = {
        entrances = {"markerCovealot"},
        exitID = "covealotExitMarker", interior = 12, dimension = 12018,
        x = 1133.25, y = -15.26, z = 1000.68, spawnX = 1133.25, spawnY = -12.76, rotation = 0,
        blip = "markerCovealot"
    }
}
local sidedMarkers = {}
for _, id in ipairs({"ammuSouthLSRange", "ammuSouthLSFloor", "ammuTRRange", "ammuTRFloor"}) do
    rooms[id].doorY = (rooms[id].entranceY + rooms[id].y) / 2
    rooms[id].markerSize = 0.6
end

local function setDoorSide(marker, room, sign)
    if not isElement(marker) or not room.doorY then return end
    local rangeRoom = room.dimension == 12022 and rooms.ammuSouthLSRange or rooms.ammuTRRange
    local floorRoom = room.dimension == 12022 and rooms.ammuSouthLSFloor or rooms.ammuTRFloor
    local side = {y = room.doorY, sign = sign}
    if room == rangeRoom and sign == 1 then side.maxY = floorRoom.doorY end
    if room == floorRoom and sign == -1 then side.minY = rangeRoom.doorY end
    setElementData(marker, "pirate.doorSide", side)
    setElementVisibleTo(marker, root, false)
    sidedMarkers[#sidedMarkers + 1] = marker
end

local returnPoints = {}
local doorCooldowns = {}
local doorTransitions = {}

local function isNearDoor(player, marker, roomID)
    if not isElement(marker) or isPedDead(player) or getPedOccupiedVehicle(player) then return false end
    if getElementDimension(player) ~= getElementDimension(marker)
        or getElementInterior(player) ~= getElementInterior(marker) then return false end
    local x, y, z = getElementPosition(player)
    local side = getElementData(marker, "pirate.doorSide")
    if side and (y - side.y) * side.sign <= 0 then return false end
    local mx, my, mz = getElementPosition(marker)
    local room = rooms[roomID]
    local distance = getElementData(marker, "pirate.doorDistance")
        or ((room and room.internal or roomID == "ammuTR" or roomID == "ammuSouthLS") and 0.7 or 1.8)
    return getDistanceBetweenPoints2D(x, y, mx, my) <= distance and math.abs(z - mz) <= 2
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
        if not isElement(player) or not isNearDoor(player, marker, roomID) then
            clearDoorTransition(player)
            return
        end
        returnPlayer(player, destination)
        if not rooms[roomID].internal then
            returnPoints[player] = entering and origin or nil
        end
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
    -- BLOCK THE GARAGE SHUTTER WITHOUT COVERING THE EXIT MARKER
    local barrier = createObject(3095, 621.8, -125.390625, 1001, 0, 90, 0)
    if isElement(barrier) then
        setElementID(barrier, "autoBahnShutterBarrier")
        setElementInterior(barrier, rooms.autoBahn.interior)
        setElementDimension(barrier, rooms.autoBahn.dimension)
        setElementAlpha(barrier, 0)
        setElementFrozen(barrier, true)
        setElementCollisionsEnabled(barrier, true)
    end
    for _, room in pairs(rooms) do
        if room.internal then
            local marker = createMarker(room.entranceX, room.entranceY, room.entranceZ + 0.6,
                "arrow", room.markerSize or 0.6, 4, 210, 193, 255)
            if isElement(marker) then
                setElementID(marker, room.entrances[1])
                setElementInterior(marker, room.interior)
                setElementDimension(marker, room.dimension)
                setElementData(marker, "pirate.doorDistance", 0.7)
                setDoorSide(marker, room, -1)
            end
        end
        local entrance = room.blip and getElementByID(room.blip)
        if isElement(entrance) then
            local blip = createBlipAttachedTo(entrance, room.blipIcon or 44, 2, 255, 255, 255, 255, 0, 65535)
            if isElement(blip) then
                setElementInterior(blip, getElementInterior(entrance))
                setElementDimension(blip, getElementDimension(entrance))
            end
        end
        room.exitMarker = createMarker(room.x, room.y, room.z + 0.6, "arrow", room.markerSize or 0.6, 4, 210, 193, 255)
        if isElement(room.exitMarker) then
            setElementID(room.exitMarker, room.exitID)
            setElementInterior(room.exitMarker, room.interior)
            setElementDimension(room.exitMarker, room.dimension)
            setElementData(room.exitMarker, "pirate.doorDistance", 0.7)
            setDoorSide(room.exitMarker, room, 1)
        end
    end
    setTimer(function()
        for _, player in ipairs(getElementsByType("player")) do
            local _, y = getElementPosition(player)
            for _, marker in ipairs(sidedMarkers) do
                local side = getElementData(marker, "pirate.doorSide")
                local visible = getElementInterior(player) == getElementInterior(marker)
                    and getElementDimension(player) == getElementDimension(marker)
                    and (y - side.y) * side.sign > 0
                    and (not side.minY or y > side.minY)
                    and (not side.maxY or y < side.maxY)
                if isElementVisibleTo(marker, player) ~= visible then
                    setElementVisibleTo(marker, player, visible)
                end
            end
        end
    end, 150, 0)
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
            if isNearDoor(client, marker, roomID) then
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
        local point = room.internal and room.returnPoint or returnPoints[client]
        if not isNearDoor(client, room.exitMarker, roomID) then return end
        if not point or (not room.internal and point.roomID ~= roomID) then return end
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
