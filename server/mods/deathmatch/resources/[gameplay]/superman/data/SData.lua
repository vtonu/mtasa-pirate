local supermanReceivers = {}

local function tableToElementsArray(tableWithElements)
	local arrayTable = {}
	local elementID = 0

	for elementReference, _ in pairs(tableWithElements) do
		local validElement = isElement(elementReference)

		if (validElement) then
			local newElementID = (elementID + 1)

			arrayTable[elementID] = elementReference
			elementID = newElementID
		end
	end

	return arrayTable
end

local function canElementDataBeChanged(clientElement, sourceElement, dataKey, newValue)
	local matchingPlayer = (clientElement == sourceElement)

	if (not matchingPlayer) then
		return false
	end

	local supermanDataKey = SUPERMAN_ALLOWED_DATA_KEYS[dataKey]
    if supermanDataKey and newValue==true and not canUseSuperman(clientElement) then return false end

	if (not supermanDataKey) then
		return true
	end

	local newValueDataType = type(newValue)
	local newValueBool = (newValueDataType == "boolean")

	return newValueBool
end

local function onServerSupermanSetData(dataKey, dataValue)
    if not client or source~=client or (dataValue==true and not canUseSuperman(client)) then return false end
	if (not client) then
		return false
	end

	setSupermanData(client, dataKey, dataValue)
end
if (not SUPERMAN_USE_ELEMENT_DATA) then
	addEvent("onServerSupermanSetData", true)
	addEventHandler("onServerSupermanSetData", root, onServerSupermanSetData)
end

local function onElementDataChangeSuperman(dataKey, oldValue, newValue)
	if (not client) then
		return false
	end

	local allowElementDataChange = canElementDataBeChanged(client, source, dataKey, newValue)

	if (not allowElementDataChange) then
		local removeChangedData = (oldValue == nil)

		if (removeChangedData) then
			removeElementData(source, dataKey)
		else
			setElementData(source, dataKey, oldValue)
		end
	end
end
if (SUPERMAN_USE_ELEMENT_DATA) then addEventHandler("onElementDataChange", root, onElementDataChangeSuperman) end

local function onPlayerResourceStartSyncSuperman(startedResource)
	local matchingResource = (startedResource == resource)

	if (not matchingResource) then
		return false
	end

	local supermansData = getSupermansData()

	triggerClientEvent(source, "onClientSupermanSync", source, supermansData)
	supermanReceivers[source] = true
end
if (not SUPERMAN_USE_ELEMENT_DATA) then addEventHandler("onPlayerResourceStart", root, onPlayerResourceStartSyncSuperman) end

local function onResourceStopClearSupermanElementData()
	local playersTable = getElementsByType("player")

	for playerID = 1, #playersTable do
		local playerElement = playersTable[playerID]

		for dataKey, _ in pairs(SUPERMAN_ALLOWED_DATA_KEYS) do
			removeElementData(playerElement, dataKey)
		end
	end
end
if (SUPERMAN_USE_ELEMENT_DATA) then addEventHandler("onResourceStop", resourceRoot, onResourceStopClearSupermanElementData) end

local function onPlayerQuitClearSupermanReceiver()
	supermanReceivers[source] = nil
end
if (not SUPERMAN_USE_ELEMENT_DATA) then addEventHandler("onPlayerQuit", root, onPlayerQuitClearSupermanReceiver) end

function getSupermanReceivers()
	local supermanListeners = tableToElementsArray(supermanReceivers)

	return supermanListeners
end
-- SERVER OWNS ADMIN ACCESS, INCLUDING LOGIN AND ACL CHANGES
local function syncSupermanAccess(player)
    if not isElement(player) or getElementType(player)~="player" then return end
    local allowed=canUseSuperman(player)
    if getElementData(player,"superman:allowed")~=allowed then setElementData(player,"superman:allowed",allowed) end
    if not allowed then
        setSupermanData(player,SUPERMAN_FLY_DATA_KEY,false)
        setSupermanData(player,SUPERMAN_TAKE_OFF_DATA_KEY,false)
    end
end
addEventHandler("onElementDataChange",root,function(key)
    if client and key=="superman:allowed" then syncSupermanAccess(source) end
end)
addEventHandler("onPlayerLogin",root,function() syncSupermanAccess(source) end)
addEventHandler("onPlayerLogout",root,function() setTimer(syncSupermanAccess,50,1,source) end)
addEventHandler("onPlayerJoin",root,function() syncSupermanAccess(source) end)
addEventHandler("onResourceStart",resourceRoot,function()
    for _,player in ipairs(getElementsByType("player")) do syncSupermanAccess(player) end
end)
setTimer(function()
    for _,player in ipairs(getElementsByType("player")) do syncSupermanAccess(player) end
end,2000,0)
