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
    if not matchingDimension then return end
    if getElementType(hitElement) ~= "player" then return end

    setElementData(hitElement, "atWeedGarden", true)
    outputChatBox("Welcome to the Fog of War Garden. Press F5 to show/hide controls.", hitElement, 127, 255, 212)
end

local function onPlayerLeaveGarden(leftElement, matchingDimension)
    if getElementType(leftElement) ~= "player" then return end
    setElementData(leftElement, "atWeedGarden", false)
end

-- Simplified command that matches the F5 functionality perfectly
--[[ addCommandHandler("harvest", function(player)
    if getElementData(player, "atWeedGarden") ~= true then
        outputChatBox("You need to be at the Fog of War Garden to use this.", player, 255, 100, 100)
        return
    end

    local open = not previewState[player]
    previewState[player] = open

    if not open then
        triggerClientEvent(player, "weedGarden:closeUI", resourceRoot)
        return
    end

    local dataPayload = getGardenPayload()
    sendGardenUI(player, dataPayload)
end) ]]


addEventHandler("onResourceStart", resourceRoot, function()
    createMarker(MARKER_X, MARKER_Y, MARKER_Z, "cylinder", MARKER_RADIUS, 127, 255, 212, 150)
    gardenCol = createColSphere(MARKER_X, MARKER_Y, MARKER_Z, SHOP_COL_RADIUS)
    addEventHandler("onColShapeHit", gardenCol, onPlayerEnterGarden)
    addEventHandler("onColShapeLeave", gardenCol, onPlayerLeaveGarden)
end)