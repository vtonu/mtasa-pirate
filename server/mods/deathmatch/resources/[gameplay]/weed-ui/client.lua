local screenW, screenH = guiGetScreenSize()
local uiBrowser
local uiBrowserElement
local currentPayload = {}
local isDragging = false
local dragOffsetX = 0
local dragOffsetY = 0
local previousInputMode = nil

local UI_WIDTH = math.floor(screenW * 0.52)
local UI_HEIGHT = math.floor(screenH * 0.66)
local uiX = math.floor((screenW - UI_WIDTH) / 2)
local uiY = math.floor((screenH - UI_HEIGHT) / 2)

local SATIVA_RUN_SPEED_LIMIT = 1.35 -- Run speed limit for sativa strain (MP5)
local SATIVA_RUN_ACCELERATION = 1.80 -- Run acceleration speed for sativa strain (MP5)
local SATIVA_SWIM_SPEED_LIMIT = 0.29 -- Swim speed limit for sativa strain (MP5)
local SATIVA_SWIM_ACCELERATION = 1.08 -- Swim acceleration speed for sativa strain (MP5)
local INDICA_MOVEMENT_SPEED_LIMIT = 0.010 -- Limit all ground movement for indica strain (combat shotgun)
local HYBRID_WALK_SPEED_LIMIT = 0.008 -- Limit the hybrid strain walk speed (deagle)

local function encodeValue(value)
    local valueType = type(value)

    if valueType == "table" then
        local arrayItems = {}
        local objectItems = {}
        local maxIndex = 0
        local itemCount = 0

        for key in pairs(value) do
            itemCount = itemCount + 1
            if type(key) == "number" and key > 0 and key % 1 == 0 then
                maxIndex = math.max(maxIndex, key)
            end
        end

        if maxIndex == itemCount then
            for index = 1, maxIndex do
                table.insert(arrayItems, encodeValue(value[index]))
            end
            return "[" .. table.concat(arrayItems, ",") .. "]"
        end

        for key, item in pairs(value) do
            table.insert(objectItems, encodeValue(tostring(key)) .. ":" .. encodeValue(item))
        end
        return "{" .. table.concat(objectItems, ",") .. "}"
    end

    if valueType == "string" then
        local escaped = value:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r")
        return '"' .. escaped .. '"'
    end

    if valueType == "number" or valueType == "boolean" then
        return tostring(value)
    end

    return "null"
end

local function sendPayloadToBrowser(payload)
    currentPayload = payload or currentPayload

    if not isElement(uiBrowser) then
        return
    end

    executeBrowserJavascript(uiBrowser, "window.updateGarden(" .. encodeValue(currentPayload) .. ");")
end

local function createGardenUI(payload)
    if isElement(uiBrowserElement) then
        sendPayloadToBrowser(payload)
        return
    end

    currentPayload = payload or {}
    uiBrowserElement = guiCreateBrowser(uiX, uiY, UI_WIDTH, UI_HEIGHT, true, true, false)
    uiBrowser = guiGetBrowser(uiBrowserElement)

    addEventHandler("onClientBrowserCreated", uiBrowser, function()
        loadBrowserURL(source, "http://mta/local/ui.html")
        focusBrowser(source)
    end)

    addEventHandler("onClientBrowserDocumentReady", uiBrowser, function()
        sendPayloadToBrowser(currentPayload)
    end)

    previousInputMode = guiGetInputMode()
    guiSetInputMode("no_binds")
    showCursor(true)
end

local function closeGardenUI()
    if isElement(uiBrowserElement) then
        destroyElement(uiBrowserElement)
    end

    uiBrowserElement = nil
    uiBrowser = nil
    isDragging = false

    if previousInputMode then
        guiSetInputMode(previousInputMode)
        previousInputMode = nil
    end

    showCursor(false)
end

local function updateDragPosition(_, _, absoluteX, absoluteY)
    if not isDragging or not isElement(uiBrowserElement) then
        return
    end

    uiX = math.max(0, math.min(screenW - UI_WIDTH, absoluteX - dragOffsetX))
    uiY = math.max(0, math.min(screenH - UI_HEIGHT, absoluteY - dragOffsetY))
    guiSetPosition(uiBrowserElement, uiX, uiY, false)
end

local function boostHorizontalVelocity(speedLimit, acceleration, timeSlice)
    local velocityX, velocityY, velocityZ = getElementVelocity(localPlayer)
    local horizontalSpeed = math.sqrt(velocityX * velocityX + velocityY * velocityY)

    if horizontalSpeed < 0.005 or horizontalSpeed >= speedLimit then
        return
    end

    local frameAcceleration = 1 + ((acceleration - 1) * math.min(timeSlice / 16.6667, 2))
    local boostedSpeed = math.min(speedLimit, horizontalSpeed * frameAcceleration)
    local multiplier = boostedSpeed / horizontalSpeed

    setElementVelocity(localPlayer, velocityX * multiplier, velocityY * multiplier, velocityZ)
end

