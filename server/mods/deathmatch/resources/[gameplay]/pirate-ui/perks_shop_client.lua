local closeGardenUI
local function ownerRoot()
    local owner = getResourceFromName("pirate-perks")
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
local shopNotice = nil
local shopNoticeUntil = 0

local encodeValue = shopWindow.encode
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
    uiBrowserElement, uiBrowser = shopWindow.open("perks", currentPayload.shopMode == "kratom" and "http://mta/local/kratom.html" or "http://mta/local/weed.html", function()
        sendPayloadToBrowser(currentPayload)
    end, closeGardenUI)
end

-- KEEP PERK EXPIRY FEEDBACK OUT OF CHAT
addEvent("weedGarden:notification", true)
addOwnerEvent("weedGarden:notification", function(message)
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
    shopWindow.drawPrompt(shopNotice, 0.74)
end)

closeGardenUI = function()
    if shopWindow.close("perks") then return end
    openRequestUntil = 0

    uiBrowserElement = nil
    uiBrowser = nil

end

addEvent("weedGarden:openUI", true)
addOwnerEvent("weedGarden:openUI", function(payload)
    if isElement(uiBrowserElement) and currentPayload.shopMode=="kratom" then closeGardenUI() end
    createGardenUI(payload)
end)

addEvent("weedGarden:updateUI", true)
addOwnerEvent("weedGarden:updateUI", sendPayloadToBrowser)

addEvent("weedGarden:perkPreview", true)
addEvent("weedGarden:perkClock", true)
addOwnerEvent("weedGarden:perkPreview", function(preview)
    if currentPayload.shopMode=="kratom" then return end
    currentPayload.perkPreview = preview
    if isElement(uiBrowser) then
        executeBrowserJavascript(uiBrowser, "window.updatePerkPreview(" .. encodeValue(preview) .. ");")
    end
end)

addEvent("weedGarden:stockUpdate", true)
addOwnerEvent("weedGarden:stockUpdate", function(catalog)
    if currentPayload.shopMode=="kratom" then return end
    currentPayload.strainCatalog = catalog
    if isElement(uiBrowser) then
        executeBrowserJavascript(uiBrowser, "window.updateGardenCatalog(" .. encodeValue(catalog) .. ");")
    end
end)

addEvent("weedGarden:closeUI", true)
addOwnerEvent("weedGarden:closeUI", closeGardenUI)

addEvent("weedGarden:closeFromBrowser", true)
addEventHandler("weedGarden:closeFromBrowser", root, function()
    if source ~= uiBrowser then return end
    local mode=currentPayload.shopMode
    closeGardenUI()
    triggerServerEvent(mode=="kratom" and "kratom:uiClosed" or "weedGarden:uiClosed", ownerRoot())
end)

addEvent("weedGarden:startDrag", true)
addEventHandler("weedGarden:startDrag", root, function()
    shopWindow.startDrag(source)
end)

addEvent("weedGarden:stopDrag", true)
addEventHandler("weedGarden:stopDrag", root, function()
    shopWindow.stopDrag(source)
end)

addEvent("weedGarden:actionFromBrowser", true)
addEventHandler("weedGarden:actionFromBrowser", root, function(actionName)
    if source ~= uiBrowser then return end
    triggerServerEvent(currentPayload.shopMode=="kratom" and "kratom:uiAction" or "weedGarden:uiAction", ownerRoot(), actionName)
end)

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
    if not isElement(localPlayer) or isPedDead(localPlayer) or isPedInVehicle(localPlayer) then return false end
    local x,y,z=getElementPosition(localPlayer)
    for _,id in ipairs({"specialShopWeedGarden","specialShopRedCounty","specialShopNorthLV"}) do
        local marker=getElementByID(id)
        if isElement(marker) and getElementData(marker,"specialShop:catalog")=="kratom"
            and getElementInterior(marker)==getElementInterior(localPlayer)
            and getElementDimension(marker)==getElementDimension(localPlayer) then
            local mx,my,mz=getElementPosition(marker)
            if getDistanceBetweenPoints3D(x,y,z,mx,my,mz+1)<=1.25 then return true end
        end
    end
    return false
end

addEvent("kratom:openUI",true)
addOwnerEvent("kratom:openUI", function(payload)
    if isElement(uiBrowserElement) and currentPayload.shopMode~="kratom" then closeGardenUI() end
    createGardenUI(payload)
end)
addEvent("kratom:closeUI",true)
addOwnerEvent("kratom:closeUI", function()
    if currentPayload.shopMode=="kratom" then closeGardenUI() end
end)
addEvent("kratom:perkClock",true)
addOwnerEvent("kratom:perkClock", function(preview)
    if currentPayload.shopMode~="kratom" then return end
    currentPayload.perkPreview=preview
    if isElement(uiBrowser) then executeBrowserJavascript(uiBrowser,"window.updatePerkPreview("..encodeValue(preview)..");") end
end)

local function handleHarvestToggle()
    if not ownerRoot() then return end
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
        triggerServerEvent("kratom:requestOpen", ownerRoot())
    elseif getElementData(localPlayer, "atWeedGarden") == true then
        openRequestUntil = currentTick + 5000
        triggerServerEvent("weedGarden:requestOpen", ownerRoot())
    end
end

-- MATCH THE AIRYARD H PROMPT
addEventHandler("onClientRender", root, function()
    if (not nearKratomShop() and getElementData(localPlayer, "atWeedGarden") ~= true) or isElement(uiBrowserElement)
        or getTickCount() < openRequestUntil
        or isPedDead(localPlayer) or isCursorShowing() or isChatBoxInputActive()
        or isConsoleActive() or isMainMenuActive() then return end
    shopWindow.drawPrompt("PRESS 'H' TO OPEN SHOP")
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    bindKey(HARVEST_KEY, "down", handleHarvestToggle)
end)

addEventHandler("onClientResourceStop", root, function(stopped)
    if getResourceName(stopped) == "pirate-perks" then closeGardenUI() end
end)
