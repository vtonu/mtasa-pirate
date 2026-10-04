--layout------------------------
local scrollbarThumbSize = 20 --px
local screenX,screenY = guiGetScreenSize()

local layout = {}

layout.padding = {
	top    = 25, --px
	bottom = 30, --px
	left   = 10, --px
	right  = 0, --px
}
layout.margin = {
	bottom = 5, --px
}
layout.label = {
	width = 55, --px
	height = 23, --px
	R = 255,
	G = 255,
	B = 255,
}
layout.window = {
	x = 20, --px
	y = 20, --px
	width  = math.min(1000, screenX - 40), --px
	height = math.min(screenY - 40, 650), --px
}
layout.window.y = math.min(100, math.floor((screenY - layout.window.height) / 2))
layout.button = {
	width =  80, --px
	height = 20, --px
}
layout.pulloutButton = {
	width = 27, --px
	height = 20, --px
}
layout.pullout = {
	width = 120, --px
	height = 70, --px
	items = {
		"CopyPOS",
		"Clone",
		"Delete",
	}
}
layout.line = {
	x = layout.padding.left,
	y = layout.window.height - layout.padding.bottom - 8,
	width = layout.window.width - layout.padding.left / 2,
	height = 1, --px
}
layout.pane = {
	x = 0,
	y = scrollbarThumbSize,
	width = layout.window.width - scrollbarThumbSize, --scrollbar thumb width
	height = layout.window.height - layout.button.height - scrollbarThumbSize - layout.padding.bottom + 2, --scrollbar thumb height
}
layout.control = {
	-- baseY: take the type/elementID labels and parent control into account
	baseY = 180,
	x = layout.padding.left + layout.label.width,
}
layout.control.width = layout.pane.width - layout.control.x - scrollbarThumbSize - layout.padding.right
layout.relative = false

--end padding definitions
local endPadding = {
	markerType   = 205,
	colshapeType = 205,
	weaponID = 205,
	pickupType = 205,
	selection = 205,
}

--properties window widgets------
local wndProperties
local spnProperties
local btnApply, btnCancel, btnOK
local lblType, lblTypeCaption
local edtID, lblIDCaption, tooltipID
local cntParent, lblParentCaption, tooltipParent
local lineImg

--global variables---------------
local selectedElement
local DEFAULT_PARENT_TEXT = "This element's parent for the map tree structure"
local edfResource = getResourceFromName "edf"
local editorResource = getResourceFromName "editor_main"
local propertiesYPos = layout.control.baseY  --Y position to attach the next control at, initially base pos
local projPropertiesYPos = 0
local isPropertiesOpen
local syncPropertiesCallback
local propertiesChanged
local creatingNewElement
local lastPropertiesType

local addedControls = {} -- table containing all added editing-controls
local previousValues = {} -- table containing previously applied values for all editing-controls
local caption = {} -- table linking controls to their captions

local newElementType
local newElementResource

local descriptionTimer = nil
local tooltipShowing = nil
local descriptionTooltips = {}
local createdTooltips = {}
local pulloutAction = {}
local actionButtons = {}

local function arrangePropertiesHeader(objectLayout)
	local width = layout.pane.width
	local y = objectLayout and 35 or 25
	local idX = objectLayout and 70 or 100
	guiSetPosition(lblType, 10, y, false)
	guiSetSize(lblType, objectLayout and 42 or 65, 23, false)
	guiSetPosition(lblIDCaption, objectLayout and 50 or 75, y, false)
	guiSetPosition(edtID, idX, y, false)
	guiSetSize(edtID, width * 0.35 - idX - 8, 23, false)
	guiSetPosition(lblParentCaption, width * 0.35, y, false)
	guiSetSize(lblParentCaption, 45, 23, false)
	local x = width * 0.35 + 45
	local parentWidth = objectLayout and width - x - 187 or width * 0.32 - 55
	local editWidth, clearWidth = parentWidth - 85, 23
	guiSetPosition(cntParent.GUI.editField, x, y, false)
	guiSetSize(cntParent.GUI.editField, editWidth, 23, false)
	guiSetPosition(cntParent.GUI.clearButton, x + editWidth, y, false)
	guiSetSize(cntParent.GUI.clearButton, clearWidth, 23, false)
	guiSetPosition(cntParent.GUI.launchBrowserButton, x + editWidth + clearWidth, y, false)
	guiSetSize(cntParent.GUI.launchBrowserButton, 62, 23, false)
	for index, button in ipairs(actionButtons) do
		guiSetPosition(button, 10 + (index - 1) * 90, objectLayout and 270 or 90, false)
	end
end

