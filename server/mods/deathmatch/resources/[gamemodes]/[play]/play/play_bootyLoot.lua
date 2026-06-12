-- ==========================================
-- LOCO SKULL SHOP SYSTEM
-- ==========================================

-- MARKER POSITION
local MARKER_X, MARKER_Y, MARKER_Z = 2000.70, 1539.16, 12.65
local MARKER_RADIUS = 0.8
local SHOP_COL_RADIUS = 1.1

local REWARD_MONEY = 500
local REWARD_POINTS = 1

local shopCol = nil

local function onPlayerEnterShop(hitElement, matchingDimension)
    if not matchingDimension then return end
    if getElementType(hitElement) ~= "player" then return end

    setElementData(hitElement, "atBootyShop", true)
    outputChatBox("You're at the Booty Desk. Type /buybooty", hitElement, 127, 255, 212)
end

local function onPlayerLeaveShop(leftElement, matchingDimension)
    if getElementType(leftElement) ~= "player" then return end
    setElementData(leftElement, "atBootyShop", false)
end

addCommandHandler("buybooty", function(player)
    if getElementData(player, "atBootyShop") ~= true then
        outputChatBox("You need to be at the Booty Desk to use this command.", player, 255, 100, 100)
        return
    end

    -- grant a small pack (adjust functions to your codebase)
    if type(addPlayerMoneyEarned) == "function" then
        addPlayerMoneyEarned(player, REWARD_MONEY)
    else
        -- fallback: give basic money if other helper not available
        givePlayerMoney = givePlayerMoney or setPlayerMoney
        if type(givePlayerMoney) == "function" then
            givePlayerMoney(player, (getPlayerMoney(player) or 0) + REWARD_MONEY)
        end
    end

    if type(addPlayerPlayStat) == "function" then
        addPlayerPlayStat(player, "bootyPoints", REWARD_POINTS)
    else
        setElementData(player, "bootyPoints", (getElementData(player, "bootyPoints") or 0) + REWARD_POINTS)
    end

    outputChatBox("Aye-aye! +" .. REWARD_MONEY .. " and +" .. REWARD_POINTS .. " booty point.", player, 127, 255, 212)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    createMarker(MARKER_X, MARKER_Y, MARKER_Z, "cylinder", MARKER_RADIUS, 127, 255, 212, 150)
    shopCol = createColSphere(MARKER_X, MARKER_Y, MARKER_Z, SHOP_COL_RADIUS)
    addEventHandler("onColShapeHit", shopCol, onPlayerEnterShop)
    addEventHandler("onColShapeLeave", shopCol, onPlayerLeaveShop)
end)