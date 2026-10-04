-- KEEP NATIVE ARROW DRAWING OUT OF THE EDITOR
local nativeGetType, nativeSetType = getMarkerType, setMarkerType
local nativeGetColor, nativeSetColor = getMarkerColor, setMarkerColor
local previews = {}
local previewKey = "editor.arrowPreview"
local texture = svgCreate(128, 128, [[<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128"><defs><linearGradient id="a" x2="0" y2="1"><stop stop-color="white" stop-opacity="0.25"/><stop offset="1" stop-color="white"/></linearGradient></defs><path d="M8 8 Q64 24 120 8 L64 120 Z" fill="url(#a)"/></svg>]])

local function editorRunning()
	local editor = getResourceFromName("editor_main")
	return editor and getResourceState(editor) == "running"
end

local function hideArrow(marker)
	if not previews[marker] then
		previews[marker] = {nativeGetColor(marker)}
		setElementData(marker, previewKey, true, false)
	end
	nativeSetType(marker, "corona")
	local color = previews[marker]
	nativeSetColor(marker, color[1], color[2], color[3], 0)
end

local function restoreArrow(marker, markerType)
	local color = previews[marker]
	previews[marker] = nil
	if color and isElement(marker) then
		setElementData(marker, previewKey, false, false)
		nativeSetType(marker, markerType or "arrow")
		nativeSetColor(marker, unpack(color))
	end
end

-- EDF GETTERS MUST RETURN THE SAVED TYPE AND COLOR
function getMarkerType(marker)
	if previews[marker] then return "arrow" end
	return nativeGetType(marker)
end

function getMarkerColor(marker)
	if previews[marker] then return unpack(previews[marker]) end
	return nativeGetColor(marker)
end

function setMarkerType(marker, markerType)
	if markerType == "arrow" and editorRunning() and texture then
		hideArrow(marker)
		return true
	end
	if previews[marker] then restoreArrow(marker, markerType) end
	return nativeSetType(marker, markerType)
end

function setMarkerColor(marker, r, g, b, a)
	if previews[marker] then
		previews[marker] = {r, g, b, a or 255}
		return nativeSetColor(marker, r, g, b, 0)
	end
	return nativeSetColor(marker, r, g, b, a)
end

addEventHandler("onClientPreRender", root, function()
	if not texture or not editorRunning() then return end
	for _, marker in ipairs(getElementsByType("marker")) do
		local markerType = nativeGetType(marker)
		if markerType == "arrow" then
			hideArrow(marker)
		elseif previews[marker] and markerType ~= "corona" then
			restoreArrow(marker, markerType)
		end
		local color = previews[marker]
		if color then
			-- PICK UP SELECTION COLORS SET BY OTHER EDITOR RESOURCES
			local r, g, b, a = nativeGetColor(marker)
			if a ~= 0 then
				color = {r, g, b, a}
				previews[marker] = color
				nativeSetColor(marker, r, g, b, 0)
			end
			if getElementDimension(marker) == getElementDimension(localPlayer)
				and getElementInterior(marker) == getElementInterior(localPlayer) then
				local x, y, z = getElementPosition(marker)
				local size = getMarkerSize(marker)
				dxDrawMaterialLine3D(x, y, z + size * 0.5, x, y, z - size * 0.5,
					texture, size, tocolor(unpack(color)))
			end
		end
	end
end)

addEventHandler("onClientElementStreamIn", root, function()
	if texture and editorRunning() and getElementType(source) == "marker"
		and nativeGetType(source) == "arrow" then hideArrow(source) end
end)

addEventHandler("onClientElementDataChange", root, function(key)
	if not previews[source] then return end
	if key == "type" then
		local markerType = getElementData(source, "type")
		if markerType and markerType ~= "arrow" then restoreArrow(source, markerType) end
	elseif key == "color" then
		local value = getElementData(source, "color")
		if type(value) == "string" then
			local r, g, b, a = getColorFromString(value)
			if r then setMarkerColor(source, r, g, b, a) end
		end
	end
end)

addEventHandler("onClientElementDestroy", root, function() previews[source] = nil end)

addEventHandler("onClientResourceStop", root, function()
	local editor = getResourceFromName("editor_main")
	if source ~= resourceRoot and (not editor or source ~= getResourceRootElement(editor)) then return end
	for marker in pairs(previews) do restoreArrow(marker) end
end)
