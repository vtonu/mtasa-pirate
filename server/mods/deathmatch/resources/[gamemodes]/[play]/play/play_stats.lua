-- ==========================================
-- PLAY STATS
-- ==========================================
local ZOMBIE_KILL_REWARDS = {
    [0] = 75, -- KNIFE
    [1] = 50, -- CHAINSAW
    [2] = 20, -- UNARMED RUNNER
    [3] = 35 -- BASEBALL BAT
}
local rewardedZombies = setmetatable({}, {__mode = "k"})

local STAT_DEFAULTS = {
    kills = 0,
    deaths = 0,
    pvpKills = 0,
    pvpDeaths = 0,
    zombieKills = 0,
    zombieDeaths = 0,
    moneyEarned = 0,
    vehiclesDestroyed = 0,
    missionCompletions = 0,
    locoPoints = 0
}

local function getStatKey(statName)
    return "play.stats." .. statName
end

function initPlayerStats(playerElement)
    if not isElement(playerElement) then
        return false
    end

    for statName, defaultValue in pairs(STAT_DEFAULTS) do
        local key = getStatKey(statName)

        if getElementData(playerElement, key) == false then
            setElementData(playerElement, key, defaultValue)
        end
    end

    return true
end

function getPlayerPlayStat(playerElement, statName)
    if not isElement(playerElement) or not STAT_DEFAULTS[statName] then
        return false
    end

    return tonumber(getElementData(playerElement, getStatKey(statName))) or STAT_DEFAULTS[statName]
end

function addPlayerPlayStat(playerElement, statName, amount)
    if not isElement(playerElement) or not STAT_DEFAULTS[statName] then
        return false
    end

    amount = tonumber(amount) or 1

    local newValue = getPlayerPlayStat(playerElement, statName) + amount
    setElementData(playerElement, getStatKey(statName), newValue)

    if statName == "locoPoints" then
        setElementData(playerElement, "locoPoints", newValue)
    end

    return newValue
end

function addPlayerMoneyEarned(playerElement, amount)
    amount = tonumber(amount) or 0

    if amount <= 0 then
        return false
    end

    givePlayerMoney(playerElement, amount)
    addPlayerPlayStat(playerElement, "moneyEarned", amount)

    return true
end

local function getKillPlayer(killerElement)
    if not isElement(killerElement) then return nil end
    if getElementType(killerElement) == "vehicle" then
        killerElement = getVehicleOccupant(killerElement, 0)
    end
    if isElement(killerElement) and getElementType(killerElement) == "player" then
        return killerElement
    end
end

local function isZombie(element)
    local zombies = getResourceFromName("new-zombies-zday")
    return isElement(element) and getElementType(element) == "ped"
        and zombies and getElementData(element, "zday.variant") ~= false
        and getElementParent(element) == getResourceDynamicElementRoot(zombies)
end

function onPlayerStatsWasted(killerElement)
    if isElement(source) then
        addPlayerPlayStat(source, "deaths", 1)
        if isZombie(killerElement) then
            addPlayerPlayStat(source, "zombieDeaths", 1)
        end
    end

    local killer = getKillPlayer(killerElement)
    if killer and killer ~= source then
        addPlayerPlayStat(killer, "kills", 1)
        addPlayerPlayStat(killer, "pvpKills", 1)
        addPlayerPlayStat(source, "pvpDeaths", 1)
    end
end

addEventHandler("onPedWasted", root, function(totalAmmo, killerElement)
    if not isZombie(source) then return end
    if rewardedZombies[source] then return end
    local killer = getKillPlayer(killerElement)
    if killer then
        rewardedZombies[source] = true
        addPlayerPlayStat(killer, "kills", 1)
        addPlayerPlayStat(killer, "zombieKills", 1)
        local reward = ZOMBIE_KILL_REWARDS[tonumber(getElementData(source, "zday.variant"))]
        if reward then addPlayerMoneyEarned(killer, reward) end
    end
end)

