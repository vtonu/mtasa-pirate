-- DRAW ARROWS AT THEIR SAVED POSITION WITHOUT NATIVE GROUND SNAPPING
local arrows = {}
local texture = svgCreate(128, 128, [[<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128"><defs><linearGradient id="a" x2="0" y2="1"><stop stop-color="white" stop-opacity="0.25"/><stop offset="1" stop-color="white"/></linearGradient></defs><path d="M8 8 Q64 24 120 8 L64 120 Z" fill="url(#a)"/></svg>]])

local function restoreArrows()
    for marker, color in pairs(arrows) do
        if isElement(marker) then
            setMarkerType(marker, "arrow")
            setMarkerColor(marker, unpack(color))
        end
        arrows[marker] = nil
    end
end

local function hideArrow(marker)
    if not texture or getElementType(marker) ~= "marker" or getMarkerType(marker) ~= "arrow" then return end
    arrows[marker] = {getMarkerColor(marker)}
    setMarkerType(marker, "corona")
    local color = arrows[marker]
    setMarkerColor(marker, color[1], color[2], color[3], 0)
end

addEventHandler("onClientPreRender", root, function()
    if not texture then return end
    local editor = getResourceFromName("editor_main")
    if editor and getResourceState(editor) == "running" then
        restoreArrows()
        return
    end
    for _, marker in ipairs(getPirateElements("marker")) do
        hideArrow(marker)
    end
    local px, py, pz = getElementPosition(localPlayer)
    for marker, color in pairs(arrows) do
        if isElement(marker) then
            local r, g, b, a = getMarkerColor(marker)
            if a ~= 0 then
                color = {r, g, b, a}
                arrows[marker] = color
                setMarkerColor(marker, r, g, b, 0)
            end
            local owner = getElementData(marker, "bone:markerOwner")
            if (not owner or owner == localPlayer)
                and getElementInterior(marker) == getElementInterior(localPlayer)
                and getElementDimension(marker) == getElementDimension(localPlayer) then
                local x, y, z = getElementPosition(marker)
                if getElementID(marker) == "theHighRollerMarker" then z = z + 1 end
                if getDistanceBetweenPoints3D(px, py, pz, x, y, z) <= 100 then
                    local size = getMarkerSize(marker)
                    dxDrawMaterialLine3D(x, y, z + size * 0.5, x, y, z - size * 0.5,
                        texture, size, tocolor(unpack(color)))
                end
            end
        end
    end
end)

addEventHandler("onClientElementDestroy", root, function() arrows[source] = nil end)
addEventHandler("onClientResourceStop", resourceRoot, restoreArrows)
