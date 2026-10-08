local closeBootyUI
local function ownerRoot()
    local owner = getResourceFromName("pirate-weapons")
    return owner and getResourceState(owner) == "running" and getResourceRootElement(owner)
end

local function addOwnerEvent(name, handler)
    addEventHandler(name, root, function(...)
        if source == ownerRoot() then handler(...) end
    end)
end

local screenW, screenH = guiGetScreenSize()
local uiBrowser
local uiBrowserElement
local currentPayload = {}
local openRequestUntil = 0
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
addOwnerEvent("bootyShop:clerkReaction", function(clerk, state, weapon)
    if clerk ~= activeClerk or not isElement(uiBrowserElement) then return end
    animateClerk(state, weapon)
end)

-- KEEP THE CLERKS SAFE WITHOUT AFFECTING OTHER PEDS
addEventHandler("onClientPedDamage", root, function()
    if getElementData(source, "ammu:clerk") == true then cancelEvent() end
end)

local encodeValue = shopWindow.encode
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
    uiBrowserElement, uiBrowser = shopWindow.open("weapons", "http://mta/local/weapons.html", function()
        sendPayloadToBrowser(currentPayload)
        if isTimer(previewTimer) then killTimer(previewTimer) end
        previewTimer = setTimer(sendInventoryToBrowser, 1000, 0)
    end, closeBootyUI)
end

closeBootyUI = function()
    if shopWindow.close("weapons") then return end
    openRequestUntil = 0
    if isElement(uiBrowserElement) and isElement(activeClerk) then animateClerk("goodbye") end
    if isTimer(previewTimer) then killTimer(previewTimer) end
    previewTimer = nil

    uiBrowserElement = nil
    uiBrowser = nil

end

addEvent("bootyShop:openUI", true)
addOwnerEvent("bootyShop:openUI", createBootyUI)

addEvent("bootyShop:updateUI", true)
addOwnerEvent("bootyShop:updateUI", sendPayloadToBrowser)

addEvent("bootyShop:closeUI", true)
addOwnerEvent("bootyShop:closeUI", closeBootyUI)

addEvent("bootyShop:closeFromBrowser", true)
addEventHandler("bootyShop:closeFromBrowser", root, function()
    if source ~= uiBrowser then return end
    closeBootyUI()
    triggerServerEvent("bootyShop:uiClosed", ownerRoot())
end)

addEvent("bootyShop:startDrag", true)
addEventHandler("bootyShop:startDrag", root, function()
    shopWindow.startDrag(source)
end)

addEvent("bootyShop:stopDrag", true)
addEventHandler("bootyShop:stopDrag", root, function()
    shopWindow.stopDrag(source)
end)

addEvent("bootyShop:actionFromBrowser", true)
addEventHandler("bootyShop:actionFromBrowser", root, function(actionName)
    if source ~= uiBrowser then return end
    triggerServerEvent("bootyShop:uiAction", ownerRoot(), actionName)
end)

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
    if not ownerRoot() then return end
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
        triggerServerEvent("bootyShop:requestOpen", ownerRoot())
    end
end

-- MATCH THE AIRYARD H PROMPT
addEventHandler("onClientRender", root, function()
    local ammu = isElement(getElementData(localPlayer, "ammu:shopClerk"))
    if (getElementData(localPlayer, "atBootyShop") ~= true and not ammu) or isElement(uiBrowserElement)
        or getTickCount() < openRequestUntil
        or isPedDead(localPlayer) or isCursorShowing() or isChatBoxInputActive()
        or isConsoleActive() or isMainMenuActive() then return end
    shopWindow.drawPrompt("PRESS 'H' TO OPEN SHOP")
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    bindKey(SHOP_KEY, "down", handleShopToggle)
end)

addEventHandler("onClientResourceStop", resourceRoot, stopClerk)

addEventHandler("onClientResourceStop", root, function(stopped)
    if getResourceName(stopped) == "pirate-weapons" then closeBootyUI() end
end)
