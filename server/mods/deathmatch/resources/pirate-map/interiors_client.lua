local casinoMarker

-- ROYAL CASINO DOOR PROMPT
addEventHandler("onClientRender", root, function()
    if not isElement(casinoMarker) then
        casinoMarker = getElementByID("royalCasinoMarker")
    end
    if not isElement(casinoMarker) or isPedDead(localPlayer) or getPedOccupiedVehicle(localPlayer)
        or isCursorShowing() or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() then return end
    if getElementDimension(localPlayer) ~= getElementDimension(casinoMarker)
        or getElementInterior(localPlayer) ~= getElementInterior(casinoMarker) then return end

    local x, y, z = getElementPosition(localPlayer)
    local mx, my, mz = getElementPosition(casinoMarker)
    if getDistanceBetweenPoints2D(x, y, mx, my) > 1.8 or math.abs(z - mz) > 2 then return end

    local w, h = guiGetScreenSize()
    local width = math.min(420, w - 32)
    local left, top = (w - width) / 2, h * 0.82
    local prompt = "PRESS [H] TO ENTER"
    local font = "unifont"
    local scale = math.min(1, (width - 32) / dxGetTextWidth(prompt, 1, font))
    dxDrawRectangle(left, top, width, 48, tocolor(16, 35, 34, 124))
    dxDrawRectangle(left, top, width, 1, tocolor(220, 255, 239, 55))
    dxDrawRectangle(left, top, 2, 48, tocolor(127, 255, 212, 200))
    dxDrawText(prompt, left + 12, top, left + width - 12, top + 48,
        tocolor(238, 255, 247, 245), scale, font, "center", "center", false, false, false, false)
end)
