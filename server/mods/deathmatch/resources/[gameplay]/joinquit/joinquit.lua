local resourceName = getResourceName(getThisResource())
local settingPrefix = string.format("*%s.", resourceName)

local showColorCodes = get("showColorCodes") == "true" 	-- Shows player"s names colorcoded if set to true, and if set to false it doesn"t
local defaultColor = {127, 255, 212} -- MINT MESSAGES
local fallbackHexCode = "#7FFFD4" -- MINT FALLBACK
local nickChangeDelay = get("nickChangeDelay")

nickChangeTime = {}

function reloadSettings(settingName)
	-- Setting change affects this resource
	if (string.find(settingName, settingPrefix, 1, true)) then
		showColorCodes = get("showColorCodes") == "true"
		defaultColor = {127, 255, 212}
		nickChangeDelay = get("nickChangeDelay")
	end
end
addEventHandler("onSettingChange", root, reloadSettings)

-- This function converts RGB colors to colorcodes like #ffffff
function RGBToHex(red, green, blue)
	-- Make sure RGB values passed to this function are correct
	if (not red or not green or not blue or (red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255)) then
		return nil
	end

	return string.format("#%.2X%.2X%.2X", red, green, blue)
end

function getDefaultColor()
	local hexColor = RGBToHex(defaultColor[1], defaultColor[2], defaultColor[3])
	if (not hexColor) then
		return fallbackHexCode
	end

	return hexColor
end

function getHexFriendlyNick(player, nick)
	return RGBToHex(getPlayerNametagColor(player))..nick
end

function joinMessage()
	if (showColorCodes) then
		outputChatBox(getDefaultColor().."* "..getHexFriendlyNick(source, getPlayerName(source))..getDefaultColor().." has joined the game", root, 127, 255, 212, true)
	else
		outputChatBox("* "..getPlayerName(source).." has joined the game", root, 127, 255, 212)
	end
end
addEventHandler("onPlayerJoin", root, joinMessage)

function nickChangeMessage(oldNick, newNick)

	if wasEventCancelled() then return end

	if isPlayerMuted(source) then
		cancelEvent()
		outputChatBox("You cannot change your nickname whilst muted!", source, 238, 20, 38)
		return
	end

	if nickChangeTime[source] and nickChangeTime[source] + tonumber(nickChangeDelay) > getTickCount() then
		cancelEvent()
		outputChatBox("You can only change your name once every "..(tonumber(nickChangeDelay)/1000).." seconds", source, 238, 20, 38)
		return false
	else
		nickChangeTime[source] = getTickCount()
	end

	if wasEventCancelled() then return end

	if (showColorCodes) then
		outputChatBox(getDefaultColor().."* "..getHexFriendlyNick(source, oldNick)..getDefaultColor().." is now known as "..getHexFriendlyNick(source, newNick), root, 127, 255, 212, true)
	else
		outputChatBox("* "..oldNick.." is now known as "..newNick, root, 127, 255, 212)
	end
end
addEventHandler("onPlayerChangeNick", root, nickChangeMessage)

function leftMessage(quitType, reason)

    if nickChangeTime[source] then
        nickChangeTime[source] = nil
    end

	if (showColorCodes) then
		outputChatBox(getDefaultColor().."* "..getHexFriendlyNick(source, getPlayerName(source))..getDefaultColor().." has left the game ["..quitType.."]", root, 127, 255, 212, true)
	else
		outputChatBox("* "..getPlayerName(source).." has left the game ["..quitType.."]", root, 127, 255, 212)
	end
end
addEventHandler("onPlayerQuit", root, leftMessage)
