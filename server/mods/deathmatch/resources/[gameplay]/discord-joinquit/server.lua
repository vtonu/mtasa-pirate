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
        content = "```text\n" .. entry.message .. "\n```",
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
    queue[#queue + 1] = { message = message, attempts = 0 }
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
end)

addEventHandler("onPlayerJoin", root, function()
    enqueue(timestamp() .. " JOIN: " .. cleanText(getPlayerName(source))
        .. " joined the game (IP: " .. cleanText(getPlayerIP(source)) .. ")")
end)

addEventHandler("onPlayerQuit", root, function(quitType)
    enqueue(timestamp() .. " QUIT: " .. cleanText(getPlayerName(source))
        .. " left the game [" .. cleanText(quitType) .. "]")
end)
