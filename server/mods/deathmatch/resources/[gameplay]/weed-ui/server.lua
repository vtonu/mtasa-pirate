local previewState = {}
local playerShopState = {}
local playerPerks = {}

local PACKAGE_SETTINGS = {
    cart = { label = "CART", duration = 5 * 60 * 1000, flowerAmmo = 60 },
    eighth = { label = "1/8", duration = 10 * 60 * 1000, flowerAmmo = 120 },
    ounce = { label = "OUNCE", duration = 20 * 60 * 1000, flowerAmmo = 250 },
    qp = { label = "QP", duration = 30 * 60 * 1000, flowerAmmo = 500 }
}

local STRAINS = {
    ["Granddaddy Purple"] = { type = "indica", prices = { eighth = 90, ounce = 190, qp = 340, cart = 45 } },
    ["Northern Lights"] = { type = "indica", prices = { eighth = 80, ounce = 175, qp = 315, cart = 40 } },
    ["Bubba Kush"] = { type = "indica", prices = { eighth = 75, ounce = 165, qp = 295, cart = 35 } },
    ["Purple Kush"] = { type = "indica", prices = { eighth = 85, ounce = 185, qp = 330, cart = 45 } },
    ["Hindu Kush"] = { type = "indica", prices = { eighth = 70, ounce = 155, qp = 275, cart = 30 } },
    ["Sour Diesel"] = { type = "sativa", prices = { eighth = 100, ounce = 220, qp = 390, cart = 50 } },
    ["Durban Poison"] = { type = "sativa", prices = { eighth = 90, ounce = 200, qp = 350, cart = 45 } },
    ["Jack Herer"] = { type = "sativa", prices = { eighth = 85, ounce = 180, qp = 325, cart = 40 } },
    ["Green Crack"] = { type = "sativa", prices = { eighth = 95, ounce = 210, qp = 375, cart = 50 } },
    ["Super Lemon Haze"] = { type = "sativa", prices = { eighth = 80, ounce = 175, qp = 310, cart = 40 } },
    ["Gorilla Glue"] = { type = "hybrid", prices = { eighth = 100, ounce = 215, qp = 385, cart = 50 } },
    ["Girl Scout Cookies"] = { type = "hybrid", prices = { eighth = 95, ounce = 205, qp = 365, cart = 45 } },
    ["OG Kush"] = { type = "hybrid", prices = { eighth = 85, ounce = 190, qp = 335, cart = 40 } },
    ["White Widow"] = { type = "hybrid", prices = { eighth = 80, ounce = 180, qp = 320, cart = 35 } },
    ["Blue Zushi"] = { type = "hybrid", prices = { eighth = 100, ounce = 220, qp = 400, cart = 50 } }
}

local FLOWER_WEAPON = 14

local PERK_SETTINGS = {
    indica = {
        weapon = FLOWER_WEAPON,
        healthRegen = 4,
        armorRegen = 12,
        gravity = 0.012,
        gravityLabel = "High",
        speedLabel = "Slow",
        walkingStyle = 120, -- OLD FATMAN
        stats = { [23] = 1000 } -- MUSCLE
    },
    sativa = {
        weapon = FLOWER_WEAPON,
        healthRegen = 8,
        armorRegen = 8,
        gravityLabel = "Normal",
        speedLabel = "Fast",
        walkingStyle = 0, -- DEFAULT
        stats = { [22] = 1000 } -- STAMINA
    },
    hybrid = {
        weapon = FLOWER_WEAPON,
        healthRegen = 12,
        armorRegen = 4,
        gravity = 0.0015, -- LOW GRAVITY JUMP
        gravityLabel = "Low",
        speedLabel = "Normal",
        walkingStyle = 125, -- JOGGER
        stats = {}
    }
}

local INDICA_DAMAGE_REDUCTION = 0.15 -- 15% Damage reduction for indica.
local HYBRID_DAMAGE_REDUCTION = 0.15 -- 15% Damage reduction for hybrid.
local SATIVA_DAMAGE_INCREASE = 0.15 -- 15% Damage increase for sativa.

local function sendGardenUI(player, payload)
    if not isElement(player) then
        return
    end

    triggerClientEvent(player, "weedGarden:openUI", resourceRoot, payload or {})
end

function openGardenUI(player, payload)
    sendGardenUI(player, payload)
end

function updateGardenUI(player, payload)
    if isElement(player) then
        triggerClientEvent(player, "weedGarden:updateUI", resourceRoot, payload or {})
    end
end

function closeGardenUI(player)
    if isElement(player) then
        triggerClientEvent(player, "weedGarden:closeUI", resourceRoot)
    end
end

