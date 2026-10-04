local previewState = {}
local playerShopState = {}
local playerPerks = {}

local PACKAGE_SETTINGS = {
    cart = {
        label = "CART",
        duration = 5 * 60 * 1000,
        flowerAmmo = 60
    },
    eighth = {
        label = "1/8",
        duration = 10 * 60 * 1000,
        flowerAmmo = 120
    },
    ounce = {
        label = "OUNCE",
        duration = 20 * 60 * 1000,
        flowerAmmo = 250
    },
    qp = {
        label = "QP",
        duration = 30 * 60 * 1000,
        flowerAmmo = 500
    }
}

local STRAINS = {
    ["Granddaddy Purple"] = {
        type = "indica",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Northern Lights"] = {
        type = "indica",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Bubba Kush"] = {
        type = "indica",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Purple Kush"] = {
        type = "indica",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Hindu Kush"] = {
        type = "indica",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Sour Diesel"] = {
        type = "sativa",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Durban Poison"] = {
        type = "sativa",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Jack Herer"] = {
        type = "sativa",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Green Crack"] = {
        type = "sativa",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Super Lemon Haze"] = {
        type = "sativa",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Gorilla Glue"] = {
        type = "hybrid",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Girl Scout Cookies"] = {
        type = "hybrid",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["OG Kush"] = {
        type = "hybrid",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["White Widow"] = {
        type = "hybrid",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    },
    ["Blue Zushi"] = {
        type = "hybrid",
        prices = {
            eighth = 900,
            ounce = 1600,
            qp = 2200,
            cart = 500
        }
    }
}

-- PREMIUM STOCK PRICES
local STRAIN_PRICE_FACTORS = {
    ["Hindu Kush"] = 0.80,
    ["Bubba Kush"] = 0.85,
    ["Purple Kush"] = 0.90,
    ["Northern Lights"] = 0.95,
    ["Granddaddy Purple"] = 1.00,
    ["Durban Poison"] = 1.05,
    ["Green Crack"] = 1.10,
    ["Jack Herer"] = 1.15,
    ["Sour Diesel"] = 1.20,
    ["Super Lemon Haze"] = 1.25,
    ["White Widow"] = 1.30,
    ["Gorilla Glue"] = 1.35,
    ["OG Kush"] = 1.40,
    ["Girl Scout Cookies"] = 1.45,
    ["Blue Zushi"] = 1.50
}

for name, strain in pairs(STRAINS) do
    for size, price in pairs(strain.prices) do
        strain.prices[size] = math.floor(price * STRAIN_PRICE_FACTORS[name] / 5 + 0.5) * 5
    end
end

local unavailableStrains = {}
local STOCK_INTERVAL = 30 * 60 * 1000

local function getStrainCatalog()
    local catalog = {}
    for name, strain in pairs(STRAINS) do
        catalog[name] = {prices = strain.prices, available = not unavailableStrains[name]}
    end
    return catalog
end

local function rotateStock()
    local names = {}
    for name in pairs(STRAINS) do table.insert(names, name) end
    for index = #names, 2, -1 do
        local other = math.random(index)
        names[index], names[other] = names[other], names[index]
    end
    unavailableStrains = {}
    for index = 1, math.random(1, 2) do unavailableStrains[names[index]] = true end
    local catalog = getStrainCatalog()
    for player in pairs(previewState) do
        if isElement(player) then
            triggerClientEvent(player, "weedGarden:stockUpdate", resourceRoot, catalog)
        end
    end
end

rotateStock()
setTimer(rotateStock, STOCK_INTERVAL, 0)

local FLOWER_WEAPON = 14
local SPRAYCAN_WEAPON = 41
local HARVEST_SPRAYCAN_AMMO = 1000
local HARVEST_SPRAYCAN_AMMO_LIMIT = 3000

local PERK_SETTINGS = {
    indica = {
        weapon = FLOWER_WEAPON,
        fightingStyle = 15,
        healthRegen = 5,
        armorRegen = 25,
        gravity = 0.020,
        drivingGravity = 0.012,
        gravityLabel = "High",
        speedLabel = "Slow",
        walkingStyle = 120 -- OLD FATMAN
    },
    sativa = {
        weapon = FLOWER_WEAPON,
        fightingStyle = 5,
        healthRegen = 10,
        armorRegen = 10,
        gravityLabel = "Normal",
        speedLabel = "Fast",
        walkingStyle = 0 -- DEFAULT
    },
    hybrid = {
        weapon = FLOWER_WEAPON,
        fightingStyle = 7,
        healthRegen = 25,
        armorRegen = 5,
        gravity = 0.003, -- LOW GRAVITY JUMP
        gravityLabel = "Low",
        speedLabel = "Normal",
        walkingStyle = 125 -- JOGGER
    }
}

local INDICA_DAMAGE_REDUCTION = 0.15 -- 15% Damage reduction for indica.
local HYBRID_DAMAGE_REDUCTION = 0.15 -- 15% Damage reduction for hybrid.
local SATIVA_DAMAGE_INCREASE = 0.15 -- 15% Damage increase for sativa.

local function getPerkPreview(player)
    local active = playerPerks[player]
    local remaining = active and isTimer(active.expireTimer) and getTimerDetails(active.expireTimer) or 0
    return {
        type = remaining > 0 and getElementData(player, "weed.perk") or false,
        remaining = remaining,
        duration = active and active.duration or 0
    }
end

local function addPreviewData(player, payload)
    payload = payload or {}
    payload.perkPreview = getPerkPreview(player)
    payload.strainCatalog = getStrainCatalog()
    payload.packageDurations = {}
    for name, package in pairs(PACKAGE_SETTINGS) do
        payload.packageDurations[name] = package.duration
    end
    return payload
end

local function sendGardenUI(player, payload)
    if not isElement(player) then
        return
    end

    previewState[player] = true
    triggerClientEvent(player, "weedGarden:openUI", resourceRoot, addPreviewData(player, payload))
end

function openGardenUI(player, payload)
    sendGardenUI(player, payload)
end

function updateGardenUI(player, payload)
    if isElement(player) then
        triggerClientEvent(player, "weedGarden:updateUI", resourceRoot, addPreviewData(player, payload))
    end
end

function closeGardenUI(player)
    previewState[player] = nil
    if isElement(player) then
        triggerClientEvent(player, "weedGarden:closeUI", resourceRoot)
    end
end

local function getGardenPayload(note, resetSelection)
    return {
        title = "Monitor System",
        zone = "Fog of War Garden",
        ready = 22,
        health = 87,
        water = 64,
        gravity = "Normal",
        speed = "Normal",
        healthRegen = 0,
        armorRegen = 0,
        status = "Stable",
        note = note or "SELECT A STRAIN.",
        resetSelection = resetSelection == true,
        actions = {"BUY", "HARVEST", "CART"},
        buySizes = {{
            label = "1/8",
            value = "eighth"
        }, {
            label = "OUNCE",
            value = "ounce"
        }, {
            label = "QP",
            value = "qp"
        }}
    }
end

local function sendShopMessage(player, message, resetSelection)
    updateGardenUI(player, getGardenPayload(message, resetSelection))
end

local function sendWeedNotification(player, message)
    outputChatBox(message, player, 127, 255, 212)
end

local function isAircraft(vehicle)
    if not isElement(vehicle) then return false end
    local vehicleType = getVehicleType(vehicle)
    return vehicleType == "Plane" or vehicleType == "Helicopter"
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

        setPedGravity(player, isAircraft(getPedOccupiedVehicle(player)) and 0.008 or (active.baseGravity or 0.008))
        setPedWalkingStyle(player, active.baseWalkingStyle or 0)
        setPedFightingStyle(player, active.baseFightingStyle or 4)

        setElementData(player, "weed.perk", false)
        setElementData(player, "weed.strain", false)
    end

    playerPerks[player] = nil
    if isElement(player) then
        triggerClientEvent(player, "weedGarden:perkPreview", resourceRoot, getPerkPreview(player))
    end
end

local function equipPlayerPerks(player, strainName, strainType, packageName)
    local perks = PERK_SETTINGS[strainType]
    local package = PACKAGE_SETTINGS[packageName]
    if not perks or not package then
        return false
    end

    local previous = playerPerks[player]
    local baseGravity = previous and previous.baseGravity or getPedGravity(player)

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
    end

    local baseWalkingStyle = previous and previous.baseWalkingStyle or getPedWalkingStyle(player)
    local baseFightingStyle = previous and previous.baseFightingStyle or getPedFightingStyle(player)
    local fightingStyleRoll = math.random(1, 100)
    local fightingStyle = perks.fightingStyle
    if fightingStyleRoll <= 5 then
        fightingStyle = 6
    elseif fightingStyleRoll <= 10 then
        fightingStyle = 16
    end

    local active = {
        duration = package.duration,
        weapon = perks.weapon,
        baseGravity = baseGravity,
        baseWalkingStyle = baseWalkingStyle,
        baseFightingStyle = baseFightingStyle
    }

    playerPerks[player] = active

    local gravity = perks.gravity or baseGravity
    if isAircraft(getPedOccupiedVehicle(player)) then
        gravity = 0.008
    elseif perks.drivingGravity and isPedInVehicle(player) and getPedOccupiedVehicleSeat(player) == 0 then
        gravity = perks.drivingGravity
    end
    setPedGravity(player, gravity)
    setPedFightingStyle(player, fightingStyle)

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
        sendWeedNotification(targetPlayer, "Your equipped weed perks have worn off.")
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
    if unavailableStrains[state.strain] then
        sendShopMessage(player, string.upper(state.strain) .. " IS CURRENTLY UNAVAILABLE.")
        return
    end
    local package = PACKAGE_SETTINGS[state.package]
    local price = strain.prices[state.package]

    if not price or getPlayerMoney(player) < price then
        state.insufficientFunds = (state.insufficientFunds or 0) + 1
        local message = state.insufficientFunds > 3 and "YO, GET SOME MONEY DAWG!" or "SORRY, INSUFFICIENT FUNDS."
        sendShopMessage(player, message)
        return
    end

    state.insufficientFunds = 0
    takePlayerMoney(player, price)
    equipPlayerPerks(player, state.strain, strain.type, state.package)

    sendShopMessage(player, "PURCHASE COMPLETE: " .. package.label .. " " .. string.upper(state.strain) .. " FOR $" ..
        price .. ".")
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

    if actionName == "HARVEST" then
        if getElementData(player, "atWeedGarden") ~= true then
            sendShopMessage(player, "YOU MUST REMAIN AT THE GARDEN.")
            return
        end

        local spraycanSlot = getSlotFromWeapon(SPRAYCAN_WEAPON)
        local currentAmmo = getPedTotalAmmo(player, spraycanSlot)

        if currentAmmo >= HARVEST_SPRAYCAN_AMMO_LIMIT then
            sendShopMessage(player, "YOU'VE REACHED THE AMMO LIMIT.")
            return
        end

        local ammoToGive = math.min(HARVEST_SPRAYCAN_AMMO, HARVEST_SPRAYCAN_AMMO_LIMIT - currentAmmo)

        if giveWeapon(player, SPRAYCAN_WEAPON, ammoToGive, true) then
            sendShopMessage(player, "Harvest Tool Available.")
        else
            sendShopMessage(player, "HARVEST FAILED. EQUIPMENT COULD NOT BE ISSUED.")
        end

        return
    end

    if actionName == "CART" then
        if not state.strain then
            sendShopMessage(player, "SELECT A STRAIN.", true)
            return
        end

        state.package = "cart"
        state.insufficientFunds = 0
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
        state.insufficientFunds = 0
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
        state.insufficientFunds = 0
        return
    end
end

addEvent("weedGarden:requestOpen", true)
addEventHandler("weedGarden:requestOpen", resourceRoot, function()
    if getElementData(client, "atWeedGarden") == true then
        previewState[client] = true
        playerShopState[client] = {
            revision = 0
        }
        sendGardenUI(client, getGardenPayload("SELECT A STRAIN.", true))
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

addEventHandler("onPlayerVehicleEnter", root, function(vehicle, seat)
    local perks = PERK_SETTINGS[getElementData(source, "weed.perk")]
    if isAircraft(vehicle) then
        setPedGravity(source, 0.008)
    elseif playerPerks[source] and perks and perks.drivingGravity and seat == 0 then
        setPedGravity(source, perks.drivingGravity)
    end
end, true, "low")

addEventHandler("onPlayerVehicleExit", root, function(vehicle, seat)
    local perks = PERK_SETTINGS[getElementData(source, "weed.perk")]
    if isAircraft(vehicle) then
        local active = playerPerks[source]
        setPedGravity(source, active and perks and (perks.gravity or active.baseGravity or 0.008) or 0.008)
    elseif playerPerks[source] and perks and perks.drivingGravity and seat == 0 then
        setPedGravity(source, perks.gravity)
    end
end, true, "low")

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
