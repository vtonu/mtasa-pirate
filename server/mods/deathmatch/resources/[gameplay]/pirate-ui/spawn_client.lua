-- ==========================================
-- SPAWN SCREEN
-- ==========================================
local screenW, screenH = guiGetScreenSize()
local promptColor = tocolor(127, 255, 212)
local promptFont = "default-bold"
local promptScale = 2
local promptText = "PRESS 'SPACE' TO SPAWN"
local promptBottomOffset = 100

-- REFRESH CACHED STYLE WHEN THE CONFIG STARTS
local function refreshPromptStyle()
    local configResource = getResourceFromName("pirate-core")
    if not configResource or getResourceState(configResource) ~= "running" then return end
    local style = exports["pirate-core"]:getPromptStyle("spawn")
    if type(style) ~= "table" then return end
    promptColor = tocolor(unpack(style.color))
    promptFont = style.font
    promptScale = style.scale
    promptText = style.text
    promptBottomOffset = style.bottomOffset
end

addEventHandler("onClientResourceStart", root, function(startedResource)
    if startedResource == getThisResource() or getResourceName(startedResource) == "pirate-core" then
        setTimer(refreshPromptStyle, 100, 1)
    end
end)
local view = false
local requested = false
local startedAt = 0

local function updateCamera()
    if not view then
        return
    end

    local seconds = (getTickCount() - startedAt) / 1000
    local bob = math.sin(seconds * 0.65) * 0.6
    local progress = math.min(seconds / 4, 1)
    local drop = 2 * progress * progress * (3 - 2 * progress)
    setCameraMatrix(view.x - 45, view.y - 25, view.z + 28 + bob - drop, view.x - 5, view.y + 5, view.z - drop)
end

addEventHandler("onClientKey", root, function(key, pressed)
    if pressed and (view or getElementData(localPlayer, "spawnScreen:waiting") == true) and key ~= "space" then
        cancelEvent()
    end
end, true, "high+10")
addEventHandler("onClientPlayerDamage", localPlayer, function()
    if view or getElementData(localPlayer, "spawnScreen:waiting") == true then cancelEvent() end
end)

local function drawPrompt()
    if view then
        dxDrawText(promptText, 0, screenH - promptBottomOffset, screenW, screenH,
            promptColor, promptScale, promptFont, "center", "top")
    end
end

local function requestSpawn()
    if not view or requested or isChatBoxInputActive() or isConsoleActive() or isMTAWindowActive() then
        return
    end

    requested = true
    sendCoreUIEvent("spawnScreenRequest")
end

local function hideScreen()
    if not view then
        return
    end

    view = false
    requested = false
    unbindKey("space", "down", requestSpawn)
    removeEventHandler("onClientPreRender", root, updateCamera)
    removeEventHandler("onClientRender", root, drawPrompt)
    setCameraTarget(localPlayer)
end

addEvent("spawnScreenShow", true)
addCoreUIEvent("spawnScreenShow", function(x, y, z)
    if view then
        return
    end

    view = {x = x, y = y, z = z}
    requested = false
    startedAt = getTickCount()
    updateCamera()
    bindKey("space", "down", requestSpawn)
    addEventHandler("onClientPreRender", root, updateCamera)
    addEventHandler("onClientRender", root, drawPrompt)
end)

addEvent("spawnScreenHide", true)
addCoreUIEvent("spawnScreenHide", hideScreen)
addEventHandler("onClientResourceStop", resourceRoot, hideScreen)
addEventHandler("onClientResourceStart", root, function(startedResource)
    if startedResource == getThisResource() or getResourceName(startedResource) == "pirate-core" then
        sendCoreUIEvent("spawnScreenClientReady")
    end
end)
addEventHandler("onClientResourceStop", root, function(stoppedResource)
    if getResourceName(stoppedResource) == "pirate-core" then hideScreen() end
end)
