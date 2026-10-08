-- ==========================================
-- PLAY MODE & RESOURCE MANAGEMENT
-- ==========================================
local function onResourceStartPlay()

    -- INITIALIZE PLAY MODE
    outputDebugString("PLAY MODE STARTED")
    math.randomseed(os.time())
    exports["pirate-world"]:initializeWorld(playWorldSettings, playSafeZones, vehicleSpawns)
    createPlayPickups()

    -- SPAWN EXISTING PLAYERS
    local players = getElementsByType("player")

    for i = 1, #players do
        playSpawnPlayer(players[i])
    end

    -- REGISTER EVENTS
    addEventHandler("onPlayerJoin", root, onPlayerJoin)
    addEventHandler("onPlayerWasted", root, onPlayerWasted)
    addEventHandler("onPlayerQuit", root, onPlayerQuit)
    addEvent("playRespawnRequest", true)
    addEventHandler("playRespawnRequest", resourceRoot, onPlayerRespawnRequest)
end
addEventHandler("onResourceStart", resourceRoot, onResourceStartPlay)

addEventHandler("onResourceStart", root, function(startedResource)
    if getResourceName(startedResource) == "pirate-world" and getResourceState(getThisResource()) == "running" then
        exports["pirate-world"]:initializeWorld(playWorldSettings, playSafeZones, vehicleSpawns)
    end
end)
