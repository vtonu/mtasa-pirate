local playerShopState = {}

-- ==========================================
-- WEAPON CATALOG
-- ==========================================

local WEAPONS = {
    brass_knuckles = {
        name = "Brass Knuckles",
        symbol = "BK",
        category = "stealth",
        price = 10000,
        weapon = 1,
        ammo = 1,
        winningRate = 49,
        stealth = 90,
        ballistics = 0,
        heavy = 12,
        damage = "LOW",
        range = "CLOSE",
        capacity = "N/A",
        handling = "FAST",
        description = "A compact hand-to-hand upgrade for stronger physical strikes."
    },
    flowers = {
        name = "Flowers",
        symbol = "FLR",
        category = "stealth",
        price = 350,
        weapon = 14,
        ammo = 1,
        available = false,
        winningRate = 31,
        stealth = 98,
        ballistics = 0,
        heavy = 1,
        damage = "LOW",
        range = "CLOSE",
        capacity = "N/A",
        handling = "LIGHT",
        description = "A harmless-looking gift that can still be used at close range."
    },
    cane = {
        name = "Cane",
        symbol = "CNE",
        category = "stealth",
        price = 10,
        weapon = 15,
        ammo = 1,
        winningRate = 38,
        stealth = 86,
        ballistics = 0,
        heavy = 8,
        damage = "LOW",
        range = "CLOSE",
        capacity = "N/A",
        handling = "LIGHT",
        description = "A discreet blunt weapon with quick close-range handling."
    },
    dildo = {
        name = "Dildo",
        symbol = "DLD",
        category = "heavy",
        price = 10,
        weapon = 10,
        ammo = 1,
        winningRate = 34,
        stealth = 18,
        ballistics = 0,
        heavy = 82,
        damage = "LOW",
        range = "CLOSE",
        capacity = "N/A",
        handling = "LIGHT",
        description = "An unconventional close-quarter weapon for chaotic encounters."
    },
    vibrator = {
        name = "Vibrator",
        symbol = "VBR",
        category = "heavy",
        price = 10,
        weapon = 12,
        ammo = 1,
        winningRate = 34,
        stealth = 18,
        ballistics = 0,
        heavy = 82,
        damage = "LOW",
        range = "CLOSE",
        capacity = "N/A",
        handling = "LIGHT",
        description = "A compact novelty weapon with close-range utility."
    },
    knife = {
        name = "Knife",
        symbol = "KNF",
        category = "stealth",
        price = 50000,
        weapon = 4,
        ammo = 1,
        winningRate = 67,
        stealth = 100,
        ballistics = 0,
        heavy = 14,
        damage = "HIGH",
        range = "CLOSE",
        capacity = "N/A",
        handling = "FAST",
        description = "A silent blade suited to close-quarter attacks and stealth takedowns."
    },
    katana = {
        name = "Katana",
        symbol = "KTN",
        category = "stealth",
        price = 100000,
        weapon = 8,
        ammo = 1,
        winningRate = 76,
        stealth = 78,
        ballistics = 0,
        heavy = 35,
        damage = "HIGH",
        range = "CLOSE",
        capacity = "N/A",
        handling = "BALANCED",
        description = "A long blade with excellent melee damage and reach."
    },
    chainsaw = {
        name = "Chainsaw",
        symbol = "CSW",
        category = "stealth",
        price = 10000,
        weapon = 9,
        ammo = 1,
        available = false,
        winningRate = 82,
        stealth = 12,
        ballistics = 0,
        heavy = 92,
        damage = "EXTREME",
        range = "CLOSE",
        capacity = "N/A",
        handling = "HEAVY",
        description = "A devastating close-range tool that sacrifices stealth for raw damage."
    },
    baseball_bat = {
        name = "Baseball Bat",
        symbol = "BAT",
        category = "stealth",
        price = 500,
        weapon = 5,
        ammo = 1,
        winningRate = 55,
        stealth = 76,
        ballistics = 0,
        heavy = 31,
        damage = "MEDIUM",
        range = "CLOSE",
        capacity = "N/A",
        handling = "BALANCED",
        description = "A reliable blunt weapon with solid reach and impact."
    },
    golf_club = {
        name = "Golf Club",
        symbol = "GLF",
        category = "stealth",
        price = 500,
        weapon = 2,
        ammo = 1,
        winningRate = 51,
        stealth = 74,
        ballistics = 0,
        heavy = 27,
        damage = "MEDIUM",
        range = "CLOSE",
        capacity = "N/A",
        handling = "BALANCED",
        description = "A long blunt instrument with useful melee reach."
    },
    nightstick = {
        name = "Nightstick",
        symbol = "NST",
        category = "stealth",
        price = 500,
        weapon = 3,
        ammo = 1,
        winningRate = 57,
        stealth = 82,
        ballistics = 0,
        heavy = 24,
        damage = "MEDIUM",
        range = "CLOSE",
        capacity = "N/A",
        handling = "FAST",
        description = "A fast tactical baton designed for close-range control."
    },
    shovel = {
        name = "Shovel",
        symbol = "SHV",
        category = "stealth",
        price = 10,
        weapon = 6,
        ammo = 1,
        winningRate = 52,
        stealth = 65,
        ballistics = 0,
        heavy = 38,
        damage = "MEDIUM",
        range = "CLOSE",
        capacity = "N/A",
        handling = "HEAVY",
        description = "A sturdy improvised weapon with strong blunt-force impact."
    },
    pool_cue = {
        name = "Pool Cue",
        symbol = "PC",
        category = "stealth",
        price = 500,
        weapon = 7,
        ammo = 1,
        winningRate = 48,
        stealth = 80,
        ballistics = 0,
        heavy = 19,
        damage = "LOW",
        range = "CLOSE",
        capacity = "N/A",
        handling = "FAST",
        description = "A light improvised weapon with quick close-range swings."
    },

    colt_45 = {
        name = "Colt 45",
        symbol = "C45",
        category = "stealth",
        price = 500,
        weapon = 22,
        ammo = 1000,
        winningRate = 61,
        stealth = 72,
        ballistics = 45,
        heavy = 10,
        damage = "MEDIUM",
        range = "MEDIUM",
        capacity = "1000",
        handling = "FAST",
        description = "A dependable sidearm with manageable recoil and good accuracy."
    },
    silenced_9mm = {
        name = "Silenced 9mm",
        symbol = "S9",
        category = "stealth",
        price = 500,
        weapon = 23,
        ammo = 1000,
        winningRate = 69,
        stealth = 96,
        ballistics = 64,
        heavy = 8,
        damage = "MEDIUM",
        range = "MEDIUM",
        capacity = "1000",
        handling = "PRECISE",
        description = "A suppressed pistol combining stealth with accurate direct fire."
    },
    desert_eagle = {
        name = "Desert Eagle",
        symbol = "DE",
        category = "ballistics",
        price = 25000,
        weapon = 24,
        ammo = 500,
        winningRate = 79,
        stealth = 18,
        ballistics = 92,
        heavy = 32,
        damage = "HIGH",
        range = "MEDIUM",
        capacity = "500",
        handling = "HEAVY",
        description = "A powerful handgun with high damage and substantial recoil."
    },
    tec_9 = {
        name = "Tec-9",
        symbol = "T9",
        category = "ballistics",
        price = 25000,
        weapon = 32,
        ammo = 1000,
        winningRate = 70,
        stealth = 16,
        ballistics = 80,
        heavy = 22,
        damage = "MEDIUM",
        range = "SHORT",
        capacity = "1000",
        handling = "RAPID",
        description = "A compact automatic weapon favoring mobility and volume of fire."
    },
    micro_smg = {
        name = "Double UZI",
        symbol = "UZI",
        category = "ballistics",
        price = 25000,
        weapon = 28,
        ammo = 1000,
        stat = 75,
        statValue = 1000,
        winningRate = 72,
        stealth = 14,
        ballistics = 83,
        heavy = 24,
        damage = "MEDIUM",
        range = "SHORT",
        capacity = "1000",
        handling = "RAPID",
        description = "Dual compact automatic sidearms effective in close gunfights."
    },
    mp5 = {
        name = "MP5",
        symbol = "MP5",
        category = "stealth",
        price = 10000,
        weapon = 29,
        ammo = 500,
        winningRate = 78,
        stealth = 90,
        ballistics = 78,
        heavy = 27,
        damage = "MEDIUM",
        range = "MEDIUM",
        capacity = "500",
        handling = "STABLE",
        description = "A controlled submachine gun with strong accuracy and fire rate."
    },
    shotgun = {
        name = "Shotgun",
        symbol = "SG",
        category = "ballistics",
        price = 25000,
        weapon = 25,
        ammo = 500,
        winningRate = 73,
        stealth = 8,
        ballistics = 76,
        heavy = 48,
        damage = "HIGH",
        range = "SHORT",
        capacity = "500",
        handling = "PUMP",
        description = "A reliable pump shotgun delivering heavy close-range damage."
    },
    sawn_off = {
        name = "Sawn-off Shotgun",
        symbol = "SOS",
        category = "ballistics",
        price = 35000,
        weapon = 26,
        ammo = 500,
        winningRate = 81,
        stealth = 6,
        ballistics = 80,
        heavy = 58,
        damage = "EXTREME",
        range = "SHORT",
        capacity = "500",
        handling = "FAST",
        description = "A compact shotgun with devastating close-range burst damage."
    },
    combat_shotgun = {
        name = "Combat Shotgun",
        symbol = "CSG",
        category = "ballistics",
        price = 45000,
        weapon = 27,
        ammo = 500,
        winningRate = 88,
        stealth = 5,
        ballistics = 91,
        heavy = 67,
        damage = "EXTREME",
        range = "SHORT",
        capacity = "500",
        handling = "RAPID",
        description = "A fast-firing shotgun built to dominate close combat."
    },
    ak_47 = {
        name = "AK-47",
        symbol = "AK",
        category = "ballistics",
        price = 45000,
        weapon = 30,
        ammo = 500,
        winningRate = 84,
        stealth = 4,
        ballistics = 94,
        heavy = 54,
        damage = "HIGH",
        range = "LONG",
        capacity = "500",
        handling = "STRONG",
        description = "A hard-hitting assault rifle with dependable long-range firepower."
    },
    m4 = {
        name = "M4",
        symbol = "M4",
        category = "ballistics",
        price = 45000,
        weapon = 31,
        ammo = 500,
        winningRate = 90,
        stealth = 5,
        ballistics = 98,
        heavy = 52,
        damage = "HIGH",
        range = "LONG",
        capacity = "500",
        handling = "PRECISE",
        description = "An accurate assault rifle with excellent range and sustained fire."
    },
    country_rifle = {
        name = "Country Rifle",
        symbol = "CR",
        category = "ballistics",
        price = 35000,
        weapon = 33,
        ammo = 500,
        winningRate = 75,
        stealth = 26,
        ballistics = 86,
        heavy = 35,
        damage = "HIGH",
        range = "LONG",
        capacity = "500",
        handling = "SINGLE",
        description = "A traditional long-range rifle with strong single-shot damage."
    },
    sniper_rifle = {
        name = "Sniper Rifle",
        symbol = "SR",
        category = "ballistics",
        price = 100000,
        weapon = 34,
        ammo = 10,
        winningRate = 93,
        stealth = 42,
        ballistics = 100,
        heavy = 41,
        damage = "EXTREME",
        range = "EXTREME",
        capacity = "10",
        handling = "PRECISE",
        description = "A scoped rifle designed for accurate elimination at extreme range."
    },

    grenade = {
        name = "Grenades",
        symbol = "GRN",
        category = "heavy",
        price = 10000,
        weapon = 16,
        ammo = 10,
        winningRate = 72,
        stealth = 4,
        ballistics = 20,
        heavy = 86,
        damage = "EXTREME",
        range = "THROWN",
        capacity = "10",
        handling = "TACTICAL",
        description = "Thrown explosives that deal area damage after a short fuse."
    },
    satchel = {
        name = "Satchels",
        symbol = "SAT",
        category = "heavy",
        price = 10000,
        weapon = 39,
        ammo = 10,
        winningRate = 86,
        stealth = 52,
        ballistics = 12,
        heavy = 96,
        damage = "EXTREME",
        range = "REMOTE",
        capacity = "10",
        handling = "TACTICAL",
        description = "Remote explosives for traps, ambushes, and controlled demolition."
    },
    molotov = {
        name = "Molotov Cocktails",
        symbol = "MOL",
        category = "heavy",
        price = 10000,
        weapon = 18,
        ammo = 10,
        winningRate = 70,
        stealth = 3,
        ballistics = 16,
        heavy = 82,
        damage = "HIGH",
        range = "THROWN",
        capacity = "10",
        handling = "TACTICAL",
        description = "Incendiary projectiles that spread fire across an area."
    },
    tear_gas = {
        name = "Tear Gas",
        symbol = "TG",
        category = "heavy",
        price = 10000,
        weapon = 17,
        ammo = 10,
        winningRate = 60,
        stealth = 18,
        ballistics = 8,
        heavy = 65,
        damage = "CONTROL",
        range = "THROWN",
        capacity = "10",
        handling = "TACTICAL",
        description = "Non-lethal tactical gas used to deny space and disrupt targets."
    },
    rocket_launcher = {
        name = "RPG",
        symbol = "RL",
        category = "heavy",
        price = 100000,
        weapon = 35,
        ammo = 10,
        winningRate = 95,
        stealth = 0,
        ballistics = 24,
        heavy = 100,
        damage = "EXTREME",
        range = "LONG",
        capacity = "10",
        handling = "HEAVY",
        description = "Heavy explosive ordnance for vehicles and grouped targets."
    },
    heat_rocket = {
        name = "Heat-Seeking Launcher",
        symbol = "HSL",
        category = "heavy",
        price = 100000,
        weapon = 36,
        ammo = 10,
        winningRate = 97,
        stealth = 0,
        ballistics = 30,
        heavy = 100,
        damage = "EXTREME",
        range = "LONG",
        capacity = "10",
        handling = "LOCK-ON",
        description = "A guided launcher designed to track and destroy vehicle targets."
    },
    flamethrower = {
        name = "Flamethrower",
        symbol = "FLM",
        category = "heavy",
        price = 500,
        weapon = 37,
        ammo = 1000,
        winningRate = 91,
        stealth = 0,
        ballistics = 14,
        heavy = 96,
        damage = "EXTREME",
        range = "SHORT",
        capacity = "1000",
        handling = "STREAM",
        description = "A heavy weapon projecting continuous fire over a short distance."
    },
    minigun = {
        name = "Minigun",
        symbol = "MIN",
        category = "heavy",
        price = 10000000,
        weapon = 38,
        ammo = 500,
        winningRate = 99,
        stealth = 0,
        ballistics = 88,
        heavy = 100,
        damage = "EXTREME",
        range = "LONG",
        capacity = "500",
        handling = "HEAVY",
        description = "The most expensive weapon in the shop, delivering overwhelming sustained fire."
    },
    parachute = {
        name = "Parachute",
        symbol = "PAR",
        category = "stealth",
        price = 500,
        weapon = 46,
        ammo = 1,
        winningRate = 58,
        stealth = 88,
        ballistics = 0,
        heavy = 22,
        damage = "NONE",
        range = "UTILITY",
        capacity = "1",
        handling = "MOBILE",
        description = "Safety equipment for controlled descents from extreme heights."
    },
    spraycan = {
        name = "Spraycan",
        symbol = "SPY",
        category = "stealth",
        price = 500,
        weapon = 41,
        ammo = 1000,
        available = false,
        winningRate = 40,
        stealth = 78,
        ballistics = 2,
        heavy = 18,
        damage = "LOW",
        range = "SHORT",
        capacity = "1000",
        handling = "UTILITY",
        description = "A utility tool with short-range spray and unusual combat applications."
    },
    extinguisher = {
        name = "Fire Extinguisher",
        symbol = "EXT",
        category = "stealth",
        price = 500,
        weapon = 42,
        ammo = 1000,
        winningRate = 44,
        stealth = 74,
        ballistics = 2,
        heavy = 24,
        damage = "LOW",
        range = "SHORT",
        capacity = "1000",
        handling = "UTILITY",
        description = "A tactical utility tool for suppressing fires and disrupting targets."
    },
    night_vision = {
        name = "Night Vision Goggles",
        symbol = "NVG",
        category = "stealth",
        price = 500000,
        weapon = 44,
        ammo = 1,
        winningRate = 68,
        stealth = 92,
        ballistics = 8,
        heavy = 24,
        damage = "NONE",
        range = "OPTICAL",
        capacity = "1",
        handling = "TACTICAL",
        description = "Specialized optics for improved visibility in darkness."
    },
    thermal = {
        name = "Thermal Goggles",
        symbol = "THM",
        category = "stealth",
        price = 1000000,
        weapon = 45,
        ammo = 1,
        winningRate = 74,
        stealth = 90,
        ballistics = 10,
        heavy = 28,
        damage = "NONE",
        range = "OPTICAL",
        capacity = "1",
        handling = "TACTICAL",
        description = "Advanced optics that highlight heat signatures through poor visibility."
    },
    jetpack = {
        name = "Jetpack",
        symbol = "JET",
        category = "heavy",
        price = 100000,
        available = false,
        winningRate = 99,
        stealth = 8,
        ballistics = 0,
        heavy = 100,
        damage = "NONE",
        range = "AIRBORNE",
        capacity = "N/A",
        handling = "SPECIAL",
        description = "Rare tactical mobility gear providing unrestricted airborne movement."
    },
    detonator = {
        name = "Detonator",
        symbol = "DET",
        category = "heavy",
        price = 500,
        weapon = 40,
        ammo = 1,
        winningRate = 55,
        stealth = 88,
        ballistics = 0,
        heavy = 48,
        damage = "REMOTE",
        range = "REMOTE",
        capacity = "1",
        handling = "TACTICAL",
        description = "The remote trigger used to detonate placed satchel charges."
    }
}

