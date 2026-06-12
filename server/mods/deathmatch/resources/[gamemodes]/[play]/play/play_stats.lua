-- ==========================================
-- PLAY STATS
-- ==========================================

local STAT_DEFAULTS = {
    kills = 0,
    deaths = 0,
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

function onPlayerStatsWasted(killerElement)
    if isElement(source) then
        addPlayerPlayStat(source, "deaths", 1)
    end

    if isElement(killerElement) and getElementType(killerElement) == "player" and killerElement ~= source then
        addPlayerPlayStat(killerElement, "kills", 1)
    end
end

