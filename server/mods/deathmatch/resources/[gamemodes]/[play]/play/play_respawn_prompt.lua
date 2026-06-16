-- ==========================================
-- RESPAWN PROMPT
-- ==========================================
local screenW, screenH = guiGetScreenSize()
local promptVisible = false
local promptColor = tocolor(127, 255, 212)
local promptFont = "default-bold"
local promptScale = 2
local promptText = "PRESS SPACE TO RESPAWN"

local function drawRespawnPrompt()
    dxDrawText(promptText, 0, screenH - 100, screenW, screenH, promptColor, promptScale, promptFont,
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
