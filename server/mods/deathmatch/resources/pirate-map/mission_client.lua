local active = false
local targetBlip
local pressedThisVisit = false
local blinkTimer
local blinkVisible = true

local function stopBlinking()
    if isTimer(blinkTimer) then killTimer(blinkTimer) end
    blinkTimer = nil
    blinkVisible = true
    if isElement(targetBlip) then setBlipVisibleDistance(targetBlip, 16383) end
end

local function atDesk()
    local zone = getElementData(resourceRoot, "airyard:desk")
    return isElement(zone) and not isPedDead(localPlayer) and not isPedInVehicle(localPlayer)
        and getElementDimension(localPlayer) == 0 and getElementInterior(localPlayer) == 0
        and isElementWithinColShape(localPlayer, zone)
end

local function showAiryard()
    if isElement(targetBlip) then return end
    local target = getElementData(resourceRoot, "airyard:target")
    if type(target) ~= "table" then return end
    targetBlip = createBlip(target[1], target[2], target[3], 5, 2, 255, 255, 255, 255)
    setElementData(targetBlip, "blipName", "Airyard", false)
end

bindKey("h", "down", function()
    if pressedThisVisit or not atDesk() or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() then return end
    triggerServerEvent("airyard:start", resourceRoot)
end)

addEvent("airyard:started", true)
addEventHandler("airyard:started", resourceRoot, function()
    active = true
    pressedThisVisit = atDesk()
    showAiryard()
    stopBlinking()
    blinkTimer = setTimer(function()
        if not active or not isElement(targetBlip) then return end
        blinkVisible = not blinkVisible
        setBlipVisibleDistance(targetBlip, blinkVisible and 16383 or 0)
    end, 600, 0)
end)

addEvent("airyard:finished", true)
addEventHandler("airyard:finished", resourceRoot, function()
    active = false
    stopBlinking()
end)

addEventHandler("onClientRender", root, function()
    if not atDesk() then
        pressedThisVisit = false
        return
    end
    showAiryard()
    if pressedThisVisit then return end
    local w, h = guiGetScreenSize()
    local width = math.min(420, w - 32)
    local left, top = (w - width) / 2, h * 0.82
    dxDrawRectangle(left, top, width, 48, tocolor(235, 245, 250, 38))
    dxDrawRectangle(left, top, width, 1, tocolor(255, 255, 255, 55))
    dxDrawText("PRESS [H] TO START", left + 13, top + 1, left + width - 11, top + 49,
        tocolor(0, 0, 0, 130), 1.15, "default-bold", "center", "center")
    dxDrawText("PRESS [H] TO START", left + 12, top, left + width - 12, top + 48,
        tocolor(230, 255, 246, 255), 1.15, "default-bold", "center", "center")
end)
