-- WALK-THROUGH OBJECT IDS
local objectIds = {
    greenGulp = true,
    greenGloopWeed = true,
    greenCapsuleParachute = true
}

-- WALK-THROUGH MODEL IDS
local modelIds = {
    [734] = true
}

-- INVISIBLE SOLID MODEL IDS
local invisibleSolidModelIds = {
    [964] = true
}

local function applyWalkthrough(object)
    if getElementType(object) ~= "object" then return end

    if invisibleSolidModelIds[getElementModel(object)] then
        setElementAlpha(object, 0)
        setElementCollisionsEnabled(object, true)
        return
    end

    if objectIds[getElementID(object)] or modelIds[getElementModel(object)] then
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