local function getWeaponPayload()
    local payload = {}

    for id, weapon in pairs(WEAPONS) do
        local item = {}
        for key, value in pairs(weapon) do
            item[key] = value
        end
        item.id = id
        table.insert(payload, item)
    end

    table.sort(payload, function(left, right)
        if left.category == right.category then
            return left.price < right.price
        end
        return left.category < right.category
    end)

    return payload
end

local function getShopPayload(note, resetSelection)
    return {
        title = "Shop System",
        zone = "Pirate in Men's Pants",
        stock = "Available",
        note = note or "SELECT A WEAPON.",
        resetSelection = resetSelection == true,
        weapons = getWeaponPayload()
    }
end

local function updateShop(player, note, resetSelection)
    if isElement(player) then
        triggerClientEvent(player, "bootyShop:updateUI", resourceRoot, getShopPayload(note, resetSelection))
    end
end

function openBootyUI(player)
    if not isElement(player) or getElementData(player, "atBootyShop") ~= true then
        return false
    end

    playerShopState[player] = {}
    triggerClientEvent(player, "bootyShop:openUI", resourceRoot, getShopPayload("SELECT A WEAPON.", true))
    return true
end

function closeBootyUI(player)
    if isElement(player) then
        triggerClientEvent(player, "bootyShop:closeUI", resourceRoot)
    end
    playerShopState[player] = nil