local function propertyPlacement(field)
	local width = layout.pane.width
	local elementType = selectedElement and getElementType(selectedElement) or newElementType
	if field == "model" then
		if elementType == "object" then
			local x = width - 177
			return {x = x + 45, y = 35, width = 122, labelX = x, labelY = 35, height = 23, editWidth = 60 / 122, buttonWidth = 62 / 122}
		end
		return {x = width * 0.72, y = 25, width = width * 0.28 - 10, labelX = width * 0.67, labelY = 25, height = 23}
	elseif field == "position" or field == "rotation" then
		local x = field == "position" and 10 or math.floor(width / 2)
		local gap = elementType == "object" and 52 or 65
		local y = elementType == "object" and 235 or 60
		return {x = x + gap, y = y, width = width / 2 - gap - 10, labelX = x, labelY = y, height = 23, horizontal = true}
	elseif elementType == "object" then
		local toggles = {collisions = 0, frozen = 1, doublesided = 2, breakable = 3, ["locked-s"] = 4}
		if toggles[field] then
			local x = math.floor(width * 0.64)
			return {x = x, y = 75 + toggles[field] * 28, width = width - x - 10, labelX = x, labelY = 75 + toggles[field] * 28, height = 26}
		end
		local left = {interior = 0, dimension = 1, alpha = 2, scale = 3}
		local right = {moveX = 0, moveY = 1, moveZ = 2, moveSpeed = 3, moveDelay = 4}
		local row = left[field] or right[field]
		if row then
			local x = left[field] and 10 or math.floor(width * 0.32)
			return {x = x + 75, y = 75 + row * 28, width = math.min(110, width * 0.32 - 95), labelX = x, labelY = 75 + row * 28, height = 23}
		end
	elseif elementType == "vehicle" then
		local color = tonumber(field:match("^color(%d)$"))
		if color or field == "paintjob" then
			local x = 10 + (color and color - 1 or 4) * (width - 20) / 5
			return {x = x, y = 143, width = (width - 20) / 5 - 10, labelX = x, labelY = 120, height = 23}
		elseif field == "upgrades" then
			local _, paneHeight = guiGetSize(spnProperties, false)
			return {x = 10, y = 200, width = width * 0.6 - 25, labelX = 10, labelY = 177, height = math.max(150, paneHeight - 210), columns = 3}
		else
			local fields = {plate = 0, sirens = 1, health = 2, interior = 3, dimension = 4, alpha = 5, frozen = 6, collisions = 7, locked = 8, landingGearDown = 9, ["locked-s"] = 10}
			if fields[field] then
				local x = math.floor(width * 0.6)
				if field == "plate" then
					return {x = x, y = 185, width = width - x - 15, labelX = x, labelY = 162, height = 23}
				end
				local index = fields[field] - 1
				local cellWidth = (width - x - 15) / 2
				x = x + (index % 2) * cellWidth
				local y = 220 + math.floor(index / 2) * 50
				return {x = x, y = y + 20, width = cellWidth - 10, labelX = x, labelY = y, height = 23}
			end
		end
	end
	return {x = 110, y = propertiesYPos, width = math.min(300, width - 130), labelX = 10, labelY = propertiesYPos}
end

local commonApplier = {
	position = function (control)
		return edf.edfSetElementPosition(selectedElement, unpack(control:getValue()))
	end,
	rotationZ = function (control)
		return edf.edfSetElementRotation(selectedElement, 0, 0, control:getValue())
	end,
	rotationXYZ = function (control)
		return edf.edfSetElementRotation(selectedElement, unpack(control:getValue()))
	end,
	dimension = function(control)
		local dimension = control:getValue()
		if dimension then
			return setElementData(selectedElement, "me:dimension", dimension)
		else
			return false
		end
	end,
	interior = function(control)
		return edf.edfSetElementInterior(selectedElement, control:getValue())
	end,
}

