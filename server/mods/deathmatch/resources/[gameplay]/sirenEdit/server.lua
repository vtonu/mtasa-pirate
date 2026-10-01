-- ADMIN ACCESS
local function canEditSirens(player)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	local account = getPlayerAccount(player)
	local group = aclGetGroup("Admin")
	return account and not isGuestAccount(account) and group
		and isObjectInACLGroup("user." .. getAccountName(account), group) or false
end

local function canEditVehicle(player, vehicle)
	return canEditSirens(player) and isElement(vehicle) and getElementType(vehicle) == "vehicle"
		and getPedOccupiedVehicle(player) == vehicle
end

addEvent("sirens_requestEditor", true)
addEventHandler("sirens_requestEditor", resourceRoot, function()
	if source ~= resourceRoot or not canEditSirens(client) then return end
	triggerClientEvent(client, "sirens_openEditor", resourceRoot)
end)

function siren_sync ( sirenTable )
	local veh = source
	if not canEditVehicle(client, veh) or type(sirenTable) ~= "table" then return end
	for k,v in ipairs(sirenTable) do
		if k > 8 or type(v) ~= "table" then return end
	end
	for k,v in ipairs( sirenTable ) do
		setVehicleSirens(veh, k, v.x ~= nil and v.x or 0, v.y ~= nil and v.y or 0, v.z ~= nil and v.z or 0, v.Red ~= nil and v.Red or 0, v.Green ~= nil and v.Green or 0, v.Blue ~= nil and v.Blue or 255, v.Alpha ~= nil and v.Alpha or 255, v.Min_Alpha ~= nil and v.Min_Alpha or 128)
	end
end
addEvent("sirens_sync", true)
addEventHandler("sirens_sync", root, siren_sync)

function siren_sync2 ( sirenTable )
	local veh = source
	if not canEditVehicle(client, veh) or type(sirenTable) ~= "table"
		or type(sirenTable.Flags) ~= "table" then return end
	addVehicleSirens ( veh, sirenTable.SirenCount ~= nil and sirenTable.SirenCount or 1, sirenTable.SirenType ~= nil and sirenTable.SirenType or 2, sirenTable.Flags["360"] ~= nil and sirenTable.Flags["360"] or false, sirenTable.Flags.DoLOSCheck ~= nil and sirenTable.Flags.DoLOSCheck or false, sirenTable.Flags.UseRandomiser ~= nil and sirenTable.Flags.UseRandomiser or false, sirenTable.Flags.Silent ~= nil and sirenTable.Flags.Silent or false )
end
addEvent("sirens_sync2", true)
addEventHandler("sirens_sync2", root, siren_sync2)
