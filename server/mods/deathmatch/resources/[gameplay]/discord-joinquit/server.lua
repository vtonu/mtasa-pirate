local queue = {}
local busy = false
local ready = false
local sendNext

local function logError(message)
    outputDebugString("[discord-joinquit] " .. message, 1)
end

local function cleanText(value)
    return tostring(value):gsub("#%x%x%x%x%x%x", ""):gsub("[%c`]", " ")
end

local function timestamp()
    local time = getRealTime()
    return string.format("[%02d:%02d:%02d]", time.hour, time.minute, time.second)
end

local function resumeQueue(delay)
    setTimer(function()
        busy = false
        sendNext()
    end, math.max(1000, delay), 1)
end

sendNext = function()
    if busy or not ready or #queue == 0 then
        return
    end

    busy = true
    local entry = queue[1]
    local payload = toJSON({
        content = entry.message,
        allowed_mentions = { parse = {} }
    }, true)
    local request = fetchRemote(DISCORD_WEBHOOK_URL, {
        method = "POST",
        headers = { ["Content-Type"] = "application/json" },
        postData = payload:sub(2, -2),
        queueName = "discord-joinquit",
        connectionAttempts = 1,
        connectTimeout = 10000
    }, function(data, info)
        local status = info.statusCode
        local delay = 1000
        if status == 429 then
            local response = fromJSON(data)
            delay = math.ceil((type(response) == "table" and tonumber(response.retry_after) or 5) * 1000)
        elseif info.success and status >= 200 and status < 300 then
            table.remove(queue, 1)
            for name, value in pairs(info.headers or {}) do
                if name:lower() == "x-ratelimit-remaining" and tonumber(value) == 0 then
                    for resetName, resetValue in pairs(info.headers) do
                        if resetName:lower() == "x-ratelimit-reset-after" then
                            delay = math.ceil((tonumber(resetValue) or 1) * 1000) + 250
                        end
                    end
                end
            end
        else
            entry.attempts = entry.attempts + 1
            logError("send failed (status " .. tostring(status) .. ")")
            if status == 401 or status == 403 or status == 404 then
                ready = false
                queue = {}
                logError("check the webhook url, then restart this resource")
            elseif entry.attempts >= 3 then
                table.remove(queue, 1)
                logError("dropped a log after 3 failed sends")
            end
            delay = 5000
        end
        resumeQueue(delay)
    end)

    if not request then
        ready = false
        busy = false
        queue = {}
        logError("request failed to start; check fetchRemote permission")
    end
end

local function enqueue(message)
    if not ready then
        return
    end
    if #queue >= 1000 then
        logError("log queue full; dropped a new log")
        return
    end
    queue[#queue + 1] = { message = utf8.sub(message, 1, 1900), attempts = 0 }
    sendNext()
end

addEventHandler("onResourceStart", resourceRoot, function()
    if type(DISCORD_WEBHOOK_URL) ~= "string"
        or not DISCORD_WEBHOOK_URL:match("^https://discord%.com/api/webhooks/%d+/[%w_%-]+$") then
        logError("paste a discord webhook url into config.lua, then restart this resource")
        return
    end
    if not hasObjectPermissionTo(getThisResource(), "function.fetchRemote", false) then
        logError("run: aclrequest allow discord-joinquit function.fetchRemote")
        return
    end
    ready = true
    for _, player in ipairs(getElementsByType("player")) do
        resendPlayerACInfo(player)
    end
end)

addEventHandler("onPlayerJoin", root, function()
    enqueue(timestamp() .. " JOIN: " .. cleanText(getPlayerName(source))
        .. " joined the game (IP: " .. cleanText(getPlayerIP(source)) .. ")")
end)

local alertTimes = {}
local alertCount = 0

setTimer(function()
    local now = getTickCount()
    for key, time in pairs(alertTimes) do
        if now - time >= 30000 then
            alertTimes[key] = nil
        end
    end
    alertCount = 0
end, 60000, 0)

local function alert(category, key, message)
    if not ready or alertCount >= 30 then
        return
    end
    local now = getTickCount()
    if alertTimes[key] and now - alertTimes[key] < 30000 then
        return
    end
    alertTimes[key] = now
    alertCount = alertCount + 1
    enqueue(timestamp() .. " " .. category .. ": " .. cleanText(message))
end

local function suspicious(player, kind, details)
    alert("SUSPICIOUS", getPlayerSerial(player) .. ":" .. kind,
        cleanText(getPlayerName(player)) .. " - " .. kind .. " (" .. details .. ")")
end

addEventHandler("onPlayerACInfo", root, function(codes)
    if type(codes) == "table" and #codes > 0 then
        suspicious(source, "anti-cheat report", "codes: " .. table.concat(codes, ", "))
    end
end)

local version = getVersion().sortable
if version >= "1.6.0-9.22459" then
    addEventHandler("onPlayerTriggerInvalidEvent", root, function(eventName, isAdded, isRemote)
        suspicious(source, "invalid event", cleanText(eventName)
            .. "; registered: " .. tostring(isAdded) .. "; remote: " .. tostring(isRemote))
    end)
end

if version >= "1.6.0-9.22313" then
    addEventHandler("onPlayerTriggerEventThreshold", root, function(eventName)
        suspicious(source, "event spam", "last event: " .. cleanText(eventName or "unknown"))
    end)
end

if version >= "1.6.0-9.22790" then
    addEventHandler("onPlayerChangesProtectedData", root, function(element, key)
        suspicious(source, "protected data change", "key: " .. cleanText(key))
    end)
end

addEventHandler("onDebugMessage", root, function(message, level, file, line)
    if level ~= 1 and level ~= 2 then
        return
    end
    if tostring(message):find("[discord-joinquit]", 1, true)
        or tostring(file):find("discord-joinquit", 1, true) then
        return
    end
    local location = file and (cleanText(file) .. ":" .. tostring(line or "?")) or "server"
    alert(level == 1 and "ERROR" or "WARNING", location .. ":" .. tostring(message),
        location .. " - " .. cleanText(message))
end)

addEventHandler("onPlayerQuit", root, function(quitType)
    enqueue(timestamp() .. " QUIT: " .. cleanText(getPlayerName(source))
        .. " left the game [" .. cleanText(quitType) .. "]")
end)
