local screenW, screenH = guiGetScreenSize()
local uiBrowser
local uiBrowserElement
local currentPayload = {}
local openRequestUntil = 0
local shopNotice = nil
local shopNoticeUntil = 0
local isDragging = false
local dragOffsetX = 0
local dragOffsetY = 0
local previousInputMode = nil

local UI_WIDTH = math.floor(math.min(screenW - 32, math.max(960, screenW * 0.52)))
local UI_HEIGHT = math.floor(math.min(screenH - 32, math.max(680, screenH * 0.66)))
local uiX = math.floor((screenW - UI_WIDTH) / 2)
local uiY = math.floor((screenH - UI_HEIGHT) / 2)

-- STRAIN MOVEMENT PERKS
local SATIVA_RUN_SPEED_LIMIT = 1.65
local SATIVA_RUN_ACCELERATION = 2.10
local SATIVA_SWIM_SPEED_LIMIT = 0.36
local SATIVA_SWIM_ACCELERATION = 1.25
local INDICA_MOVEMENT_SPEED_LIMIT = 0.010

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
    openRequestUntil = 0
    if isElement(uiBrowserElement) then
        sendPayloadToBrowser(payload)
        return
    end

    currentPayload = payload or {}
    uiBrowserElement = guiCreateBrowser(uiX, uiY, UI_WIDTH, UI_HEIGHT, true, true, false)
    uiBrowser = guiGetBrowser(uiBrowserElement)

    addEventHandler("onClientBrowserCreated", uiBrowser, function()
        loadBrowserURL(source, currentPayload.shopMode=="kratom" and "http://mta/local/kratom.html" or "http://mta/local/ui.html")
        focusBrowser(source)
    end)

    addEventHandler("onClientBrowserDocumentReady", uiBrowser, function()
        sendPayloadToBrowser(currentPayload)
    end)

    previousInputMode = guiGetInputMode()
    guiSetInputMode("no_binds")
    showCursor(true)
end

-- KEEP PERK EXPIRY FEEDBACK OUT OF CHAT
addEvent("weedGarden:notification", true)
addEventHandler("weedGarden:notification", resourceRoot, function(message)
    if type(message) ~= "string" then return end
    if isElement(uiBrowserElement) then
        currentPayload.note = message
        sendPayloadToBrowser(currentPayload)
    else
        shopNotice = message
        shopNoticeUntil = getTickCount() + 5000
    end
end)

addEventHandler("onClientRender", root, function()
    if not shopNotice or getTickCount() >= shopNoticeUntil or isElement(uiBrowserElement)
        or isMainMenuActive() then return end
    local w, h = guiGetScreenSize()
    local width = math.min(420, w - 32)
    local left, top = (w - width) / 2, h * 0.74
    local font = "unifont"
    local scale = math.min(1, (width - 32) / dxGetTextWidth(shopNotice, 1, font))
    dxDrawRectangle(left, top, width, 48, tocolor(31, 31, 31, 124))
    dxDrawRectangle(left, top, width, 1, tocolor(127, 255, 212, 55))
    dxDrawRectangle(left, top, 2, 48, tocolor(127, 255, 212, 200))
    dxDrawText(shopNotice, left + 12, top, left + width - 12, top + 48,
        tocolor(127, 255, 212, 245), scale, font, "center", "center", false, false, false, false)
end)

local function closeGardenUI()
    openRequestUntil = 0
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

    if activePerk == "indica" and isPedOnGround(localPlayer) and not isElementInWater(localPlayer) and
        (getPedControlState(localPlayer, "forwards") or getPedControlState(localPlayer, "backwards") or
            getPedControlState(localPlayer, "left") or getPedControlState(localPlayer, "right")) then
        limitHorizontalVelocity(INDICA_MOVEMENT_SPEED_LIMIT)
        return
    end

    if activePerk == "sativa" and isPedOnGround(localPlayer) and
        (getPedControlState(localPlayer, "forwards") or getPedControlState(localPlayer, "backwards") or
            getPedControlState(localPlayer, "left") or getPedControlState(localPlayer, "right")) then
        boostHorizontalVelocity(SATIVA_RUN_SPEED_LIMIT, SATIVA_RUN_ACCELERATION, timeSlice)
        return
    end

    if activePerk == "sativa" and isElementInWater(localPlayer) and
        (getPedControlState(localPlayer, "forwards") or getPedControlState(localPlayer, "backwards")) then
        boostHorizontalVelocity(SATIVA_SWIM_SPEED_LIMIT, SATIVA_SWIM_ACCELERATION, timeSlice)
    end
end

addEvent("weedGarden:openUI", true)
addEventHandler("weedGarden:openUI", resourceRoot, function(payload)
    if isElement(uiBrowserElement) and currentPayload.shopMode=="kratom" then closeGardenUI() end
    createGardenUI(payload)
end)

addEvent("weedGarden:updateUI", true)
addEventHandler("weedGarden:updateUI", resourceRoot, sendPayloadToBrowser)

addEvent("weedGarden:perkPreview", true)
addEvent("weedGarden:perkClock", true)
addEventHandler("weedGarden:perkPreview", resourceRoot, function(preview)
    if currentPayload.shopMode=="kratom" then return end
    currentPayload.perkPreview = preview
    if isElement(uiBrowser) then
        executeBrowserJavascript(uiBrowser, "window.updatePerkPreview(" .. encodeValue(preview) .. ");")
    end
end)