function createPropertiesBox()
	wndProperties = guiCreateWindow(
		layout.window.x,
		layout.window.y,
		layout.window.width,
		layout.window.height,
		"PROPERTIES",
		layout.relative
	)
	guiWindowSetSizable(wndProperties, true)
	guiSetProperty ( wndProperties, "AbsoluteMinSize", "w:"..layout.window.width.." h:"..math.min(350, layout.window.height) )
	guiSetProperty ( wndProperties, "AbsoluteMaxSize", "w:"..layout.window.width.." h:"..(screenY - 20) )
	addEventHandler ( "onClientGUISize", wndProperties, propertiesResize, false )

	spnProperties = guiCreateScrollPane(
		layout.pane.x,
		layout.pane.y,
		layout.pane.width,
		layout.pane.height,
		layout.relative,
		wndProperties
	)
	guiScrollPaneSetScrollBars(spnProperties, false, false)
	guiSetProperty(spnProperties, "ContentPaneAutoSized", "False")
	guiSetProperty(spnProperties, "VertStepSize", "0.15")

	guiSetVisible( wndProperties, false )

	lblTypeCaption = guiCreateLabel(
		layout.padding.left,
		layout.padding.top,
		layout.label.width,
		layout.label.height,
		"type",
		layout.relative,
		spnProperties
	)

	guiLabelSetVerticalAlign ( lblTypeCaption, "center" )
	guiLabelSetColor( lblTypeCaption, layout.label.R, layout.label.G, layout.label.B )

	lblType = guiCreateLabel(
		layout.padding.left + layout.label.width,
		layout.padding.top,
		layout.control.width,
		layout.label.height,
		"",
		layout.relative,
		spnProperties
	)
	guiLabelSetVerticalAlign ( lblType, "center" )

	lblIDCaption = guiCreateLabel(
		layout.padding.left,
		layout.padding.top + layout.label.height,
		layout.label.width,
		layout.label.height,
		"ID",
		layout.relative,
		spnProperties
	)
	guiLabelSetVerticalAlign ( lblIDCaption, "center" )
	guiLabelSetColor( lblIDCaption, layout.label.R, layout.label.G, layout.label.B )

	edtID = guiCreateEdit(
		100,
		layout.padding.top,
		layout.pane.width * 0.35 - 110,
		layout.label.height,
		"",
		layout.relative,
		spnProperties
	)
	addEventHandler("onClientGUIChanged", edtID, function() setPropertiesChanged(true) end, false)

	tooltipID = tooltip.Create(0, 0, "Unique identifier for this element.  Blank the text to allow the editor to auto-assign an ID.")

	lblParentCaption = guiCreateLabel(
		layout.padding.left,
		layout.padding.top + layout.label.height*2,
		layout.label.width,
		editingControl.element.default.height,
		"parent",
		layout.relative,
		spnProperties
	)
	guiLabelSetVerticalAlign ( lblParentCaption, "center" )
	guiLabelSetColor( lblParentCaption, layout.label.R, layout.label.G, layout.label.B )

	cntParent = editingControl.element:create{
		x = layout.pane.width * 0.35 + 55,
		y = layout.padding.top,
		width = layout.pane.width * 0.32 - 65,
		editWidth = .60,
		clearButtonWidth = .10,
		relative = layout.relative,
		parent = spnProperties,
	}
	cntParent:addChangeHandler(function () setPropertiesChanged(true) end)
	guiSetVisible(lblTypeCaption, false)
	guiSetSize(lblType, 70, 23, false)
	guiSetPosition(lblType, 10, 25, false)
	guiSetPosition(lblIDCaption, 75, 25, false)
	guiSetSize(lblIDCaption, 25, 23, false)
	guiSetPosition(lblParentCaption, layout.pane.width * 0.35, 25, false)
	guiSetSize(lblParentCaption, 55, 23, false)

	tooltipParent = tooltip.Create(0, 0, DEFAULT_PARENT_TEXT)

	lineImg = guiCreateStaticImage(
		layout.line.x,
		layout.line.y,
		layout.line.width,
		layout.line.height,
		"client/images/line.png",
		layout.relative,
		wndProperties
	)

	btnApply = guiCreateButton(
		layout.padding.left,
		layout.window.height - layout.padding.bottom,
		layout.button.width,
		layout.button.height,
		"OK",
		layout.relative,
		wndProperties
	)

	btnCancel = guiCreateButton(
		layout.window.width - layout.button.width - 10,
		layout.window.height - layout.padding.bottom,
		layout.button.width,
		layout.button.height,
		"Cancel",
		layout.relative,
		wndProperties
	)


	btnOK = guiCreateButton(
		layout.padding.left,
		layout.window.height - layout.padding.bottom,
		layout.button.width,
		layout.button.height,
		"OK",
		layout.relative,
		wndProperties
	)

	btnPullout = guiCreateButton(
		layout.window.width - layout.pulloutButton.width - layout.padding.right,
		layout.window.height - layout.padding.bottom,
		layout.pulloutButton.width,
		layout.pulloutButton.height,
		">",
		layout.relative,
		wndProperties
	)

	gdlAction = guiCreateGridList(
		0,
		0,
		layout.pullout.width,
		layout.pullout.height,
		false
	)
	guiGridListAddColumn( gdlAction, "", 0.85 )
	for i,text in ipairs(layout.pullout.items) do
		local row = guiGridListAddRow ( gdlAction )
		guiGridListSetItemText ( gdlAction, row, 1, text, false, false )
	end

	guiSetVisible(gdlAction, false)
	guiSetVisible(btnApply, false)
	guiSetVisible(btnCancel, false)
	guiSetVisible(btnOK, false)
	guiSetVisible(btnPullout, false)
	for index, name in ipairs(layout.pullout.items) do
		local button = guiCreateButton(10 + (index - 1) * 90, 90, 80, 20, name, false, spnProperties)
		actionButtons[index] = button
		addEventHandler("onClientGUIClick", button, function(mouseButton)
			if mouseButton == "left" then pulloutAction[name]() end
		end, false)
	end

	--tutorial globals
	properties_btnOK = btnOK
	properties_btnApply = btnApply
	properties_btnCancel = btnCancel
	properties_btnPullout = btnPullout


	addEventHandler("onClientControlBrowserLaunch", spnProperties,
		function ()
			guiSetVisible(wndProperties, false)
		end
	)
	addEventHandler("onClientControlBrowserClose", spnProperties,
		function ()
			guiSetVisible(wndProperties, true)
			guiSetInputEnabled(true)
		end
	)

	bindControl("properties_toggle", "down", toggleProperties)
	-- addCommandHandler("properties", toggleProperties)
end

local function checkForNewID(changedElementData)
	if changedElementData == "me:ID" then
		local newID = getElementData(selectedElement, "me:ID")
		guiSetText(edtID, newID)
		guiSetText( wndProperties, "PROPERTIES: " .. newID )
	end
end

