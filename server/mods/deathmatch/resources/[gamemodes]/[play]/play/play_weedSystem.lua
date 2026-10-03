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

local function onPlayerEnterGarden(hitElement, matchingDimension)
    if not matchingDimension then
        return
    end
    if getElementType(hitElement) ~= "player" then
        return
    end

    setElementData(hitElement, "atWeedGarden", true)
end

local function onPlayerLeaveGarden(leftElement, matchingDimension)
    if getElementType(leftElement) ~= "player" then
        return
    end
    setElementData(leftElement, "atWeedGarden", false)
end

addEventHandler("onResourceStart", resourceRoot, function()
    local gardenMarker = createMarker(MARKER_X, MARKER_Y, MARKER_Z, "cylinder", MARKER_RADIUS, 127, 255, 212, 150)
    createBlipAttachedTo(gardenMarker, 63, 2, 255, 255, 255, 255, 0, 65535)
    gardenCol = createColSphere(MARKER_X, MARKER_Y, MARKER_Z, SHOP_COL_RADIUS)
    addEventHandler("onColShapeHit", gardenCol, onPlayerEnterGarden)
    addEventHandler("onColShapeLeave", gardenCol, onPlayerLeaveGarden)
end)
