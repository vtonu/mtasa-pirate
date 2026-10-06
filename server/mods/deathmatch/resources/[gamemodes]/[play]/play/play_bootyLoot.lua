-- ==========================================
-- LOCO SKULL SHOP SYSTEM
-- ==========================================
-- MARKER POSITION
local MARKER_X, MARKER_Y, MARKER_Z = 2000.70, 1539.16, 12.65
local MARKER_RADIUS = 0.8
local SHOP_COL_RADIUS = 1.1

local shopCol = nil

local function onPlayerEnterShop(hitElement, matchingDimension)
    if not matchingDimension then
        return
    end
    if getElementType(hitElement) ~= "player" then
        return
    end

    setElementData(hitElement, "atBootyShop", true)
end

local function onPlayerLeaveShop(leftElement)
    if getElementType(leftElement) ~= "player" then
        return
    end

    setElementData(leftElement, "atBootyShop", false)

    if getResourceFromName("booty-ui") and getResourceState(getResourceFromName("booty-ui")) == "running" then
        exports["booty-ui"]:closeBootyUI(leftElement)
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    createMarker(MARKER_X, MARKER_Y, MARKER_Z, "cylinder", MARKER_RADIUS, 255, 230, 109, 150)
    shopCol = createColSphere(MARKER_X, MARKER_Y, MARKER_Z, SHOP_COL_RADIUS)
    addEventHandler("onColShapeHit", shopCol, onPlayerEnterShop)
    addEventHandler("onColShapeLeave", shopCol, onPlayerLeaveShop)
end)
