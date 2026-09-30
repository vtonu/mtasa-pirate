local entranceIDs = {"royalCasinoMarker", "royalCasinoMarker2", "royalCasinoMarker3", "royalCasinoMarker4"}
local casinoMarkers = {}
local exitMarker
local nextDoorTick = 0

local function getNearbyDoor()
    if isPedDead(localPlayer) or getPedOccupiedVehicle(localPlayer)
        or isCursorShowing() or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() then return end
    if not isElement(exitMarker) then exitMarker = getElementByID("royalCasinoExitMarker") end
    local doors = {{exitMarker, "exit"}}
    for _, id in ipairs(entranceIDs) do
        if not isElement(casinoMarkers[id]) then casinoMarkers[id] = getElementByID(id) end
        doors[#doors + 1] = {casinoMarkers[id], "enter"}
    end
    local x, y, z = getElementPosition(localPlayer)
    for _, door in ipairs(doors) do
        local marker = door[1]
        if isElement(marker) and getElementDimension(localPlayer) == getElementDimension(marker)
            and getElementInterior(localPlayer) == getElementInterior(marker) then
            local mx, my, mz = getElementPosition(marker)
            if getDistanceBetweenPoints2D(x, y, mx, my) <= 1.8 and math.abs(z - mz) <= 2 then
                return door[2]
            end
        end
    end
end

bindKey("h", "down", function()
    local door = getNearbyDoor()
    if not door or getTickCount() < nextDoorTick then return end
    nextDoorTick = getTickCount() + 1500
    triggerServerEvent("royalCasino:useDoor", resourceRoot, door)
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
