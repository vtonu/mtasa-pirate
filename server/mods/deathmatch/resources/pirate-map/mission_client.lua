local active = false
local targetBlip
local pressedThisVisit = false
local blinkTimer
local blinkVisible = true
local parachutePrompt = false
local rooftopBlip
local rooftopPrompt = false
local hunterVehicle

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

local function atAiryard()
    if isPedDead(localPlayer) or isPedInVehicle(localPlayer) then return false end
    if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return false end
    local x, y, z = getElementPosition(localPlayer)
    return getDistanceBetweenPoints3D(x, y, z, 2024, 1437.6, 10.3) < 1.5
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
    parachutePrompt = false
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
    parachutePrompt = true
    stopBlinking()
end)

bindKey("h", "down", function()
    if parachutePrompt and atAiryard() and not isChatBoxInputActive() and not isConsoleActive() and not isMainMenuActive() then
        triggerServerEvent("airyard:parachute", resourceRoot)
    end
end)

local function attachHunterBlip(vehicle)
    hunterVehicle = vehicle
    if isElement(rooftopBlip) then destroyElement(rooftopBlip) end
    if isElement(vehicle) then rooftopBlip = createBlipAttachedTo(vehicle, 19, 2, 255, 80, 80, 255) end
end

addEvent("airyard:parachuteReady", true)
addEventHandler("airyard:parachuteReady", resourceRoot, function(vehicle)
    parachutePrompt = false
    attachHunterBlip(vehicle)
end)

addEvent("airyard:reset", true)
addEventHandler("airyard:reset", resourceRoot, function()
    active = false
    parachutePrompt = false
    pressedThisVisit = false
    stopBlinking()
    if isElement(targetBlip) then destroyElement(targetBlip) end
    targetBlip = nil
    attachHunterBlip(nil)
end)

addEvent("airyard:hunterReady", true)
addEventHandler("airyard:hunterReady", resourceRoot, function(vehicle)
    attachHunterBlip(vehicle)
end)

addEvent("airyard:hunterGone", true)
addEventHandler("airyard:hunterGone", resourceRoot, function()
    hunterVehicle = nil
    if isElement(rooftopBlip) then destroyElement(rooftopBlip) end
    rooftopBlip = nil
end)

addEventHandler("onClientRender", root, function()
    if not atDesk() then
        pressedThisVisit = false
        if not parachutePrompt or not atAiryard() then return end
    end
    showAiryard()
    if pressedThisVisit then return end
    local w, h = guiGetScreenSize()
    local width = math.min(420, w - 32)
    local left, top = (w - width) / 2, h * 0.82
    if parachutePrompt and atAiryard() then
        dxDrawRectangle(left, top, width, 48, tocolor(235, 245, 250, 32))
        dxDrawText("PRESS [H] TO EQUIP PARACHUTE", left + 12, top, left + width - 12, top + 48,
            tocolor(248, 252, 255, 238), 1.05, "default", "center", "center", false, false, false, true)
        return
    end
    dxDrawRectangle(left, top, width, 48, tocolor(235, 245, 250, 32))
    dxDrawText("PRESS [H] TO START", left + 13, top + 1, left + width - 11, top + 49,
        tocolor(20, 28, 32, 70), 1.05, "default", "center", "center", false, false, false, true)
    dxDrawText("PRESS [H] TO START", left + 12, top, left + width - 12, top + 48,
        tocolor(248, 252, 255, 238), 1.05, "default", "center", "center", false, false, false, true)
end)