local function getGardenPayload(note, resetSelection)
    return {
        title = "System Monitor",
        zone = "Fog of War Garden",
        stage = "Vegetative",
        plants = 28,
        ready = 22,
        health = 87,
        water = 64,
        nutrients = 72,
        light = 11,
        temperature = 28,
        humidity = 58,
        gravity = "Normal",
        speed = "Normal",
        healthRegen = 0,
        armorRegen = 0,
        status = "Stable",
        note = note or "SELECT A STRAIN.",
        resetSelection = resetSelection == true,
        actions = {
            "BUY",
            "HARVEST",
            "CART"
        },
        buySizes = {
            { label = "1/8", value = "eighth" },
            { label = "Ounce", value = "ounce" },
            { label = "QP", value = "qp" }
        }
    }
end

local function sendShopMessage(player, message, resetSelection)
    updateGardenUI(player, getGardenPayload(message, resetSelection))
end

local function restorePlayerPerks(player)
    local active = playerPerks[player]
    if not active then
        return
    end

    if active.expireTimer and isTimer(active.expireTimer) then
        killTimer(active.expireTimer)
    end

    if active.regenTimer and isTimer(active.regenTimer) then
        killTimer(active.regenTimer)
    end

    if isElement(player) then
        if active.weapon then
            takeWeapon(player, active.weapon)
        end

        setPedGravity(player, active.baseGravity or 0.008)
        setPedWalkingStyle(player, active.baseWalkingStyle or 0)

        for statId, statValue in pairs(active.baseStats or {}) do
            setPedStat(player, statId, statValue)
        end

        setElementData(player, "weed.perk", false)
        setElementData(player, "weed.strain", false)
    end

    playerPerks[player] = nil
end

local function equipPlayerPerks(player, strainName, strainType, packageName)
    local perks = PERK_SETTINGS[strainType]
    local package = PACKAGE_SETTINGS[packageName]
    if not perks or not package then
        return false
    end

    local previous = playerPerks[player]
    local baseGravity = previous and previous.baseGravity or getPedGravity(player)
    local baseStats = previous and previous.baseStats or {}

    if previous then
        if previous.expireTimer and isTimer(previous.expireTimer) then
            killTimer(previous.expireTimer)
        end

        if previous.regenTimer and isTimer(previous.regenTimer) then
            killTimer(previous.regenTimer)
        end

        if previous.weapon then
            takeWeapon(player, previous.weapon)
        end

        setPedGravity(player, baseGravity)
        for statId, statValue in pairs(baseStats) do
            setPedStat(player, statId, statValue)
        end
    end

    for statId in pairs(perks.stats) do
        if baseStats[statId] == nil then
            baseStats[statId] = getPedStat(player, statId)
        end
    end

    local baseWalkingStyle = previous and previous.baseWalkingStyle or getPedWalkingStyle(player)

    local active = {
        weapon = perks.weapon,
        baseGravity = baseGravity,
        baseWalkingStyle = baseWalkingStyle,
        baseStats = baseStats
    }

    playerPerks[player] = active

    setPedGravity(player, perks.gravity or baseGravity)

    for statId, statValue in pairs(perks.stats) do
        setPedStat(player, statId, statValue)
    end

    giveWeapon(player, perks.weapon, package.flowerAmmo, true)

    if perks.walkingStyle then
        setPedWalkingStyle(player, perks.walkingStyle)
    end
    
    setElementData(player, "weed.perk", strainType)
    setElementData(player, "weed.strain", strainName)

    if perks.healthRegen > 0 or perks.armorRegen > 0 then
        active.regenTimer = setTimer(function(targetPlayer)
            if not isElement(targetPlayer) or playerPerks[targetPlayer] ~= active then
                return
            end

            local health = getElementHealth(targetPlayer)
            if health > 0 and health < 100 then
                setElementHealth(targetPlayer, math.min(100, health + perks.healthRegen))
            end

            local armor = getPedArmor(targetPlayer)
            if armor < 100 then
                setPedArmor(targetPlayer, math.min(100, armor + perks.armorRegen))
            end
        end, 5000, 0, player)
    end

    active.expireTimer = setTimer(function(targetPlayer)
        if not isElement(targetPlayer) or playerPerks[targetPlayer] ~= active then
            return
        end

        restorePlayerPerks(targetPlayer)
        outputChatBox("[NOTIFICATION] Your equipped weed perks have worn off.", targetPlayer, 255, 250, 80)
    end, package.duration, 1, player)

    return true
end

local function getPlayerShopState(player)
    if not playerShopState[player] then
        playerShopState[player] = {
            revision = 0
        }
    end

    return playerShopState[player]
end

local function scheduleIdleReset(player, state)
    state.revision = state.revision + 1
    local revision = state.revision

    setTimer(function(targetPlayer)
        if not isElement(targetPlayer) then
            return
        end

        local currentState = playerShopState[targetPlayer]
        if not currentState or currentState.revision ~= revision then
            return
        end

        currentState.strain = nil
        currentState.package = nil
        sendShopMessage(targetPlayer, "SELECT A STRAIN.", true)
    end, 2200, 1, player)
end

