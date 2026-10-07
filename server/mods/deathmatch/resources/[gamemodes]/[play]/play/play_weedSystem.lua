-- ==========================================
-- LOCO SKULL WEED SYSTEM
-- ==========================================
-- MARKER POSITION
local MARKER_X, MARKER_Y, MARKER_Z = 2018.58, 1537.11, 9.82
local MARKER_RADIUS = 0.8
local SHOP_COL_RADIUS = 1.8

local GARDEN_REWARD_MONEY = 250
local GARDEN_REWARD_POINTS = 1

local gardenCol = nil
local gardenWelcomeCooldowns = {}
local GARDEN_WELCOME_COOLDOWN_MS = 120000

local function onPlayerEnterGarden(hitElement, matchingDimension)
    if not matchingDimension then
        return
    end
    if getElementType(hitElement) ~= "player" then
        return
    end

    setElementData(hitElement, "atWeedGarden", true)

    if getElementInterior(hitElement) ~= 0 or isPedDead(hitElement) then return end
    local now = getTickCount()
    if not gardenWelcomeCooldowns[hitElement] or now >= gardenWelcomeCooldowns[hitElement] then
        gardenWelcomeCooldowns[hitElement] = now + GARDEN_WELCOME_COOLDOWN_MS
        outputChatBox("[NOTIFICATION] Welcome to the weed garden!", hitElement, 255, 230, 109)
    end
end

addEventHandler("onPlayerQuit", root, function()
    gardenWelcomeCooldowns[source] = nil
end)

local function onPlayerLeaveGarden(leftElement, matchingDimension)
    if getElementType(leftElement) ~= "player" then
        return
    end
    setElementData(leftElement, "atWeedGarden", false)
end

local function createWeedShop(x, y, z, markerRadius, alpha, markerId)
    local gardenMarker = createMarker(x, y, z, "cylinder", markerRadius, 127, 255, 212, alpha)
    if markerId then
        setElementID(gardenMarker, markerId)
    end
    createBlipAttachedTo(gardenMarker, 63, 2, 255, 255, 255, 255, 0, 65535)
    local shopCol = createColSphere(x, y, z, SHOP_COL_RADIUS)
    addEventHandler("onColShapeHit", shopCol, onPlayerEnterGarden)
    addEventHandler("onColShapeLeave", shopCol, onPlayerLeaveGarden)
    return shopCol
end

addEventHandler("onResourceStart", resourceRoot, function()
    gardenCol = createWeedShop(MARKER_X, MARKER_Y, MARKER_Z, MARKER_RADIUS, 150)
    createWeedShop(1587.70569, 1910.43542, 9.82031, 1, 255, "weedShopLVHospital")
    createWeedShop(-368.70197, 1168.55225, 19.27188, 1, 255, "weedShopFortCarson")
    createWeedShop(-1448.90356, 2557.48486, 54.83594, 1, 255, "weedShopElQuebrados")
    createWeedShop(-2558.18848, 660.76196, 13.45312, 1, 255, "weedShopSFHospital")
    createWeedShop(-2222.99658, -2293.78003, 30.67188, 1, 255, "weedShopAngelPine")
    createWeedShop(1186.32507, -1233.26770, 21.14062, 1, 255, "weedShopLSWest")
    createWeedShop(2150.92139, -1446.24048, 24.77460, 1, 255, "weedShopLSEast")
    createWeedShop(1234.84790, 359.37027, 18.55469, 1, 255, "weedShopMontgomery")
    createWeedShop(2271.73340, -77.74500, 25.57205, 1, 255, "weedShopPalominoCreek")
end)
