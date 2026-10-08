local screenW, screenH = guiGetScreenSize()
local width = math.floor(math.min(screenW - 32, math.max(960, screenW * 0.52)))
local height = math.floor(math.min(screenH - 32, math.max(680, screenH * 0.66)))
local positions = {}
local active
local dragging = false
local offsetX, offsetY = 0, 0

shopWindow = {}

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

shopWindow.encode = encodeValue

function shopWindow.close(id)
    if not active or active.id ~= id then return false end
    local window = active
    active = nil
    dragging = false
    if window.onClose then window.onClose() end
    if isElement(window.element) then destroyElement(window.element) end
    guiSetInputMode(window.inputMode)
    showCursor(false)
    return true
end

function shopWindow.open(id, url, onReady, onClose)
    if active then shopWindow.close(active.id) end
    local position = positions[id] or {x = math.floor((screenW - width) / 2), y = math.floor((screenH - height) / 2)}
    positions[id] = position
    local element = guiCreateBrowser(position.x, position.y, width, height, true, true, false)
    local browser = guiGetBrowser(element)
    active = {id = id, element = element, browser = browser, position = position,
        inputMode = guiGetInputMode(), onClose = onClose}
    addEventHandler("onClientBrowserCreated", browser, function()
        loadBrowserURL(source, url)
        focusBrowser(source)
    end)
    addEventHandler("onClientBrowserDocumentReady", browser, function()
        if active and active.browser == source then onReady() end
    end)
    guiSetInputMode("no_binds")
    showCursor(true)
    return element, browser
end

function shopWindow.startDrag(browser)
    if not active or active.browser ~= browser then return end
    local x, y = getCursorPosition()
    if not x or not y then return end
    offsetX = x * screenW - active.position.x
    offsetY = y * screenH - active.position.y
    dragging = true
end

function shopWindow.stopDrag(browser)
    if active and active.browser == browser then dragging = false end
end

function shopWindow.drawPrompt(text, position)
    local w, h = guiGetScreenSize()
    local promptWidth = math.min(420, w - 32)
    local left, top = (w - promptWidth) / 2, h * (position or 0.82)
    local font = "unifont"
    local scale = math.min(1, (promptWidth - 32) / dxGetTextWidth(text, 1, font))
    dxDrawRectangle(left, top, promptWidth, 48, tocolor(31, 31, 31, 124))
    dxDrawRectangle(left, top, promptWidth, 1, tocolor(127, 255, 212, 55))
    dxDrawRectangle(left, top, 2, 48, tocolor(127, 255, 212, 200))
    dxDrawText(text, left + 12, top, left + promptWidth - 12, top + 48,
        tocolor(127, 255, 212, 245), scale, font, "center", "center", false, false, false, false)
end

addEventHandler("onClientCursorMove", root, function(_, _, x, y)
    if not active or not dragging then return end
    active.position.x = math.max(0, math.min(screenW - width, x - offsetX))
    active.position.y = math.max(0, math.min(screenH - height, y - offsetY))
    guiSetPosition(active.element, active.position.x, active.position.y, false)
end)

addEventHandler("onClientClick", root, function(button, state)
    if button == "left" and state == "up" then dragging = false end
end)

addEventHandler("onClientKey", root, function(button)
    if active and not button:find("^mouse") then cancelEvent() end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if active then shopWindow.close(active.id) end
end)

addEventHandler("onClientPlayerWasted", localPlayer, function()
    if active then shopWindow.close(active.id) end
end)