local function handlePurchase(player, state)
    if getElementData(player, "atWeedGarden") ~= true then
        sendShopMessage(player, "YOU MUST REMAIN AT THE GARDEN.")
        return
    end

    if not state.strain or not STRAINS[state.strain] then
        sendShopMessage(player, "SELECT A STRAIN.", true)
        return
    end

    if not state.package or not PACKAGE_SETTINGS[state.package] then
        sendShopMessage(player, "SELECT A PACKAGE SIZE.")
        return
    end

    local strain = STRAINS[state.strain]
    local package = PACKAGE_SETTINGS[state.package]
    local price = strain.prices[state.package]

    if not price or getPlayerMoney(player) < price then
        sendShopMessage(player, "SORRY, INSUFFICIENT FUNDS.")
        scheduleIdleReset(player, state)
        return
    end

    takePlayerMoney(player, price)
    equipPlayerPerks(player, state.strain, strain.type, state.package)

    sendShopMessage(
        player,
        "PURCHASE COMPLETE: " .. package.label .. " " .. string.upper(state.strain) .. " FOR $" .. price .. "."
    )
    outputChatBox("[NOTIFICATION] Aye-aye, great choice! Perks equipped.", player, 255, 250, 80)
    scheduleIdleReset(player, state)
end

local function handleShopAction(player, actionName)
    if type(actionName) ~= "string" or #actionName > 80 then
        return
    end

    local state = getPlayerShopState(player)
    state.revision = state.revision + 1

    if actionName == "BUY" then
        handlePurchase(player, state)
        return
    end

    if actionName == "CART" then
        if not state.strain then
            sendShopMessage(player, "SELECT A STRAIN.", true)
            return
        end

        state.package = "cart"
        return
    end

    local strainName = actionName:match("^strain:(.+)$")
    if strainName then
        if not STRAINS[strainName] then
            sendShopMessage(player, "SELECT A STRAIN.", true)
            return
        end

        state.strain = strainName
        state.package = nil
        return
    end

    local packageName = actionName:match("^buy:(.+)$")
    if packageName then
        if not state.strain then
            sendShopMessage(player, "SELECT A STRAIN.", true)
            return
        end

        if not PACKAGE_SETTINGS[packageName] or packageName == "cart" then
            sendShopMessage(player, "SELECT A PACKAGE SIZE.")
            return
        end

        state.package = packageName
        return
    end
end

addEvent("weedGarden:requestOpen", true)
addEventHandler("weedGarden:requestOpen", resourceRoot, function()
    if getElementData(client, "atWeedGarden") == true then
        previewState[client] = true
        playerShopState[client] = { revision = 0 }
        sendGardenUI(client, getGardenPayload("SELECT A STRAIN.", true))
    else
        outputChatBox("Error: You must be at the garden.", client, 127, 255, 212)
    end
end)

addEvent("weedGarden:requestClose", true)
addEventHandler("weedGarden:requestClose", resourceRoot, function()
    if isElement(client) then
        triggerClientEvent(client, "weedGarden:closeUI", resourceRoot)
    end
end)

addEvent("weedGarden:requestUpdate", true)
addEventHandler("weedGarden:requestUpdate", resourceRoot, function(payload)
    if isElement(client) then
        triggerClientEvent(client, "weedGarden:updateUI", resourceRoot, payload or {})
    end
end)

addEvent("weedGarden:uiAction", true)
addEventHandler("weedGarden:uiAction", resourceRoot, function(actionName)
    if not isElement(client) then
        return
    end

    handleShopAction(client, actionName)
    triggerEvent("weedGarden:action", resourceRoot, client, actionName)
end)

addEvent("weedGarden:action")

addEvent("weedGarden:uiClosed", true)
addEventHandler("weedGarden:uiClosed", resourceRoot, function()
    if isElement(client) then
        previewState[client] = nil
        playerShopState[client] = nil
    end
end)

addEventHandler("onPlayerWasted", root, function()
    restorePlayerPerks(source)
end)

addEventHandler("onPlayerDamage", root, function(attacker, weapon, bodypart, loss)
    if wasEventCancelled() then
        return
    end

    local damageMultiplier = 1
    local activePerk = getElementData(source, "weed.perk")

    if activePerk == "indica" then
        damageMultiplier = damageMultiplier * (1 - INDICA_DAMAGE_REDUCTION)
    elseif activePerk == "hybrid" then
        damageMultiplier = damageMultiplier * (1 - HYBRID_DAMAGE_REDUCTION)
    elseif activePerk == "sativa" then
        damageMultiplier = damageMultiplier * (1 + SATIVA_DAMAGE_INCREASE)
    end

    if damageMultiplier == 1 then
        return
    end

    cancelEvent()

    setTimer(function(player, adjustedLoss)
        if not isElement(player) or isPedDead(player) then
            return
        end

        setElementHealth(player, math.max(0, getElementHealth(player) - adjustedLoss))
    end, 50, 1, source, loss * damageMultiplier)
end, false, "low")

addEventHandler("onPlayerQuit", root, function()
    previewState[source] = nil
    playerShopState[source] = nil
    restorePlayerPerks(source)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for player in pairs(playerPerks) do
        restorePlayerPerks(player)
    end
end)