end

addEvent("bootyShop:requestOpen", true)
addEventHandler("bootyShop:requestOpen", resourceRoot, function()
    openBootyUI(client)
end)

local function purchaseWeapon(player, weaponId)
    local weapon = WEAPONS[weaponId]

    if not weapon or getElementData(player, "atBootyShop") ~= true then
        updateShop(player, "YOU MUST REMAIN AT THE BOOTY DESK.")
        return
    end

    if weapon.available == false then
        updateShop(player, string.upper(weapon.name) .. " IS CURRENTLY UNAVAILABLE.")
        return
    end

    if getPlayerMoney(player) < weapon.price then
        local state = playerShopState[player] or {}
        state.insufficientFunds = (state.insufficientFunds or 0) + 1
        playerShopState[player] = state
        local message = state.insufficientFunds > 3 and "YO, GET SOME MONEY DAWG!" or "SORRY, INSUFFICIENT FUNDS."
        updateShop(player, message)
        return
    end

    local granted = false

    if weapon.weapon == 0 then
        setPedWeaponSlot(player, 0)
        granted = true
    else
        granted = giveWeapon(player, weapon.weapon, weapon.ammo or 1, true) == true
    end

    if not granted then
        updateShop(player, "PURCHASE FAILED. EQUIPMENT COULD NOT BE ISSUED.")
        return
    end

    if weapon.stat and weapon.statValue then
        setPedStat(player, weapon.stat, weapon.statValue)
    end

    takePlayerMoney(player, weapon.price)
    local state = playerShopState[player]
    if state then
        state.insufficientFunds = 0
    end
    updateShop(player, "PURCHASE COMPLETE: " .. string.upper(weapon.name) .. " FOR $" .. weapon.price .. ".")
    outputChatBox("[NOTIFICATION] Aye-aye! " .. weapon.name .. " purchased.", player, 255, 250, 80)
end

addEvent("bootyShop:uiAction", true)
addEventHandler("bootyShop:uiAction", resourceRoot, function(actionName)
    if not isElement(client) or type(actionName) ~= "string" or #actionName > 80 then
        return
    end

    local weaponId = actionName:match("^select:(.+)$")
    if weaponId and WEAPONS[weaponId] then
        playerShopState[client] = {
            weaponId = weaponId,
            insufficientFunds = 0
        }
        return
    end

    if actionName == "buy" then
        local state = playerShopState[client]
        if not state or not state.weaponId then
            updateShop(client, "SELECT A WEAPON.", true)
            return
        end

        purchaseWeapon(client, state.weaponId)
    end
end)

addEvent("bootyShop:uiClosed", true)
addEventHandler("bootyShop:uiClosed", resourceRoot, function()
    playerShopState[client] = nil
end)

addEventHandler("onPlayerQuit", root, function()
    playerShopState[source] = nil
end)
