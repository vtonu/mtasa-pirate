local function setPlayerColor(player)
	player = player or source
	setPlayerNametagColor(player, 255, 255, 255)
end
addEventHandler("onPlayerJoin", root, setPlayerColor)

local function setAllPlayerColors()
	for _, player in ipairs(getElementsByType("player")) do
		setPlayerColor(player)
	end
end
-- mapmanager resets player colors to white when the map ends
addEventHandler("onGamemodeMapStart", root, setAllPlayerColors)

local function handleResourceStartStop(res)
	if res == resource then
		setAllPlayerColors()
	end
end
addEventHandler("onResourceStart", root, handleResourceStartStop)
addEventHandler("onResourceStop", root, handleResourceStartStop)


