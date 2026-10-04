local WAIT_LOAD_INTERVAL = 100 --ms

function isSafeEditorDeleteTarget(element)
    if not isElement(element) or not isElement(mapContainer) then return false end
    local elementType = getElementType(element)
    if element == mapContainer or elementType == "root" or elementType == "resource"
        or elementType == "map" or elementType == "mapContainer" or elementType == "player" then
        return false
    end
    local parent = getElementParent(element)
    while parent and parent ~= mapContainer do
        parent = getElementParent(parent)
    end
    if parent ~= mapContainer or getElementData(element, "edf:rep", false) then return false end

    local function hasOtherMapItems(base)
        for _, child in ipairs(getElementChildren(base)) do
            local representation = getElementData(child, "edf:rep", false)
            local lod = getElementType(base) == "object" and getLowLODElement(base) == child
            if not representation and not lod then return true end
            if hasOtherMapItems(child) then return true end
        end
        return false
    end
    return not hasOtherMapItems(element)
end

function makeElementStatic(element)
	if getElementType(element) == "vehicle" then
		triggerClientEvent(root, "doSetVehicleStatic", element)
	elseif getElementType(element) == "ped" then
		triggerClientEvent(root, "doSetPedStatic", element)
	else
		for i, child in ipairs(getElementChildren(element)) do
			makeElementStatic(child)
		end
	end
end

function setupNewElement(element, creatorResource, creatorClient, attachLater,shortcut,selectionSubmode,lockSelection)
	selectionSubmode = selectionSubmode or 1
	setElementParent(element, mapContainer)
	setElementDimension ( element, getWorkingDimension() )
	makeElementStatic( element )
	assignID ( element )
	triggerEvent ( "onElementCreate_undoredo", element )
	if attachLater and creatorClient then
		setTimer(triggerClientEvent, WAIT_LOAD_INTERVAL, 1, creatorClient, "doSelectElement", element, selectionSubmode, shortcut )
	end
	justCreated[element] = true --mark it so undoredo ignores first placement

	triggerEvent("onElementCreate", element)
	triggerClientEvent(root, "onClientElementCreate", element, creatorClient, lockSelection)
end

addEventHandler ( "doCreateElement", root,
	function ( elementType, resourceName, parameters, attachLater, shortcut )
		if client and not isPlayerAllowedToDoEditorAction(client,"createElement") then
			editor_gui.outputMessage ("You don't have permissions to create a new element!", client,255,0,0)
			return
		end

		parameters = parameters or {}
		local lockSelection
		if elementType == "object" then
			for _, field in ipairs({"collisions", "frozen", "doublesided", "breakable"}) do
				if parameters[field] == nil then parameters[field] = "true" end
			end
			lockSelection = parameters._editorSelectionLocked ~= "false" and parameters._editorSelectionLocked ~= false
		elseif elementType == "vehicle" then
			local defaults = {color1 = "#000000FF", color2 = "#000000FF", color3 = "#000000FF", color4 = "#000000FF",
				health = 1000, alpha = 255, frozen = "true", collisions = "false", locked = "false", sirens = "false", paintjob = "3"}
			for field, value in pairs(defaults) do
				if parameters[field] == nil then parameters[field] = value end
			end
			lockSelection = parameters._editorSelectionLocked ~= "false" and parameters._editorSelectionLocked ~= false
		end
		parameters._editorSelectionLocked = nil

		local creatorResource = getResourceFromName( resourceName )
		local edfElement = edf.edfCreateElement (
			elementType,
			client,
			creatorResource,
			parameters,
			true --editor mode
		)

		if edfElement then
			outputConsole ( "Created '"..elementType..":"..tostring(edfElement).."' from '"..resourceName.."'" )
			setupNewElement(edfElement, creatorResource, client, attachLater, shortcut, nil, lockSelection)
		else
			outputDebugString ( "Failed to create '"..elementType.."' from '"..resourceName.."'" )
		end
	end
)

addEventHandler ( "doCloneElement", root,
	function (attachMode, creator, rotationData)
		if client and not isPlayerAllowedToDoEditorAction(client,"createElement") then
			editor_gui.outputMessage ("You don't have permissions to clone an element!", client,255,0,0)
			return
		end

		if creator then
			edf.edfSetCreatorResource(source,creator)
		end
		local clone = edf.edfCloneElement(source,true)

		if clone then
			outputConsole ( "Cloned '"..getElementType(source).."'." )

			if rotationData then
				edf.edfSetElementRotation(clone, rotationData[1], rotationData[2], rotationData[3])
			end

			setupNewElement(clone, creator or edf.edfGetCreatorResource(source), client, true, false, attachMode)
			setLockedElement(source, nil)
		else
			outputDebugString ( "Failed to clone '"..getElementType(source).."'" )
		end
	end
)

addEventHandler ( "doDestroyElement", root,
	function (forced)
        if not isSafeEditorDeleteTarget(source) then
            if client then editor_gui.outputMessage("Delete blocked: select one map item without other map items inside it.", client, 255, 0, 0) end
            return
        end
		if client and not isPlayerAllowedToDoEditorAction(client,"deleteElement") then
			editor_gui.outputMessage ("You don't have permissions to delete an element!", client,255,0,0)
			return
		elseif client and client ~= edf.edfGetCreatorClient(source) and not isPlayerAllowedToDoEditorAction(client,"deleteOtherElement") then
			editor_gui.outputMessage ("You don't have permissions to delete someone else's element!", client,255,0,0)
			return
		end

		local locked = getLockedElement(client)
		if forced or locked == source then
			outputConsole ( "Deleted '"..getElementType(source).."'." )

			if locked then
				setLockedElement(client, nil)
			end

			triggerEvent("onElementDestroy", source)
			triggerClientEvent(root, "onClientElementDestroyed", source)

			triggerEvent ( "onElementDestroy_undoredo", source )
		end
	end
)
