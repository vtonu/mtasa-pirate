-- WALK-THROUGH OBJECT IDS
local objectIds = {
    greenGulp = true,
    greenGloop = true,
    greenCapsule = true
}

local function applyWalkthrough(object)
    if getElementType(object) == "object" and objectIds[getElementID(object)] then
        setElementCollisionsEnabled(object, false)
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, object in ipairs(getElementsByType("object", resourceRoot)) do
        applyWalkthrough(object)
    end
end)

addEventHandler("onClientElementStreamIn", resourceRoot, function()
    applyWalkthrough(source)
end)
