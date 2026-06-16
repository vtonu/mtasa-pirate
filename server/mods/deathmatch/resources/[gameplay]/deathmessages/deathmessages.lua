addEventHandler("onPlayerWasted", root,
	function (ammo, killer, weapon, bodypart)
		local r, g, b = getColorFromString(string.upper(get("color")))
		local message
		if killer then
			if killer ~= source then
				local killerType = getElementType(killer)
				if killerType == "player" then
					message = getPlayerName(killer).." killed "..getPlayerName(source).."."
				elseif killerType == "vehicle" then
					message = getPlayerName(getVehicleController(killer)).." killed "..getPlayerName(source).."."
				end
			else
				message = getPlayerName(source).." committed suicide."
			end
		end
		if not message then
			message = getPlayerName(source).." died."
		end
		outputChatBox(message, root, r, g, b, true)
	end
)