local function deepTableEqual(table1, table2)
	--compare table1 keys with table2's, mark the ones we compare
	local checked = {}
	for k, v in pairs(table1) do
		if type(v) == "table" then
			if type(table2[k]) == "table" then
				local result = deepTableEqual(v, table2[k])
				if not result then
					return false
				end
			else
				return false
			end
		else
			if v ~= table2[k] then
				return false
			end
		end
		checked[k] = true
	end
	--if one key in table2 was not checked, table2 has more keys than table1
	for k in pairs(table2) do
		if not checked[k] then
			return false
		end
	end

	return true
end

--this function creates a new editing control and attaches it to the properties window
local function addPropertyControl( controlType, controlLabelName, controlDescription, propertyApplier, addedParameters )
	local elementType = selectedElement and getElementType(selectedElement) or newElementType
	local toggleFields = {collisions = true, frozen = true, doublesided = true, breakable = true}
	if controlType == "selection" and (controlLabelName == "locked-s" or (elementType == "object" and toggleFields[controlLabelName])) then
		controlType = "propertyToggle"
	end
	local controlPrototype = editingControl[controlType]

	-- if the control type exists,
	if controlPrototype then
		if selectedElement then
			elementType = getElementType(selectedElement)
			local creatorResource = getResourceName(edf.edfGetCreatorResource(selectedElement))
			local creatorDef = resourceElementDefinitions[creatorResource] or resourceElementDefinitions.editor_main

			if creatorDef and creatorDef[elementType] then
				local validModels = creatorDef[elementType].data[controlLabelName] and creatorDef[elementType].data[controlLabelName].validModels

				if validModels then
					local elementModel = getElementModel(selectedElement)
					local validModel = false

					for _, model in pairs(validModels) do
						if tonumber(model) == elementModel then
							validModel = true
							break
						end
					end

					if not validModel then
						return false
					end
				end
			end
		end

		local placement = propertyPlacement(controlLabelName == "locked-s" and "locked-s" or (addedParameters and addedParameters.datafield or controlLabelName))
		local parameters = {
			x = layout.control.x,
			y = propertiesYPos,
			width = layout.control.width,
			relative = layout.relative,
			window = wndProperties,
			parent = spnProperties,
			label = controlLabelName,
			dropHeight = 200, --! for dropdowns
		}

		local newControl

		-- TODO: This should be done in some proper way...
		if controlPrototype == editingControl.vehicleupgrades then
			parameters.vehicle = selectedElement
			if not parameters.vehicle then
				for _, control in ipairs(addedControls) do
					if control:getDataField() == "model" then parameters.vehicle = control:getValue() break end
				end
			end
		end

		addedParameters = addedParameters or {}
		for name, value in pairs(addedParameters) do
			parameters[name] = value
		end
		for name, value in pairs(placement) do parameters[name] = value end
		if controlType == "propertyToggle" and not selectedElement and elementType == "object" then
			parameters.value = "true"
		end
		if controlType == "selection" and parameters.validvalues then
			parameters.dropHeight = math.min(200, (#parameters.validvalues + 0.5) * controlPrototype.default.height)
		end

		newControl = controlPrototype:create( parameters )
		newControl:addChangeHandler(function ()
										setPropertiesChanged(true)
										editor_main.updateArrowMarker()
					    end)
		if propertyApplier and type(propertyApplier) == "function" then
			newControl:addChangeHandler(propertyApplier)
		end

		-- TODO: This should be done in some proper way...
		if controlPrototype == editingControl.vehicleupgrades then
			-- Search for the vehicle model control to attach a callback to update
			-- the compatible vehicle upgrades
			for k,control in ipairs(addedControls) do
				if control:getLabel() == "model" then
					local modelControl = control
					local handlerFunction = function ( control2 )
					        local newModel = modelControl:getValue()
					        if newModel ~= newControl:getCurrentModel() then
					            newControl:addCompatibleUpgrades( newModel )
					        end
					end
					modelControl:addChangeHandler(handlerFunction)
					break
				end
			end
		end

		if selectedElement then
			if newControl:getLabel() == "model" and (elementType == "object" or elementType == "vehicle") then
				local minX, minY, minZ = getElementBoundingBox(selectedElement)
				g_minZ = minZ or 0
				local handlerFunction = function ()
					local minX2, minY2, minZ2 = getElementBoundingBox(selectedElement)
					if minX2 and minY2 and minZ2 then
						local Zoffset = minZ2 - g_minZ
						-- Search the position control
						for k,control in ipairs(addedControls) do
							if control:getLabel() == "position" then
								local oldpos = control:getValue()
								oldpos[3] = oldpos[3] - Zoffset
								control:setValue(oldpos)
								break
							end
						end
						g_minZ = minZ2
					end
				end
				newControl:addChangeHandler(handlerFunction)
			end
		end


		table.insert(addedControls, newControl)
		previousValues[newControl] = newControl:getValue()

		-- create the caption label indicating the editing control's name
		local controlLabel = guiCreateLabel(
			placement.labelX,
			placement.labelY,
			placement.x > placement.labelX and placement.x - placement.labelX or parameters.width,
			23,
			controlLabelName,
			layout.relative,
			spnProperties
		)
		guiLabelSetVerticalAlign ( controlLabel, "center" ) -- align it to the vertical center
		guiLabelSetColor( controlLabel, layout.label.R, layout.label.G, layout.label.B ) -- colour it as the rest of labels
		caption[newControl] = controlLabel
		if controlType == "propertyToggle" then guiSetVisible(controlLabel, false) end

		-- Create the description tooltip
		if controlDescription and type(controlDescription) == "string" then
			local tooltip = tooltip.Create(0, 0, controlDescription)
			table.insert(createdTooltips, tooltip)
			descriptionTooltips[controlLabel] = tooltip
			for name,element in pairs(newControl.GUI) do
				descriptionTooltips[element] = tooltip
			end
		end

		-- store the new base Y position for the next control
		propertiesYPos = math.max(propertiesYPos, parameters.y + (parameters.height or controlPrototype.default.height) + layout.margin.bottom)
		local lastPadding = endPadding[controlType] or 0
		if controlType == "selection" and parameters.validvalues then
			lastPadding = parameters.dropHeight + layout.margin.bottom
		end
		projPropertiesYPos = math.max(parameters.y + (parameters.height or controlPrototype.default.height) + lastPadding, projPropertiesYPos)
		return true
	else
		outputDebugString( "eC."..tostring(controlType).." doesn't exist.", 2 )
		return false
	end
end

local function sortFieldsByIndex(fields)
	local result = {}
	for field, definition in pairs(fields) do
		local f = {}
		f.dataField = field
		f.dataDefinition = definition
		table.insert(result, f)
	end
	table.sort(result, function(a, b) return a.dataDefinition.index < b.dataDefinition.index end)

	return result
end

local function findChildren(element,searchStart,childTable)
	childTable = childTable or {}
	searchStart = searchStart or getResourceRootElement(getResourceFromName"editor_main") --! Should be dynamic map
	for i,child in ipairs(getElementChildren(searchStart)) do
		if 	getElementData(child,"me:parent") == element then
			table.insert(childTable,child)
		end
		childTable = findChildren(element,child,childTable)
	end
	return childTable
end

local function addEDFPropertyControlsForElement( element )
	local elementType = getElementType(element)
	local creatorResource = getResourceName( edf.edfGetCreatorResource ( element) )
	local creatorDef = resourceElementDefinitions[creatorResource] or resourceElementDefinitions.editor_main --!w
	assert(creatorDef and creatorDef[elementType], "No creator resource info.")

	-- restrict parent types
	cntParent:setTypes(creatorDef[elementType].parents)
	-- do not allow choosing the element as its own parent, or if it is a parent already, dont allow it to be a child of its own child (makes no sense)
	local ignoredElements = findChildren (element)
	table.insert(ignoredElements,element)
	cntParent:setIgnoredElements( ignoredElements )
	-- set current parent
	local parent = getElementData(element,"me:parent")
	if parent and getElementType(parent) ~= "map" then
		cntParent:setValue(parent)
	else
		cntParent:setValue(nil)
	end

	--if there was a name given to the parent, then set the label as that
	guiSetText ( lblParentCaption, creatorDef[elementType].parentName or "parent" )
	tooltip.SetText ( tooltipParent, creatorDef[elementType].parentDescription or DEFAULT_PARENT_TEXT )

	local lastCreatedType

	local sortedFields = sortFieldsByIndex(creatorDef[elementType].data)
	for k,v in ipairs(sortedFields) do
		local dataField = v.dataField
		local dataDefinition = v.dataDefinition
		local syncer
		local applier

		if dataField == "position" then
			applier = commonApplier.position
			initialValue = { edf.edfGetElementPosition (element) }
		elseif dataField == "rotation" then
			if dataDefinition.datatype == "number" then --Z rotation
				applier = commonApplier.rotationZ
				initialValue = select(3, edf.edfGetElementRotation (element))
			else --XYZ rotation
				applier = commonApplier.rotationXYZ
				initialValue = { edf.edfGetElementRotation (element) }
			end
		elseif dataField == "dimension" then
			applier = commonApplier.dimension
			initialValue = getElementData(element, "me:dimension") or 0
		elseif dataField == "interior" then
			applier = commonApplier.interior
			initialValue = edf.edfGetElementInterior (element)
		elseif dataField == "alpha" then
			applier = commonApplier.alpha
			initialValue = edf.edfGetElementAlpha (element) or 255
		else
			applier = function (control) edf.edfSetElementProperty(selectedElement, dataField, control:getValue()) end
			initialValue = edf.edfGetElementProperty (element, dataField)
		end

		addPropertyControl(
			dataDefinition.datatype,
			dataDefinition.friendlyname or dataField,
			dataDefinition.description,
			applier, --property local applier function
			{value = initialValue,
			 validvalues = dataDefinition.validvalues,
			 datafield = dataField } --parameters table
		)
	end --for
end

local function addEDFPropertyControlsForType( elementType, resourceName )
	local def = resourceElementDefinitions[resourceName] or resourceElementDefinitions.editor_main --!w
	assert(def and def[elementType], "The definition of the element being created isn't loaded.")

	local lastCreatedType
	local sortedFields = sortFieldsByIndex(def[elementType].data)
	for k,v in ipairs(sortedFields) do
		local dataField = v.dataField
		local dataDefinition = v.dataDefinition

		addPropertyControl(
			dataDefinition.datatype,
			dataDefinition.friendlyname or dataField,
			dataDefinition.description,
			nil,
			{ validvalues = dataDefinition.validvalues, datafield = dataField }
		)
	end
end

local function sendInitialParameters()
	local parametersTable = {}
	for i, control in ipairs(addedControls) do
		local field = control:getDataField()
		parametersTable[control:getLabel() == "locked-s" and "_editorSelectionLocked" or field] = control:getValue()
	end

	closePropertiesBox()

	if triggerEvent ( "onClientElementPreCreate", root, newElementType, newElementResource, parametersTable, false ) then
		triggerServerEvent("doCreateElement", localPlayer,
			newElementType,
			newElementResource,
			parametersTable,
			true -- attach this element to the cursor after creation
		)
	end

	newElementType = nil
	newElementResource = nil
end

local function applyPropertiesChanges()
	local oldValues = {}
	local newValues = {}

	--set ID
	local inputID = guiGetText(edtID)
	if inputID ~= "" and getElementByID(inputID) then
		guiSetText(edtID, getElementID(selectedElement))
	else
		oldValues.id = getElementID(selectedElement)
		newValues.id = inputID
		guiSetText( wndProperties, "PROPERTIES: " .. inputID )
	end

	--set parent
	local newParent = cntParent:getValue()
	local currentParent = getElementData(selectedElement,"me:parent")
	if not currentParent or getElementType(currentParent) == "map" then
		currentParent = nil
	elseif currentParent == selectedElement then
		cntParent:setValue(nil)
	end
	if newParent ~= currentParent then
		oldValues.parent = currentParent
		newValues.parent = newParent
	end

	--prevent editing values while syncing
	guiSetProperty(btnOK,         "Disabled", "True")
	guiSetProperty(btnCancel,     "Disabled", "True")
	guiSetProperty(btnApply,      "Disabled", "True")
	guiSetProperty(spnProperties, "Disabled", "True")

	--set properties
	for i, control in ipairs(addedControls) do
		if control:getDataField() ~= "locked" then -- we don't want to sync it
			local value = control:getValue()
			local modified

			if type(value) ~= "table" then
				modified = (value ~= previousValues[control])
			else
				modified = not deepTableEqual(value, previousValues[control])
			end

			if modified then
				local dataField = control:getDataField()
				oldValues[dataField] = previousValues[control]
				newValues[dataField] = value
				previousValues[control] = value
			end
		end
	end

	-- fix for local elements
	if not isElementLocal(selectedElement) then
		triggerServerEvent("syncProperties", localPlayer, oldValues, newValues, selectedElement)
	else
		outputDebugString("Cannot sync properties for local element.")
	end

	--allow again editing values
	guiSetProperty(btnOK,         "Disabled", "False")
	guiSetProperty(btnCancel,     "Disabled", "False")
	guiSetProperty(btnApply,      "Disabled", "False")
	guiSetProperty(spnProperties, "Disabled", "False")

	toggleProperties()
end

function closePropertiesBox()
	guiSetInputEnabled(false)
	guiSetVisible(wndProperties, false)
	isPropertiesOpen = false

	removeEventHandler( "onClientGUIClick", btnCancel, cancelProperties )
	removeEventHandler( "onClientGUIClick", btnApply, syncPropertiesCallback )
	removeEventHandler( "onClientGUIClick", btnOK, toggleProperties )
	removeEventHandler( "onClientGUIClick", btnPullout, openPullout )
	removeEventHandler( "onClientMouseMove", root, tooltipsCheckMouseMove )

	-- Destroy the tooltips
	for k,tooltip in ipairs(createdTooltips) do
		destroyElement(tooltip)
	end
	createdTooltips = {}
	descriptionTooltips = {}
	if descriptionTimer then
		killTimer(descriptionTimer)
		descriptionTimer = nil
	end
	tooltipShowing = nil

	if selectedElement then
		removeEventHandler("onClientElementDataChange", selectedElement, checkForNewID)
	end

	for index, control in ipairs( addedControls ) do
		control:destroy()
		destroyElement(caption[control])
		caption[control] = nil
	end
	previousValues = {}
	addedControls = {}

	propertiesYPos = layout.control.baseY

	showCursor(false)
	editor_main.resume()

	propertiesChanged = nil

	creatingNewElement = false
end

function addOKButtonHandler (button, state)
	if button == "left" and state == "up" then
		addEventHandler( "onClientGUIClick", btnOK, toggleProperties, false )
		removeEventHandler ( "onClientClick", root, addOKButtonHandler )
	end
end

function openPropertiesBox( element, resourceName, shortcut )
	if isPropertiesOpen then
		return false
	end

	selectedElement = nil
	local openingType = resourceName and element or getElementType(element)
	if openingType ~= lastPropertiesType then
		local width = math.min(screenX - 40, openingType == "object" and 820 or 1000)
		layout.pane.width = width - scrollbarThumbSize
		guiSetProperty(wndProperties, "AbsoluteMinSize", "w:" .. width .. " h:350")
		guiSetProperty(wndProperties, "AbsoluteMaxSize", "w:" .. width .. " h:" .. (screenY - 20))
		guiSetSize(wndProperties, width, math.min(screenY - 40, openingType == "object" and 370 or 650), false)
		local _, paneHeight = guiGetSize(spnProperties, false)
		guiSetSize(spnProperties, layout.pane.width, paneHeight, false)
		guiSetSize(lineImg, width - 20, 1, false)
		lastPropertiesType = openingType
	end
	arrangePropertiesHeader(openingType == "object")
	--Tutorial hook
	if tutorialVars.detectPropertiesBox then
		tutorialNext()
	end
	closeCurrentBrowser()
	editor_main.suspend(true)
	showCursor(true)

	if element and resourceName then
		local elementType = element
		guiSetText( wndProperties, "NEW ELEMENT: " .. elementType )

		newElementType = elementType
		newElementResource = resourceName

		guiSetText( lblType, elementType )

		guiSetVisible( edtID, false )
		guiSetVisible( lblIDCaption, false )

		addEDFPropertyControlsForType( elementType, resourceName )
		if elementType == "object" then
			addPropertyControl("selection", "locked-s", "Locked selection", nil,
				{value = "true", validvalues = {"false", "true"}, datafield = "locked"})
		end

		creatingNewElement = true
		syncPropertiesCallback = sendInitialParameters
		setPropertiesChanged(true)
	else
		selectedElement = element

		local elementID = getElementID(selectedElement)
		elementID = (type(elementID) == "string" and elementID) or "false" -- rollback

		guiSetText( wndProperties, "PROPERTIES: " .. elementID)

		guiSetText( edtID, elementID )
		guiSetText( lblType, getElementType( selectedElement ) )

		guiSetVisible( edtID, true )
		guiSetVisible( lblIDCaption, true )

		addEventHandler("onClientElementDataChange", selectedElement, checkForNewID)

		addEDFPropertyControlsForElement( selectedElement )
		-- `locked` is reserved for vehicles
		addPropertyControl("selection", "locked-s", "Locked selection", function (control) exports.editor_main:lockSelectedElement(selectedElement, control:getValue() == "true" or false) end, {value = exports.editor_main:isElementLocked(selectedElement) and "true" or "false", validvalues = {"false","true"}, datafield = "locked"})

		creatingNewElement = false
		syncPropertiesCallback = applyPropertiesChanges
		setPropertiesChanged(false)
	end

	--Hack to ensure the OK button doesn't get pressed immediately if the properties box is opened whilst the cursor is over the OK button
	guiSetVisible(btnCancel, true)
	if not getKeyState ( "mouse1" ) then --If the left mouse key isnt being pressed, we're okay to allow the OK button to be pressed
		addEventHandler( "onClientGUIClick", btnOK, toggleProperties, false )
	else --Otherwise, we attach a handler which waits for the left mouse button to be released before activating the OK button
		addEventHandler ( "onClientClick", root, addOKButtonHandler )
	end

	addEventHandler( "onClientGUIClick", btnCancel, cancelProperties, false )
	addEventHandler( "onClientGUIClick", btnApply, syncPropertiesCallback, false )
	addEventHandler( "onClientGUIClick", btnPullout, openPullout, false )
	for _, button in ipairs(actionButtons) do
		guiSetVisible(button, not creatingNewElement)
	end


	guiSetInputEnabled(true)
	guiSetVisible(wndProperties, true)
	isPropertiesOpen = true

	if ( shortcut ) then
		for k,control in ipairs(addedControls) do
			if control:getLabel() == shortcut then
				--Focus the control to the shortcut
				control:focus()
				--Sync and autoclose the properties box
				control:addChangeHandler(syncPropertiesCallback)
				--Attach after closing
				control:addChangeHandler(
					function(control2)
						if control2.cancelled then
							triggerServerEvent ( "doDestroyElement", element, true)
						else
							editor_main.selectElement(element,1)
						end
					end
				)
			end
		end
	end

	guiSetProperty(spnProperties, "ContentArea",
	               "l:" .. string.format("%.06f", layout.padding.left) .. " " ..
		       "t:" .. string.format("%.06f", layout.padding.top) .. " " ..
		       "r:" .. string.format("%.06f", layout.pane.width - layout.padding.right) .. " " ..
		       "b:" .. string.format("%.06f", math.max(propertiesYPos,projPropertiesYPos, openingType == "object" and 295 or 0)))
	projPropertiesYPos = 0
	guiScrollPaneSetVerticalScrollPosition(spnProperties, 0)
end

function toggleProperties(hold)
	if isPropertiesOpen then
		closePropertiesBox()
		--selectedElement = nil
		if not hold then
			editor_main.dropElement()
		end
	else
		local element = editor_main.getSelectedElement()
		if element then
			openPropertiesBox(element)
		end
	end
end

function setPropertiesChanged(newState)
	newState = (newState == true)
	if newState == propertiesChanged then return end

	if newState == true then
		guiSetVisible(btnApply, true)
		guiSetVisible(btnCancel, true)
		guiSetVisible(btnOK, false)
	else
		guiSetVisible(btnApply, false)
		guiSetVisible(btnCancel, true)
		guiSetVisible(btnOK, true)
	end

	propertiesChanged = newState
end

function cancelProperties()
	if creatingNewElement then
		closePropertiesBox()
		newElementType = nil
		newElementResource = nil
		return
	end
	undoProperties()
	toggleProperties()
end

function undoProperties()
	for k,control in ipairs(addedControls) do
		local value = control:getValue()
		local modified

		if type(value) ~= "table" then
			modified = (value ~= previousValues[control])
		else
			modified = not deepTableEqual(value, previousValues[control])
		end

		if modified then
			control:setValue(previousValues[control])
		end
	end
	setPropertiesChanged(false)
end

--Resize
function propertiesResize()
	local windowWidth,windowHeight = guiGetSize ( source, layout.relative )
	local x, y = guiGetPosition(wndProperties, false)
	guiSetPosition(wndProperties, x, math.max(0, math.min(y, screenY - windowHeight)), false)
	--Resize the scrollpane
	local spnWidth = guiGetSize ( spnProperties, layout.relative )
	guiSetSize (
		spnProperties,
		spnWidth,
		windowHeight - layout.button.height - scrollbarThumbSize - layout.padding.bottom + 2,
		layout.relative
	)
	for _, control in ipairs(addedControls) do
		if control:getDataField() == "upgrades" then
			local _, paneHeight = guiGetSize(spnProperties, false)
			local height = math.max(150, paneHeight - 210)
			guiSetSize(control.GUI.list, layout.pane.width * 0.6 - 25, height, false)
			propertiesYPos = math.max(525, 200 + height + layout.margin.bottom)
			guiSetProperty(spnProperties, "ContentArea", "l:10 t:25 r:" .. layout.pane.width .. " b:" .. propertiesYPos)
		end
	end
	--Reposition the line
	guiSetPosition (
		lineImg,
		layout.padding.left,
		windowHeight - layout.padding.bottom - 8,
		layout.relative
	)
	--Reposition the OK, cancel and pullout buttons
	guiSetPosition (
		btnApply,
		layout.padding.left,
		windowHeight - layout.padding.bottom,
		layout.relative
	)
	guiSetPosition (
		btnCancel,
		windowWidth - layout.button.width - 10,
		windowHeight - layout.padding.bottom,
		layout.relative
	)
	guiSetPosition (
		btnOK,
		layout.padding.left,
		windowHeight - layout.padding.bottom,
		layout.relative
	)
	guiSetPosition (
		btnPullout,
		windowWidth - layout.pulloutButton.width - layout.padding.right,
		windowHeight - layout.padding.bottom,
		layout.relative
	)
end

-- Tooltips
local lblLastOver
function tooltipsCheckMouseMove()
	if lblLastOver == source then return end
	if descriptionTimer then
		killTimer(descriptionTimer)
		descriptionTimer = nil
	end

	if ( tooltipShowing ) then
		tooltip.FadeOut(tooltipShowing)
		tooltipShowing = nil
	end

	local t = nil
	if source then
		if descriptionTooltips[source] then t = descriptionTooltips[source]
		elseif source == lblIDCaption or source == edtID then t = tooltipID;
		elseif source == lblParentCaption or table.find( cntParent.GUI, source ) then t = tooltipParent end
		lblLastOver = source
	end

	if t then
		descriptionTimer = setTimer(function ()
						local w,h = guiGetScreenSize()
						local x,y = getCursorPosition()
						x = math.floor(x * w) + 10
						y = math.floor(y * h) + 10
						tooltipShowing = t
						tooltip.SetPosition(t, x, y)
						tooltip.FadeIn(t,5)
						descriptionTimer = nil
					    end, 750, 1)

	end
end

local function pulloutClick(button, state)
	if state == "up" then return end
	if source ~= gdlAction then
		guiSetEnabled ( btnPullout, true )
		guiSetVisible ( gdlAction, false )
		removeEventHandler ( "onClientGUIWorldClick", root,pulloutClick )
		return
	end
	local item = guiGridListGetSelectedItem ( gdlAction )
	if item == -1 then return end
	removeEventHandler ( "onClientGUIWorldClick", root,pulloutClick )
	guiSetEnabled ( btnPullout, true )
	guiSetVisible(gdlAction,false)
	pulloutAction[guiGridListGetItemText(gdlAction,item,1)]()
	guiGridListSetSelectedItem(gdlAction,-1,-1)
end

function openPullout()
	if guiGetVisible ( gdlAction ) then return end
	guiSetEnabled ( btnPullout, false )
	guiSetVisible ( gdlAction, true )
	addEventHandler ( "onClientGUIWorldClick", root,pulloutClick )
	local x,y = guiGetPosition ( wndProperties, false )
	local sizeX, sizeY = guiGetSize ( wndProperties, false )
	x = x + sizeX
	y = y + sizeY
	guiSetPosition ( gdlAction, x, y - layout.pullout.height, false )
end


function pulloutAction.Clone()
	syncPropertiesCallback()
	editor_main.doCloneElement(selectedElement)
end

function pulloutAction.Delete()
	editor_main.destroySelectedElement()
	toggleProperties()
	move_keyboard.disable()
end

function pulloutAction.CopyPOS()
	local x, y, z = getElementPosition(selectedElement)
	local rx, ry, rz = getElementRotation(selectedElement)
	setClipboard(x..","..y..","..z..","..rx..","..ry..","..rz)
	outputChatBox("Position "..x..","..y..","..z..","..rx..","..ry..","..rz.." copied to clipboard")
end
