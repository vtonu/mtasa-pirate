local rooms = {
    {id = "ammuNorthLV", entrances = {"ammuNationNorthLV", "ammuNationNorthLV2", "ammuNationNorthLV3"}, exitID = "ammuNorthLVExitMarker"},
    {id = "ammuOld", entrances = {"markerAmmuOld", "markerAmmuOld2", "markerAmmuOld3"}, exitID = "ammuOldExitMarker"},
    {id = "ammuLS", entrances = {"ammuNationLSOG"}, exitID = "ammuLSExitMarker"},
    {id = "ammuSouthLS", entrances = {"ammuNationSouthLS"}, exitID = "ammuSouthLSExitMarker"},
    {id = "ammuSF", entrances = {"ammuNationSF"}, exitID = "ammuSFExitMarker"},
    {id = "ammuTR", entrances = {"ammuNationTR"}, exitID = "ammuTRExitMarker"},
    {id = "ammuBC", entrances = {"ammuNationBC"}, exitID = "ammuBCExitMarker"},
    {id = "ammuEastBC", entrances = {"ammuNationEastBC"}, exitID = "ammuEastBCExitMarker"},
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
        doors[#doors + 1] = {casinoMarkers[room.exitID], "exit", room.id}
        for _, id in ipairs(room.entrances) do
            if not isElement(casinoMarkers[id]) then casinoMarkers[id] = getElementByID(id) end
            doors[#doors + 1] = {casinoMarkers[id], "enter", room.id}
        end
    end
    local x, y, z = getElementPosition(localPlayer)
    for _, door in ipairs(doors) do
        local marker = door[1]
        if isElement(marker) and getElementDimension(localPlayer) == getElementDimension(marker)
            and getElementInterior(localPlayer) == getElementInterior(marker) then
            local mx, my, mz = getElementPosition(marker)
            if getDistanceBetweenPoints2D(x, y, mx, my) <= 1.8 and math.abs(z - mz) <= 2 then
                return door[2], door[3]
            end
        end
    end
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
