-- ==========================================
-- RESPAWN PROMPT
-- ==========================================
local screenW, screenH = guiGetScreenSize()
local promptVisible = false
local promptColor = tocolor(127, 255, 212)
local promptFont = "default-bold"
local promptScale = 2
local promptText = "PRESS 'SPACE' TO RESPAWN"
local promptBottomOffset = 100

-- REFRESH CACHED STYLE WHEN THE CONFIG STARTS
local function refreshPromptStyle()
    local configResource = getResourceFromName("pirate-config")
    if not configResource or getResourceState(configResource) ~= "running" then return end
    local style = exports["pirate-config"]:getPromptStyle("respawn")
    if type(style) ~= "table" then return end
    promptColor = tocolor(unpack(style.color))
    promptFont = style.font
    promptScale = style.scale
    promptText = style.text
    promptBottomOffset = style.bottomOffset
end

addEventHandler("onClientResourceStart", root, function(startedResource)
    if startedResource == getThisResource() or getResourceName(startedResource) == "pirate-config" then
        setTimer(refreshPromptStyle, 100, 1)
    end
end)

-- CLOSE ON-FOOT VIEW ON EACH SPAWN
addEventHandler("onClientPlayerSpawn", localPlayer, function()
    local vehicleView = getCameraViewMode()
    setCameraViewMode(vehicleView, 1)
end)

local function drawRespawnPrompt()
    dxDrawText(promptText, 0, screenH - promptBottomOffset, screenW, screenH, promptColor, promptScale, promptFont,
        "center", "top")
end

local function requestRespawn()
    if not promptVisible then
        return
    end

    triggerServerEvent("playRespawnRequest", resourceRoot)
end

local function showRespawnPrompt()
    if promptVisible then
        return
    end

    promptVisible = true
    bindKey("space", "down", requestRespawn)
    addEventHandler("onClientRender", root, drawRespawnPrompt)
end
addEvent("playShowRespawnPrompt", true)
addEventHandler("playShowRespawnPrompt", resourceRoot, showRespawnPrompt)

local function hideRespawnPrompt()
    if not promptVisible then
        return
    end

    promptVisible = false
    unbindKey("space", "down", requestRespawn)
    removeEventHandler("onClientRender", root, drawRespawnPrompt)
end
addEvent("playHideRespawnPrompt", true)
addEventHandler("playHideRespawnPrompt", resourceRoot, hideRespawnPrompt)
addEventHandler("onClientResourceStop", resourceRoot, hideRespawnPrompt)
