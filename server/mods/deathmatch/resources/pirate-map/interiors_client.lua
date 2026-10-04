local rooms = {
    {id = "ammuBlueberry", entrances = {"ammuNationRedCounty", "ammuNationRedCounty2", "ammuNationRedCounty3", "ammuNationRedCounty4"}, exitID = "ammuBlueberryExitMarker"},
    {id = "ammuPalomino", entrances = {"palaminoAmmuFront", "palaminoAmmuBackdoor"}, exitID = "ammuPalominoExitMarker"},
    {id = "ammuMC", entrances = {"ammuNationMC", "ammuNationMC2"}, exitID = "ammuMCExitMarker"},
    {id = "ammuNorthLV", entrances = {"ammuNationNorthLV", "ammuNationNorthLV2", "ammuNationNorthLV3"}, exitID = "ammuNorthLVExitMarker"},
    {id = "ammuOld", entrances = {"markerAmmuOld", "markerAmmuOld2", "markerAmmuOld3"}, exitID = "ammuOldExitMarker"},
    {id = "ammuLS", entrances = {"ammuNationLSOG"}, exitID = "ammuLSExitMarker"},
    {id = "ammuSouthLS", entrances = {"ammuNationSouthLS"}, exitID = "ammuSouthLSExitMarker"},
    {id = "ammuSouthLSRange", entrances = {"ammuSouthLSRangeEntrance"}, exitID = "ammuSouthLSRangeExit"},
    {id = "ammuSouthLSFloor", entrances = {"ammuSouthLSFloorEntrance"}, exitID = "ammuSouthLSFloorExit"},
    {id = "ammuTRRange", entrances = {"ammuTRRangeEntrance"}, exitID = "ammuTRRangeExit"},
    {id = "ammuTRFloor", entrances = {"ammuTRFloorEntrance"}, exitID = "ammuTRFloorExit"},
    {id = "ammuSF", entrances = {"ammuNationSF"}, exitID = "ammuSFExitMarker"},
    {id = "ammuTR", entrances = {"ammuNationTR"}, exitID = "ammuTRExitMarker"},
    {id = "ammuBC", entrances = {"ammuNationBCEntrance", "ammuNationBCBackdoor"}, exitID = "ammuBCExitMarker"},
    {id = "ammuBCRange", entrances = {"ammuBCRangeEntrance"}, exitID = "ammuBCRangeExit"},
    {id = "ammuBCFloor", entrances = {"ammuBCFloorEntrance"}, exitID = "ammuBCFloorExit"},
    {id = "ammuEastBC", entrances = {"ammuNationEastBCFront", "ammuNationEastBCBackdoor"}, exitID = "ammuEastBCExitMarker"},
    {id = "royal", entrances = {"royalCasinoMarker", "royalCasinoMarker2", "royalCasinoMarker3", "royalCasinoMarker4"}, exitID = "royalCasinoExitMarker"},
    {id = "highRoller", entrances = {"theHighRollerMarker"}, exitID = "highRollerExitMarker"},
    {id = "highRollerLounge", entrances = {"markerHighRollerLounge"}, exitID = "highRollerLoungeExitMarker"},
    {id = "caligula", entrances = {"mainCasinoSpawn"}, exitID = "caligulaExitMarker"},
    {id = "camelToe", entrances = {"markerCamelEntrance"}, exitID = "camelToeExitMarker"},
    {id = "autoBahn", entrances = {"markerAutoBahn"}, exitID = "autoBahnExitMarker"},
    {id = "covealot", entrances = {"markerCovealot"}, exitID = "covealotExitMarker"},
    {id = "cjHouse", entrances = {"markerCJHouse"}, exitID = "cjHouseExitMarker"}
}
local casinoMarkers = {}
local nextDoorTick = 0

local function getNearbyDoor()
    if isPedDead(localPlayer) or getPedOccupiedVehicle(localPlayer)
        or isCursorShowing() or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() then return end
    local doors = {}
    for _, room in ipairs(rooms) do
        if not isElement(casinoMarkers[room.exitID]) then casinoMarkers[room.exitID] = getElementByID(room.exitID) end
        local distance = (room.id == "ammuBCRange" or room.id == "ammuBCFloor"
            or room.id == "ammuTR" or room.id == "ammuTRRange"
            or room.id == "ammuTRFloor" or room.id == "ammuSouthLS"
            or room.id == "ammuSouthLSRange" or room.id == "ammuSouthLSFloor") and 0.7 or 1.8
        doors[#doors + 1] = {casinoMarkers[room.exitID], "exit", room.id, distance}
        for _, id in ipairs(room.entrances) do
            if not isElement(casinoMarkers[id]) then casinoMarkers[id] = getElementByID(id) end
            doors[#doors + 1] = {casinoMarkers[id], "enter", room.id, distance}
        end
    end
    local x, y, z = getElementPosition(localPlayer)
    local nearestDoor, nearestDistance
    for _, door in ipairs(doors) do
        local marker = door[1]
        if isElement(marker) and getElementDimension(localPlayer) == getElementDimension(marker)
            and getElementInterior(localPlayer) == getElementInterior(marker) then
            local mx, my, mz = getElementPosition(marker)
            local side = getElementData(marker, "pirate.doorSide")
            local distance = getDistanceBetweenPoints2D(x, y, mx, my)
            if distance <= (getElementData(marker, "pirate.doorDistance") or door[4]) and math.abs(z - mz) <= 2
                and (not side or (y - side.y) * side.sign > 0)
                and (not nearestDistance or distance < nearestDistance) then
                nearestDoor, nearestDistance = door, distance
            end
        end
    end
    if nearestDoor then return nearestDoor[2], nearestDoor[3] end
end

bindKey("h", "down", function()
    local door, roomID = getNearbyDoor()
    if not door or getTickCount() < nextDoorTick then return end
    nextDoorTick = getTickCount() + 1500
    triggerServerEvent("royalCasino:useDoor", resourceRoot, door, roomID)
end)

-- ROYAL CASINO DOOR PROMPT
addEventHandler("onClientRender", root, function()
    local door = getNearbyDoor()
    if not door then return end

    local w, h = guiGetScreenSize()
    local width = math.min(420, w - 32)
    local left, top = (w - width) / 2, h * 0.82
    local prompt = door == "exit" and "PRESS [H] TO EXIT" or "PRESS [H] TO ENTER"
    local font = "unifont"
    local scale = math.min(1, (width - 32) / dxGetTextWidth(prompt, 1, font))
    dxDrawRectangle(left, top, width, 48, tocolor(16, 35, 34, 124))
    dxDrawRectangle(left, top, width, 1, tocolor(220, 255, 239, 55))
    dxDrawRectangle(left, top, 2, 48, tocolor(127, 255, 212, 200))
    dxDrawText(prompt, left + 12, top, left + width - 12, top + 48,
        tocolor(238, 255, 247, 245), scale, font, "center", "center", false, false, false, false)
end)
