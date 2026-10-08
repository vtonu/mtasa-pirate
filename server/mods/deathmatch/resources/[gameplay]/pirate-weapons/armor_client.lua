-- APPLY TIER DURABILITY ONLY TO DAMAGE THAT BODY ARMOUR CAN ABSORB
local drainRates = {soft = 1, reinforced = 0.5, hard = 0.25}
local depleted = false

setTimer(function()
    if not depleted and drainRates[getElementData(localPlayer, "booty:armorTier")]
        and getPedArmor(localPlayer) <= 0 then
        depleted = true
        triggerServerEvent("bootyArmorDepleted", resourceRoot)
    end
end, 250, 0)

addEventHandler("onClientElementDataChange", localPlayer, function(key)
    if key == "booty:armorTier" then depleted = false end
end)

addEventHandler("onClientPlayerDamage", root, function(attacker, weapon, bodypart, loss)
    if source ~= localPlayer or wasEventCancelled() or depleted or isPedDead(localPlayer)
        or getElementData(localPlayer, "freeroam.passive") == true
        or getElementData(localPlayer, "spawnScreen:waiting") == true then return end
    local drain = drainRates[getElementData(localPlayer, "booty:armorTier")]
    if not drain or drain == 1 or type(loss) ~= "number" or loss ~= loss or loss <= 0 or loss == math.huge then return end
    if type(weapon) ~= "number" or not ((weapon >= 0 and weapon <= 46) or weapon == 49 or weapon == 51) then return end
    if bodypart == 9 then return end
    local armor = getPedArmor(localPlayer)
    if armor <= 0 then return end
    -- KEEP THE OVERFLOW AS HEALTH DAMAGE ON THE SAME HIT
    local absorbed = math.min(loss, armor / drain)
    local remaining = math.max(0, armor - absorbed * drain)
    cancelEvent()
    setPedArmor(localPlayer, remaining)
    local healthLoss = loss - absorbed
    if healthLoss > 0 then
        triggerServerEvent("bootyArmorOverflow", resourceRoot, healthLoss, attacker, weapon, bodypart)
    end
    if remaining <= 0 then
        depleted = true
        triggerServerEvent("bootyArmorDepleted", resourceRoot)
    end
end, true, "low-100")
