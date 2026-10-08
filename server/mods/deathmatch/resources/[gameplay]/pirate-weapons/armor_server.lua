-- PURCHASED ARMOUR TIERS; REGENERATION COMES ONLY FROM EXISTING WEED PERKS
bootyArmorTiers = {
    soft = {name = "SOFT VEST", price = 10000, drain = 1, durability = "1X"},
    reinforced = {name = "REINFORCED VEST", price = 20000, drain = 0.5, durability = "2X"},
    hard = {name = "HARD PLATE", price = 50000, drain = 0.25, durability = "4X"}
}
local equipped = {}

local function clearArmor(player)
    equipped[player] = nil
    if isElement(player) then setElementData(player, "booty:armorTier", false) end
end

function equipBootyArmor(player, tier)
    if not bootyArmorTiers[tier] or not isElement(player) or isPedDead(player) then return false end
    if not setPedArmor(player, 100) then return false end
    equipped[player] = tier
    setElementData(player, "booty:armorTier", tier)
    return true
end

addEvent("bootyArmorReset", false)
addEventHandler("bootyArmorReset", root, function() clearArmor(source) end)
addEventHandler("onPlayerPickupUse", root, function(player)
    if getPickupType(source) == 1 then clearArmor(player) end
end)
addEventHandler("onPlayerWasted", root, function() clearArmor(source) end)
addEventHandler("onPlayerSpawn", root, function() clearArmor(source) end)
addEventHandler("onPlayerQuit", root, function() equipped[source] = nil end)

addEvent("bootyArmorDepleted", true)
addEventHandler("bootyArmorDepleted", resourceRoot, function()
    if source == resourceRoot and client and equipped[client] then clearArmor(client) end
end)

-- KEEP LETHAL OVERFLOW AND KILL CREDIT ON THE SERVER
addEvent("bootyArmorOverflow", true)
addEventHandler("bootyArmorOverflow", resourceRoot, function(loss, attacker, weapon, bodypart)
    if source ~= resourceRoot or not client or not equipped[client] or isPedDead(client)
        or getElementData(client, "freeroam.passive") == true
        or getElementData(client, "spawnScreen:waiting") == true then return end
    if type(loss) ~= "number" or loss ~= loss or loss <= 0 or loss == math.huge
        or type(weapon) ~= "number" or weapon % 1 ~= 0
        or not ((weapon >= 0 and weapon <= 46) or weapon == 49 or weapon == 51)
        or type(bodypart) ~= "number" or bodypart % 1 ~= 0 or bodypart < 3 or bodypart > 8 then return end
    if isElement(attacker) then
        local kind = getElementType(attacker)
        if kind ~= "player" and kind ~= "ped" and kind ~= "vehicle" then return end
        if getElementDimension(attacker) ~= getElementDimension(client)
            or getElementInterior(attacker) ~= getElementInterior(client) then return end
    else
        attacker = nil
    end
    local health = getElementHealth(client) - loss
    local shop=getResourceFromName("pirate-perks")
    if shop and getResourceState(shop)=="running" and exports["pirate-perks"]:isKratomProtected(client) then
        exports["pirate-perks"]:drainKratomReserve(client,loss)
        return
    end
    if health <= 0 then killPed(client, attacker, weapon, bodypart)
    else setElementHealth(client, health) end
end)

-- CLIENTS CANNOT CHOOSE THEIR OWN DURABILITY
addEventHandler("onElementDataChange", root, function(key)
    if key == "booty:armorTier" and client then
        setElementData(source, key, equipped[source] or false)
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do clearArmor(player) end
end)
addEventHandler("onResourceStop", resourceRoot, function()
    for player in pairs(equipped) do clearArmor(player) end
end)
