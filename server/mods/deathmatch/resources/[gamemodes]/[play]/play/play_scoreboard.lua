-- PLAY SCOREBOARD
local PERK_TEAMS = {indica = "Indica", sativa = "Sativa", hybrid = "Hybrid"}
local COLUMNS = {
    {"play.scoreboard.money", 100, "Money", 2},
    {"play.scoreboard.team", 85, "Team", 3},
    {"play.scoreboard.kd", 75, "K/D", 4},
    {"play.scoreboard.zombieKills", 85, "Z/D", 5}
}

local function setScoreboardValue(player, key, value)
    if getElementData(player, key) ~= value then
        setElementData(player, key, value)
    end
end

local function updatePlayerScoreboard(player)
    setScoreboardValue(player, "play.scoreboard.money", "$" .. getPlayerMoney(player))
    setScoreboardValue(player, "play.scoreboard.team", PERK_TEAMS[getElementData(player, "weed.perk")] or "N/A")
    local kills = getPlayerPlayStat(player, "pvpKills")
    local deaths = getPlayerPlayStat(player, "pvpDeaths")
    setScoreboardValue(player, "play.scoreboard.kd", string.format("%.2f", kills / math.max(deaths, 1)))
    setScoreboardValue(player, "play.scoreboard.zombieKills",
        getPlayerPlayStat(player, "zombieKills") .. "/" .. getPlayerPlayStat(player, "zombieDeaths"))
end

local function registerScoreboardColumns()
    local scoreboard = getResourceFromName("scoreboard")
    if not scoreboard or getResourceState(scoreboard) ~= "running" then return end
    for _, column in ipairs(COLUMNS) do
        exports.scoreboard:scoreboardAddColumn(column[1], root, column[2], column[3], column[4])
    end
end

addEventHandler("onResourceStart", root, function(startedResource)
    if startedResource == getThisResource() then
        registerScoreboardColumns()
        for _, player in ipairs(getElementsByType("player")) do
            updatePlayerScoreboard(player)
        end
    elseif getResourceName(startedResource) == "scoreboard" then
        registerScoreboardColumns()
    end
end)

addEventHandler("onPlayerJoin", root, function()
    updatePlayerScoreboard(source)
end)

addEventHandler("onElementDataChange", root, function(key)
    if getElementType(source) ~= "player" then return end
    if key == "weed.perk" or key == "play.stats.pvpKills" or key == "play.stats.pvpDeaths"
        or key == "play.stats.zombieKills" or key == "play.stats.zombieDeaths" then
        updatePlayerScoreboard(source)
    end
end)

setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        updatePlayerScoreboard(player)
    end
end, 1000, 0)
