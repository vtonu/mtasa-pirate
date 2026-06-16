-- ==========================================
-- PLAY MODE & RESOURCE MANAGEMENT
-- ==========================================
local function onResourceStartPlay()

    -- INITIALIZE PLAY MODE
    outputDebugString("PLAY MODE STARTED")
    math.randomseed(os.time())
    initPlayWorld()
    createVehicles()
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
    addEventHandler("onVehicleEnter", resourceRoot, onVehicleEnter)
    addEventHandler("onVehicleExit", resourceRoot, onVehicleExit)
    addEventHandler("onVehicleExplode", root, onVehicleExplode)
    addEventHandler("onElementDestroy", resourceRoot, onVehicleElementDestroy)
end
addEventHandler("onResourceStart", resourceRoot, onResourceStartPlay)
