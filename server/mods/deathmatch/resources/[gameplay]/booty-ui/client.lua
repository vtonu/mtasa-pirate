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

    if isElement(uiBrowser) then
        executeBrowserJavascript(uiBrowser, "window.updateBootyShop(" .. encodeValue(currentPayload) .. ");")
    end
end

local function createBootyUI(payload)
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

local function closeBootyUI()
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

addEvent("bootyShop:openUI", true)
addEventHandler("bootyShop:openUI", resourceRoot, createBootyUI)

addEvent("bootyShop:updateUI", true)
addEventHandler("bootyShop:updateUI", resourceRoot, sendPayloadToBrowser)

addEvent("bootyShop:closeUI", true)
addEventHandler("bootyShop:closeUI", resourceRoot, closeBootyUI)

addEvent("bootyShop:closeFromBrowser", true)
addEventHandler("bootyShop:closeFromBrowser", root, function()
    closeBootyUI()
    triggerServerEvent("bootyShop:uiClosed", resourceRoot)
end)

addEvent("bootyShop:startDrag", true)
addEventHandler("bootyShop:startDrag", root, function()
    if not isElement(uiBrowserElement) then
        return
    end

    local cursorX, cursorY = getCursorPosition()
    if not cursorX or not cursorY then
        return
    end

    dragOffsetX = cursorX * screenW - uiX
    dragOffsetY = cursorY * screenH - uiY
    isDragging = true
end)

addEvent("bootyShop:stopDrag", true)
addEventHandler("bootyShop:stopDrag", root, function()
    isDragging = false
end)

addEvent("bootyShop:actionFromBrowser", true)
addEventHandler("bootyShop:actionFromBrowser", root, function(actionName)
    triggerServerEvent("bootyShop:uiAction", resourceRoot, actionName)
end)

addEventHandler("onClientClick", root, function(button, state)
    if button == "left" and state == "up" then
        isDragging = false
    end
end)

addEventHandler("onClientCursorMove", root, updateDragPosition)
addEventHandler("onClientResourceStop", resourceRoot, closeBootyUI)

-- ==========================================
-- KEY BIND INTEGRATION (WITH MARKER CHECK)
-- ==========================================
local SHOP_KEY = "f6" -- "F6" key to open the UI
local SPAM_THRESHOLD = 1000
local SPAM_LOCKOUT = 10000
local lastKeyTick = nil
local lockoutUntilTick = 0

local function handleShopToggle()
    local currentTick = getTickCount()

    if currentTick < lockoutUntilTick then
        return
    end

    if lastKeyTick and currentTick - lastKeyTick < SPAM_THRESHOLD then
        if getElementData(localPlayer, "atBootyShop") == true then
            outputChatBox("Don't spam key.", 127, 255, 212)
        else
            outputChatBox("You need to be at the Booty Desk to use this key. Don't spam.", 127, 255, 212)
        end
        lockoutUntilTick = currentTick + SPAM_LOCKOUT
        lastKeyTick = nil
        return
    end

    lastKeyTick = currentTick

    if isElement(uiBrowserElement) then
        return
    end

    if getElementData(localPlayer, "atBootyShop") == true then
        triggerServerEvent("bootyShop:requestOpen", resourceRoot)
    else
        outputChatBox("You need to be at the Booty Desk to use this key.", 127, 255, 212)
    end
end

addEventHandler("onClientKey", root, function(button)
    if isElement(uiBrowserElement) and not button:find("^mouse") then
        cancelEvent()
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    bindKey(SHOP_KEY, "down", handleShopToggle)
end)
