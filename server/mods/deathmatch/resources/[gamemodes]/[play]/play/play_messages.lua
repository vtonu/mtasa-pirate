-- ==========================================
-- PLAY MESSAGE HELPERS
-- ==========================================
local PLAY_COLOR = {127, 255, 212} -- aquamarine
local ERROR_COLOR = {255, 0, 0} -- red
local JOIN_COLOR = {255, 105, 180} -- pink
local NOTIFICATION_COLOR = {255, 250, 80} -- yellow

local MESSAGE_DEFINITIONS = {
    configMissingPickups = {
        text = "ERROR: pickupSpawns table not found in config!",
        color = ERROR_COLOR
    },
    joinWelcome = {
        text = "Welcome to Lifestyle Gaming!",
        color = JOIN_COLOR
    },
    joinHelp = {
        text = "Press F1 to show/hide controls.",
        color = JOIN_COLOR
    },
    locoPickup = {
        text = "Head to the deck blip. Spawn a vehicle, then destroy it.",
        color = PLAY_COLOR
    },
    locoAmmoLimit = {
        text = "Molotov limit reached (1,000). Use some first.",
        color = PLAY_COLOR
    },
    locoReward = {
        color = PLAY_COLOR,
        format = function(amount)
            return "Aye aye, captain! +$" .. tostring(amount)
        end
    },
    locoCooldown = {
        text = "TIMER HAS EXPIRED. GRAB THE LOCO SKULL AGAIN.",
        color = PLAY_COLOR
    },
    locoRequired = {
        text = "TIMER HAS EXPIRED. LOCO SKULL REQUIRED TO START.",
        color = PLAY_COLOR
    },
    locoTargetSpawned = {
        text = "TARGET SPAWNED. DESTROY IT.",
        color = PLAY_COLOR
    },
    locoNewTargetSpawned = {
        text = "NEW TARGET SPAWNED. DESTROY IT!",
        color = PLAY_COLOR
    },
    captainNotification = {
        text = "[NOTIFICATION] Aye Captain, you can always come to us! xD",
        color = NOTIFICATION_COLOR
    }
}

-- ==========================================
-- NOTIFICATION SYSTEM
-- ==========================================

local playerNotificationTimers = {}
local SHIP_WELCOME = "[NOTIFICATION] Welcome aboard, Captain!"
local shipWelcomeCooldowns = {}
local SHIP_WELCOME_COOLDOWN_MS = 120000

local NOTIFICATION_MESSAGES = {"[NOTIFICATION] Aye Captain, you can always come to us!",
                               "[NOTIFICATION] The crew awaits your orders, Captain!",
                               "[NOTIFICATION] English only in chat.",
                               "[NOTIFICATION] Found a bug? Use /report to let us know.",
                               "[NOTIFICATION] Got a suggestion? Use /report to let us know.",
                               "[NOTIFICATION] Open beta: expect bugs and things to break. Share feedback with /report."}

addEventHandler("onResourceStart", resourceRoot, function()
    local entrance = createColSphere(2025.07141, 1545.09875, 10.82031, 6)
    if not entrance then return end

    addEventHandler("onColShapeHit", entrance, function(hitElement, matchingDimension)
        if not matchingDimension or getElementInterior(hitElement) ~= 0 then return end

        local players = {}
        if getElementType(hitElement) == "player" then
            players[1] = hitElement
        elseif getElementType(hitElement) == "vehicle" then
            for _, player in pairs(getVehicleOccupants(hitElement)) do
                players[#players + 1] = player
            end
        end

        local now = getTickCount()
        for _, player in ipairs(players) do
            if getElementDimension(player) == 0 and getElementInterior(player) == 0
                and not isPedDead(player)
                and (not shipWelcomeCooldowns[player] or now >= shipWelcomeCooldowns[player]) then
                shipWelcomeCooldowns[player] = now + SHIP_WELCOME_COOLDOWN_MS
                outputChatBox(SHIP_WELCOME, player, NOTIFICATION_COLOR[1], NOTIFICATION_COLOR[2], NOTIFICATION_COLOR[3])
            end
        end
    end)
end)

addEventHandler("onPlayerQuit", root, function()
    shipWelcomeCooldowns[source] = nil
end)

function startPlayerNotifications(playerElement)
    if not playerElement then
        return
    end

    -- Kill any existing timer for this player
    if playerNotificationTimers[playerElement] and isTimer(playerNotificationTimers[playerElement]) then
        killTimer(playerNotificationTimers[playerElement])
    end

    -- First notification after 10 seconds
    playerNotificationTimers[playerElement] = setTimer(function()
        if isElement(playerElement) then
            local randomMsg = NOTIFICATION_MESSAGES[math.random(#NOTIFICATION_MESSAGES)]
            outputChatBox(randomMsg, playerElement, NOTIFICATION_COLOR[1], NOTIFICATION_COLOR[2], NOTIFICATION_COLOR[3])

            -- Set up repeating notification every 2 minutes (120000 ms)
            playerNotificationTimers[playerElement] = setTimer(function()
                if isElement(playerElement) then
                    local randomMsg = NOTIFICATION_MESSAGES[math.random(#NOTIFICATION_MESSAGES)]
                    outputChatBox(randomMsg, playerElement, NOTIFICATION_COLOR[1], NOTIFICATION_COLOR[2],
                        NOTIFICATION_COLOR[3])
                end
            end, 120000, 0)
        end
    end, 10000, 1)
end

function stopPlayerNotifications(playerElement)
    if playerNotificationTimers[playerElement] and isTimer(playerNotificationTimers[playerElement]) then
        killTimer(playerNotificationTimers[playerElement])
    end

    playerNotificationTimers[playerElement] = nil
end

function playMessage(playerElement, messageKey, ...)
    local message = MESSAGE_DEFINITIONS[messageKey]

    if not message then
        return false
    end

    local text = message.text

    if message.format then
        text = message.format(...)
    end

    if not text then
        return false
    end

    local color = message.color or PLAY_COLOR

    outputChatBox(text, playerElement or root, color[1], color[2], color[3])

    return true
end
