-- PLAY SCOREBOARD
local PERK_TEAMS = {indica = "Indica", sativa = "Sativa", hybrid = "Hybrid"}
local COLUMNS = {
    {"play.scoreboard.money", 100, "Money", 2},
    {"play.scoreboard.team", 85, "Team", 3},
    {"play.scoreboard.kd", 75, "K/D", 4}
}

local function setScoreboardValue(player, key, value)
    if getElementData(player, key) ~= value then
        setElementData(player, key, value)
    end
end

local function updatePlayerScoreboard(player)
    setScoreboardValue(player, "play.scoreboard.money", "$" .. getPlayerMoney(player))
    setScoreboardValue(player, "play.scoreboard.team", PERK_TEAMS[getElementData(player, "weed.perk")] or "N/A")
    local kills = getPlayerPlayStat(player, "kills")
    local deaths = getPlayerPlayStat(player, "deaths")
    setScoreboardValue(player, "play.scoreboard.kd", kills .. "/" .. deaths)
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
    if key == "weed.perk" or key == "play.stats.kills" or key == "play.stats.deaths" then
        updatePlayerScoreboard(source)
    end
end)

setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        updatePlayerScoreboard(player)
    end
end, 1000, 0)
