local active = false
local targetBlip

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
    if active or not atDesk() or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() then return end
    triggerServerEvent("airyard:start", resourceRoot)
end)

addEvent("airyard:started", true)
addEventHandler("airyard:started", resourceRoot, function()
    active = true
    showAiryard()
end)

addEvent("airyard:finished", true)
addEventHandler("airyard:finished", resourceRoot, function()
    active = false
end)

addEventHandler("onClientRender", root, function()
    if not atDesk() then return end
    showAiryard()
    if active then return end
    local w, h = guiGetScreenSize()
    local width = math.min(420, w - 32)
    local left, top = (w - width) / 2, h * 0.82
    dxDrawRectangle(left, top, width, 48, tocolor(5, 18, 16, 194))
    dxDrawText("PRESS [H] TO START", left + 12, top, left + width - 12, top + 48,
        tocolor(230, 255, 246, 255), 1.15, "default-bold", "center", "center")
end)