local function limitHorizontalVelocity(speedLimit)
    local velocityX, velocityY, velocityZ = getElementVelocity(localPlayer)
    local horizontalSpeed = math.sqrt(velocityX * velocityX + velocityY * velocityY)

    if horizontalSpeed <= speedLimit then
        return
    end

    local multiplier = speedLimit / horizontalSpeed
    setElementVelocity(localPlayer, velocityX * multiplier, velocityY * multiplier, velocityZ)
end

local function updateWeedMovement(timeSlice)
    if isPedDead(localPlayer) or isPedInVehicle(localPlayer) then
        return
    end

    local activePerk = getElementData(localPlayer, "weed.perk")

    if activePerk == "indica"
        and isPedOnGround(localPlayer)
        and not isElementInWater(localPlayer)
        and (getPedControlState(localPlayer, "forwards")
            or getPedControlState(localPlayer, "backwards")
            or getPedControlState(localPlayer, "left")
            or getPedControlState(localPlayer, "right")) then
        limitHorizontalVelocity(INDICA_MOVEMENT_SPEED_LIMIT)
        return
    end

    if activePerk == "sativa"
        and isPedOnGround(localPlayer)
        and getPedControlState(localPlayer, "sprint")
        and (getPedControlState(localPlayer, "forwards") or getPedControlState(localPlayer, "backwards")) then
        boostHorizontalVelocity(SATIVA_RUN_SPEED_LIMIT, SATIVA_RUN_ACCELERATION, timeSlice)
        return
    end

    if activePerk == "hybrid"
        and isPedOnGround(localPlayer)
        and not isElementInWater(localPlayer)
        and (getPedControlState(localPlayer, "forwards")
            or getPedControlState(localPlayer, "backwards")
            or getPedControlState(localPlayer, "left")
            or getPedControlState(localPlayer, "right")) then
        limitHorizontalVelocity(HYBRID_WALK_SPEED_LIMIT)
    end

    if activePerk == "sativa"
        and isElementInWater(localPlayer)
        and (getPedControlState(localPlayer, "forwards") or getPedControlState(localPlayer, "backwards")) then
        boostHorizontalVelocity(SATIVA_SWIM_SPEED_LIMIT, SATIVA_SWIM_ACCELERATION, timeSlice)
    end
end

addEvent("weedGarden:openUI", true)
addEventHandler("weedGarden:openUI", resourceRoot, createGardenUI)

addEvent("weedGarden:updateUI", true)
addEventHandler("weedGarden:updateUI", resourceRoot, sendPayloadToBrowser)

addEvent("weedGarden:closeUI", true)
addEventHandler("weedGarden:closeUI", resourceRoot, closeGardenUI)

addEvent("weedGarden:closeFromBrowser", true)
addEventHandler("weedGarden:closeFromBrowser", root, function()
    closeGardenUI()
    triggerServerEvent("weedGarden:uiClosed", resourceRoot)
end)

addEvent("weedGarden:startDrag", true)
addEventHandler("weedGarden:startDrag", root, function()
    if not isElement(uiBrowserElement) then
        return
    end

    local cursorX, cursorY = getCursorPosition()
    if not cursorX or not cursorY then
        return
    end

    local absoluteX = cursorX * screenW
    local absoluteY = cursorY * screenH
    dragOffsetX = absoluteX - uiX
    dragOffsetY = absoluteY - uiY
    isDragging = true
end)

addEvent("weedGarden:stopDrag", true)
addEventHandler("weedGarden:stopDrag", root, function()
    isDragging = false
end)

addEvent("weedGarden:actionFromBrowser", true)
addEventHandler("weedGarden:actionFromBrowser", root, function(actionName)
    triggerServerEvent("weedGarden:uiAction", resourceRoot, actionName)
end)

addEventHandler("onClientClick", root, function(button, state)
    if button == "left" and state == "up" then
        isDragging = false
    end
end)

addEventHandler("onClientCursorMove", root, updateDragPosition)
addEventHandler("onClientPreRender", root, updateWeedMovement)
addEventHandler("onClientResourceStop", resourceRoot, closeGardenUI)

-- ==========================================
-- KEY BIND INTEGRATION (WITH MARKER CHECK)
-- ==========================================
local HARVEST_KEY = "f5" -- "F5" key to toggle the UI

local function handleHarvestToggle()
    -- Check if the UI browser element currently exists on screen
    if isElement(uiBrowserElement) then
        -- Closing the UI is always allowed anywhere so they don't get trapped
        closeGardenUI()
        triggerServerEvent("weedGarden:uiClosed", resourceRoot)
    else
        -- ONLY allow opening if the element data from play_weedSystem.lua is true
        if getElementData(localPlayer, "atWeedGarden") == true then
            triggerServerEvent("weedGarden:requestOpen", resourceRoot)
        else
            outputChatBox("You need to be at the Fog of War Garden to use this key.", 127, 255, 212)
        end
    end
end

-- Bind the key automatically as soon as this script resource starts
addEventHandler("onClientResourceStart", resourceRoot, function()
    bindKey(HARVEST_KEY, "down", handleHarvestToggle)
end)