addEvent("weedGarden:stockUpdate", true)
addEventHandler("weedGarden:stockUpdate", resourceRoot, function(catalog)
    if currentPayload.shopMode=="kratom" then return end
    currentPayload.strainCatalog = catalog
    if isElement(uiBrowser) then
        executeBrowserJavascript(uiBrowser, "window.updateGardenCatalog(" .. encodeValue(catalog) .. ");")
    end
end)

addEvent("weedGarden:closeUI", true)
addEventHandler("weedGarden:closeUI", resourceRoot, closeGardenUI)

addEvent("weedGarden:closeFromBrowser", true)
addEventHandler("weedGarden:closeFromBrowser", root, function()
    local mode=currentPayload.shopMode
    closeGardenUI()
    triggerServerEvent(mode=="kratom" and "kratom:uiClosed" or "weedGarden:uiClosed", resourceRoot)
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
    triggerServerEvent(currentPayload.shopMode=="kratom" and "kratom:uiAction" or "weedGarden:uiAction", resourceRoot, actionName)
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
local HARVEST_KEY = "h" -- H TO OPEN THE SHOP
local SPAM_THRESHOLD = 1000
local SPAM_LOCKOUT = 10000
local lastKeyTick = nil
local lockoutUntilTick = 0

local function nearKratomShop()
    local marker=getElementByID("specialShopWeedGarden")
    if not isElement(marker) or getElementData(marker,"specialShop:catalog")~="kratom" or isPedInVehicle(localPlayer) then return false end
    if getElementInterior(marker)~=getElementInterior(localPlayer) or getElementDimension(marker)~=getElementDimension(localPlayer) then return false end
    local x,y,z=getElementPosition(localPlayer)
    local mx,my,mz=getElementPosition(marker)
    return getDistanceBetweenPoints3D(x,y,z,mx,my,mz+1)<=1.25
end

addEvent("kratom:openUI",true)
addEventHandler("kratom:openUI",resourceRoot,function(payload)
    if isElement(uiBrowserElement) and currentPayload.shopMode~="kratom" then closeGardenUI() end
    createGardenUI(payload)
end)
addEvent("kratom:closeUI",true)
addEventHandler("kratom:closeUI",resourceRoot,function()
    if currentPayload.shopMode=="kratom" then closeGardenUI() end
end)
addEvent("kratom:perkClock",true)
addEventHandler("kratom:perkClock",resourceRoot,function(preview)
    if currentPayload.shopMode~="kratom" then return end
    currentPayload.perkPreview=preview
    if isElement(uiBrowser) then executeBrowserJavascript(uiBrowser,"window.updatePerkPreview("..encodeValue(preview)..");") end
end)

local function handleHarvestToggle()
    if (not nearKratomShop() and getElementData(localPlayer, "atWeedGarden") ~= true) or isElement(uiBrowserElement)
        or getTickCount() < openRequestUntil or isPedDead(localPlayer)
        or isCursorShowing() or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() then return end
    local currentTick = getTickCount()

    if currentTick < lockoutUntilTick then
        return
    end

    if lastKeyTick and currentTick - lastKeyTick < SPAM_THRESHOLD then
        lockoutUntilTick = currentTick + SPAM_LOCKOUT
        lastKeyTick = nil
        return
    end

    lastKeyTick = currentTick

    if isElement(uiBrowserElement) then
        return
    end

    if nearKratomShop() then
        openRequestUntil=currentTick+5000
        triggerServerEvent("kratom:requestOpen",resourceRoot)
    elseif getElementData(localPlayer, "atWeedGarden") == true then
        openRequestUntil = currentTick + 5000
        triggerServerEvent("weedGarden:requestOpen", resourceRoot)
    end
end

-- MATCH THE AIRYARD H PROMPT
addEventHandler("onClientRender", root, function()
    if (not nearKratomShop() and getElementData(localPlayer, "atWeedGarden") ~= true) or isElement(uiBrowserElement)
        or getTickCount() < openRequestUntil
        or isPedDead(localPlayer) or isCursorShowing() or isChatBoxInputActive()
        or isConsoleActive() or isMainMenuActive() then return end
    local w, h = guiGetScreenSize()
    local width = math.min(420, w - 32)
    local left, top = (w - width) / 2, h * 0.82
    local prompt = "PRESS 'H' TO OPEN SHOP"
    local font = "unifont"
    local scale = math.min(1, (width - 32) / dxGetTextWidth(prompt, 1, font))
    dxDrawRectangle(left, top, width, 48, tocolor(31, 31, 31, 124))
    dxDrawRectangle(left, top, width, 1, tocolor(127, 255, 212, 55))
    dxDrawRectangle(left, top, 2, 48, tocolor(127, 255, 212, 200))
    dxDrawText(prompt, left + 12, top, left + width - 12, top + 48,
        tocolor(127, 255, 212, 245), scale, font, "center", "center", false, false, false, false)
end)

addEventHandler("onClientKey", root, function(button)
    if isElement(uiBrowserElement) and not button:find("^mouse") then
        cancelEvent()
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    bindKey(HARVEST_KEY, "down", handleHarvestToggle)
end)
