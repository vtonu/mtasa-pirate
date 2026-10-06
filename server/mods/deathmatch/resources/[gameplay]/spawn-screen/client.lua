-- ==========================================
-- SPAWN SCREEN
-- ==========================================
local screenW, screenH = guiGetScreenSize()
local promptColor = tocolor(127, 255, 212)
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
        dxDrawText("PRESS SPACE TO SPAWN", 0, screenH - 100, screenW, screenH,
            promptColor, 2, "default-bold", "center", "top")
    end
end

local function requestSpawn()
    if not view or requested or isChatBoxInputActive() or isConsoleActive() or isMTAWindowActive() then
        return
    end

    requested = true
    triggerServerEvent("spawnScreenRequest", resourceRoot)
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
addEventHandler("spawnScreenShow", resourceRoot, function(x, y, z)
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
addEventHandler("spawnScreenHide", resourceRoot, hideScreen)
addEventHandler("onClientResourceStop", resourceRoot, hideScreen)
addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("spawnScreenClientReady", resourceRoot)
end)
