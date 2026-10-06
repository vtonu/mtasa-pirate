local screenW, screenH = guiGetScreenSize()
local uiBrowser
local uiBrowserElement
local currentPayload = {}
local openRequestUntil = 0
local isDragging = false
local dragOffsetX = 0
local dragOffsetY = 0
local previousInputMode = nil
local previewTimer
local activeClerk, clerkTimer
local lastClerkReaction = 0

local function stopClerk()
    if isTimer(clerkTimer) then killTimer(clerkTimer) end
    clerkTimer = nil
    if isElement(activeClerk) then
        setPedAnimation(activeClerk)
        setElementFrozen(activeClerk, true)
    end
    activeClerk = nil
end

local function clerkIdle()
    if isElement(activeClerk) then
        setElementFrozen(activeClerk, false)
        setPedAnimation(activeClerk, "shop", "shp_serve_idle", -1, true, false, false, false)
    end
end

local function animateClerk(state, weapon)
    if not isElement(activeClerk) then return end
    local now = getTickCount()
    if state == "browse" and now - lastClerkReaction < 1500 then return end
    lastClerkReaction = now
    if isTimer(clerkTimer) then killTimer(clerkTimer) end
    local block, animation, duration = "shop", "shp_serve_start", 1400
    if state == "browse" then
        block, animation = "weapons", weapon and weapon >= 25 and weapon <= 34 and "shp_ar_lift" or "shp_1h_lift"
    elseif state == "purchase" then
        animation, duration = "shp_serve_loop", 1800
        if weapon == 35 or weapon == 36 or weapon == 38 then
            block, animation = "cop_ambient", "coplook_nod"
        end
    elseif state == "refusal" then
        block, animation = "cop_ambient", "coplook_shake"
    elseif state == "goodbye" then
        animation = "shp_serve_end"
    end
    setElementFrozen(activeClerk, false)
    setPedAnimation(activeClerk, block, animation, duration, false, false, false, false)
    clerkTimer = setTimer(function()
        clerkTimer = nil
        if state == "goodbye" then stopClerk() else clerkIdle() end
    end, duration, 1)
end

addEvent("bootyShop:clerkReaction", true)
addEventHandler("bootyShop:clerkReaction", resourceRoot, function(clerk, state, weapon)
    if clerk ~= activeClerk or not isElement(uiBrowserElement) then return end
    animateClerk(state, weapon)
end)

-- KEEP THE CLERKS SAFE WITHOUT AFFECTING OTHER PEDS
addEventHandler("onClientPedDamage", root, function()
    if getElementData(source, "ammu:clerk") == true then cancelEvent() end
end)

local UI_WIDTH = math.floor(math.min(screenW - 32, math.max(960, screenW * 0.52)))
local UI_HEIGHT = math.floor(math.min(screenH - 32, math.max(680, screenH * 0.66)))
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

local function sendInventoryToBrowser()
    if not isElement(uiBrowser) then return end
    local inventory = {}
    for slot = 0, 12 do
        local weapon = getPedWeapon(localPlayer, slot)
        local ammo = getPedTotalAmmo(localPlayer, slot)
        if weapon and weapon > 0 and ammo and ammo > 0 then
            table.insert(inventory, {slot = slot, weapon = weapon, ammo = ammo, name = getWeaponNameFromID(weapon)})
        end
    end
    executeBrowserJavascript(uiBrowser, "window.updateShopInventory(" .. encodeValue(inventory) .. ");")
end

local function sendPayloadToBrowser(payload)
    currentPayload = payload or currentPayload

    if isElement(uiBrowser) then
        executeBrowserJavascript(uiBrowser, "window.updateBootyShop(" .. encodeValue(currentPayload) .. ");")
        sendInventoryToBrowser()
    end
end

local function createBootyUI(payload, clerk)
    openRequestUntil = 0
    if isElement(uiBrowserElement) then
        sendPayloadToBrowser(payload)
        return
    end

    currentPayload = payload or {}
    stopClerk()
    if isElement(clerk) then
        activeClerk = clerk
        animateClerk("greeting")
    end
    uiBrowserElement = guiCreateBrowser(uiX, uiY, UI_WIDTH, UI_HEIGHT, true, true, false)
    uiBrowser = guiGetBrowser(uiBrowserElement)

    addEventHandler("onClientBrowserCreated", uiBrowser, function()
        loadBrowserURL(source, "http://mta/local/ui.html")
        focusBrowser(source)
    end)

    addEventHandler("onClientBrowserDocumentReady", uiBrowser, function()
        sendPayloadToBrowser(currentPayload)
        if isTimer(previewTimer) then killTimer(previewTimer) end
        previewTimer = setTimer(sendInventoryToBrowser, 1000, 0)
    end)

    previousInputMode = guiGetInputMode()
    guiSetInputMode("no_binds")
    showCursor(true)
end

local function closeBootyUI()
    openRequestUntil = 0
    if isElement(uiBrowserElement) and isElement(activeClerk) then animateClerk("goodbye") end
    if isTimer(previewTimer) then killTimer(previewTimer) end
    previewTimer = nil
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
local SHOP_KEY = "h" -- H TO OPEN THE SHOP
local SPAM_THRESHOLD = 1000
local SPAM_LOCKOUT = 10000
local lastKeyTick = nil
local lockoutUntilTick = 0

local function handleShopToggle()
    if (getElementData(localPlayer, "atBootyShop") ~= true and not isElement(getElementData(localPlayer, "ammu:shopClerk")))
        or isElement(uiBrowserElement) or getTickCount() < openRequestUntil or isPedDead(localPlayer)
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

    if getElementData(localPlayer, "atBootyShop") == true or isElement(getElementData(localPlayer, "ammu:shopClerk")) then
        openRequestUntil = currentTick + 5000
        triggerServerEvent("bootyShop:requestOpen", resourceRoot)
    end
end

-- MATCH THE AIRYARD H PROMPT
addEventHandler("onClientRender", root, function()
    local ammu = isElement(getElementData(localPlayer, "ammu:shopClerk"))
    if (getElementData(localPlayer, "atBootyShop") ~= true and not ammu) or isElement(uiBrowserElement)
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
    bindKey(SHOP_KEY, "down", handleShopToggle)
end)

addEventHandler("onClientResourceStop", resourceRoot, stopClerk)
addEventHandler("onClientPlayerWasted", localPlayer, closeBootyUI)
