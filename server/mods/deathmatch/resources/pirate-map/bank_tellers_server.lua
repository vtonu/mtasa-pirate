-- BANK TELLERS
local tellers = {}
local playerSessions = {}
local guns = {[22] = true, [23] = true, [24] = true, [25] = true, [26] = true,
    [27] = true, [28] = true, [29] = true, [30] = true, [31] = true,
    [32] = true, [33] = true, [34] = true}
local payoutAmount, payoutDelay, payoutLimit = 500, 5000, 3000
local holdDelay, releaseDelay, cooldownDelay = 3000, 5000, 300000

local function near(player, element, radius)
    if not isElement(player) or not isElement(element) or isPedDead(player)
        or getPedOccupiedVehicle(player) or getElementData(player, "freeroam.passive") then return false end
    if getElementInterior(player) ~= getElementInterior(element)
        or getElementDimension(player) ~= getElementDimension(element) then return false end
    local x, y, z = getElementPosition(player)
    local ex, ey, ez = getElementPosition(element)
    return getDistanceBetweenPoints2D(x, y, ex, ey) <= radius and math.abs(z - ez) <= 2
end

local function aiming(player, teller)
    return near(player, teller.ped, 6) and guns[getPedWeapon(player)]
        and getPedTotalAmmo(player) > 0 and getPedTarget(player) == teller.ped
end

local function animate(teller, state)
    if teller.animation == state then return end
    teller.animation = state
    if state == "hands" then
        setPedAnimation(teller.ped, "ped", "handsup", -1, false, false, false, true)
    elseif state == "work" then
        setPedAnimation(teller.ped, "INT_SHOP", "shop_cashier", -1, true, false, false, false)
    else
        setPedAnimation(teller.ped, false)
    end
end

local function finish(teller, now)
    local session = teller.session
    if not session then return end
    if isElement(session.player) then
        setElementData(session.player, "bank:robbery", false)
    end
    playerSessions[session.player] = nil
    if session.started then teller.cooldown = now + cooldownDelay end
    teller.session = nil
end

addEventHandler("onResourceStart", resourceRoot, function()
    local layouts = {
        {"bankTeller1", "bankMissionPalominoCreek"},
        {"bankTeller2", "bankOfficeMissionPalominoCreek"}
    }
    for _, layout in ipairs(layouts) do
        local ped, marker = getElementByID(layout[1]), getElementByID(layout[2])
        if isElement(ped) and isElement(marker) then
            setElementFrozen(ped, true)
            setElementData(ped, "bank:teller", true)
            setElementData(marker, "bank:robberyMarker", true)
            tellers[#tellers + 1] = {ped = ped, marker = marker, cooldown = 0}
        else
            outputDebugString("BANK TELLER OR MARKER MISSING: " .. layout[1], 1)
        end
    end
end)

-- THE SERVER CHECKS TARGET, WEAPON, CIRCLE, OWNER AND PAYOUT TIME
setTimer(function()
    local now = getTickCount()
    local players = getElementsByType("player")
    for _, teller in ipairs(tellers) do
        if isElement(teller.ped) and not isPedDead(teller.ped) and isElement(teller.marker) then
            local threatened, visitor = false, false
            for _, player in ipairs(players) do
                if near(player, teller.marker, 1.4) then visitor = true end
                if aiming(player, teller) then
                    threatened = true
                    if not teller.session and now >= teller.cooldown
                        and not playerSessions[player] and near(player, teller.marker, 1.4) then
                        teller.session = {player = player, held = 0, paidTime = 0, total = 0,
                            lastTick = now, lastAim = now}
                        playerSessions[player] = teller
                        setElementData(player, "bank:robbery", {state = "hold", total = 0})
                    end
                end
            end
            local session = teller.session
            if session then
                local player = session.player
                local elapsed = now - session.lastTick
                session.lastTick = now
                if not near(player, teller.marker, 1.4) then
                    finish(teller, now)
                elseif aiming(player, teller) then
                    session.lastAim = now
                    if not session.started then
                        session.held = session.held + elapsed
                        if session.held >= holdDelay then
                            session.started = true
                            setPlayerWantedLevel(player, math.min(6, getPlayerWantedLevel(player) + 2))
                            setElementData(player, "bank:robbery", {state = "robbery", total = 0})
                        end
                    else
                        session.paidTime = session.paidTime + elapsed
                        if session.paidTime >= payoutDelay then
                            session.paidTime = session.paidTime - payoutDelay
                            session.total = session.total + payoutAmount
                            givePlayerMoney(player, payoutAmount)
                            setElementData(player, "bank:robbery", {state = "robbery", total = session.total})
                            outputChatBox("[BANK] +$" .. payoutAmount, player, 127, 255, 212)
                            if session.total >= payoutLimit then finish(teller, now) end
                        end
                    end
                else
                    if not session.started then session.held = 0 end
                    if now - session.lastAim >= releaseDelay then finish(teller, now) end
                end
            end
            animate(teller, threatened and "hands" or (teller.session and "hands" or (visitor and "work" or "idle")))
        else
            finish(teller, now)
        end
    end
end, 250, 0)

local function clearPlayer()
    local teller = playerSessions[source]
    if teller then finish(teller, getTickCount()) end
end
addEventHandler("onPlayerQuit", root, clearPlayer)
addEventHandler("onPlayerWasted", root, clearPlayer)
addEventHandler("onPlayerSpawn", root, clearPlayer)

addEventHandler("onResourceStop", resourceRoot, function()
    for _, teller in ipairs(tellers) do
        finish(teller, getTickCount())
        if isElement(teller.marker) then removeElementData(teller.marker, "bank:robberyMarker") end
        if isElement(teller.ped) then setPedAnimation(teller.ped, false) end
    end
end)
