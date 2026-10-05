-- EMMET DELIVERY UI
local phase, vanBlip, targetBlip, deadline, location
local notice, noticeUntil = nil, 0
local nextRequest = 0

local function clearMission()
    if isElement(vanBlip) then destroyElement(vanBlip) end
    if isElement(targetBlip) then destroyElement(targetBlip) end
    phase, vanBlip, targetBlip, deadline = nil, nil, nil, nil
    location = nil
end

local function atStart()
    local marker = getElementData(resourceRoot, "emmet:start")
    if not isElement(marker) or isPedDead(localPlayer) or isPedInVehicle(localPlayer)
        or getElementInterior(localPlayer) ~= 0 or getElementDimension(localPlayer) ~= 0 then return false end
    local x, y, z = getElementPosition(localPlayer)
    local sx, sy, sz = getElementPosition(marker)
    return getDistanceBetweenPoints3D(x, y, z, sx, sy, sz + 1) < 1.8
end

bindKey("h", "down", function()
    if phase or not atStart() or getTickCount() < nextRequest or isChatBoxInputActive()
        or isConsoleActive() or isMainMenuActive() then return end
    nextRequest = getTickCount() + 1000
    triggerServerEvent("emmet:start", resourceRoot)
end)

addEvent("emmet:state", true)
addEventHandler("emmet:state", resourceRoot, function(state, first, second, third)
    if state == "pickup" then
        clearMission()
        phase = "pickup"
        if isElement(first) then vanBlip = createBlipAttachedTo(first, 0, 2, 127, 255, 212, 255) end
        notice, noticeUntil = second, getTickCount() + 6000
        playSoundFrontEnd(42)
    elseif state == "delivery" then
        if isElement(vanBlip) then destroyElement(vanBlip) end
        vanBlip = nil
        phase = "delivery"
        deadline = getTickCount() + second * 1000
        location = third
        local x, y, z = getElementPosition(first)
        targetBlip = createBlip(x, y, z, 51)
        notice, noticeUntil = nil, 0
    elseif state == "finished" then
        clearMission()
        notice, noticeUntil = first, getTickCount() + 7000
        if second then playSoundFrontEnd(46) end
    elseif state == "notice" then
        notice, noticeUntil = first, getTickCount() + 5000
    end
end)

local function drawPanel(text, top)
    local w = guiGetScreenSize()
    local width = math.min(520, w - 32)
    local left = (w - width) / 2
    local scale = math.min(1, (width - 32) / dxGetTextWidth(text, 1, "unifont"))
    dxDrawRectangle(left, top, width, 48, tocolor(16, 35, 34, 124))
    dxDrawRectangle(left, top, width, 1, tocolor(220, 255, 239, 55))
    dxDrawRectangle(left, top, 2, 48, tocolor(127, 255, 212, 200))
    dxDrawText(text, left + 12, top, left + width - 12, top + 48,
        tocolor(238, 255, 247, 245), scale, "unifont", "center", "center")
end

local function drawMissionText(text, top)
    local w = guiGetScreenSize()
    local scale = math.min(1, (w - 32) / dxGetTextWidth(text, 1, "unifont"))
    dxDrawText(text, 16, top, w - 16, top + 32,
        tocolor(238, 255, 247, 245), scale, "unifont", "center", "center")
end

addEventHandler("onClientRender", root, function()
    local now = getTickCount()
    local w, h = guiGetScreenSize()
    if isElement(vanBlip) then setBlipVisibleDistance(vanBlip, math.floor(now / 600) % 2 == 0 and 16383 or 0) end
    if isElement(targetBlip) then setBlipVisibleDistance(targetBlip, math.floor(now / 600) % 2 == 0 and 16383 or 0) end
    if phase == "delivery" and deadline then
        local seconds = math.max(0, math.ceil((deadline - now) / 1000))
        dxDrawText(string.format("DELIVERY TIME: %02d:%02d", math.floor(seconds / 60), seconds % 60),
            16, h * 0.88, w - 16, h * 0.88 + 32,
            tocolor(238, 255, 247, 245), 1, "unifont", "center", "center")
        if location then
            dxDrawText("DELIVERY TO: " .. location,
                16, h * 0.88 + 24, w - 16, h * 0.88 + 56,
                tocolor(238, 255, 247, 245), 1, "unifont", "center", "center")
        end
    end
    if phase == "pickup" then
        drawMissionText(notice or "COLLECT THE DELIVERY VAN.", h * 0.88)
    elseif notice and now < noticeUntil then
        drawMissionText(notice, h * 0.88)
    end
    if not phase and atStart() then
        drawPanel(getElementData(localPlayer, "emmet:busy") and "DELIVERY VAN RESETTING" or "PRESS [H] TO START", h * 0.82)
    end
end)
addEventHandler("onClientResourceStop", resourceRoot, clearMission)

-- MISSION VAN ARMOR
local function isBullet(weapon)
    return type(weapon) == "number" and ((weapon >= 22 and weapon <= 34) or weapon == 38)
end

addEventHandler("onClientVehicleDamage", root, function(_, weapon, loss)
    if getElementData(source, "emmet:armored") ~= true or not isBullet(weapon) then return end
    cancelEvent()
    -- ONLY THE VEHICLE SYNCER APPLIES THE REDUCED HEALTH LOSS
    if isElementSyncer(source) and type(loss) == "number" and loss > 0 then
        setElementHealth(source, math.max(0, getElementHealth(source) - loss * 0.1))
        setVehicleWheelStates(source, 0, 0, 0, 0)
    end
end)

addEventHandler("onClientPlayerDamage", localPlayer, function(_, weapon)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if isElement(vehicle) and getElementData(vehicle, "emmet:armored") == true and isBullet(weapon) then
        cancelEvent()
    end
end)
