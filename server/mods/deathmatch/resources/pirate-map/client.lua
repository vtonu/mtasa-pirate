-- ==========================================================
-- OBJECT COLLISION SYSTEM FOR THE PIRATE MAP
-- ==========================================================

addEventHandler("onClientResourceStart", resourceRoot, function()
    
    -- ==========================================================
    -- 1. HANDLE OBJECTS BY MODEL ID (Numbers) ALL MODELS WITH THESE IDS WILL BE AFFECTED
    -- ==========================================================
    local targetMainModels = { 3511, 2567 } -- ALL of these models will become walk-thru
    local targetInvisibleModels = { 964 } -- ALL of these models will become invisible

    -- Loop through ALL objects currently loaded in the map
    for _, obj in ipairs(getElementsByType("object")) do
        local modelID = getElementModel(obj)

        -- Turn off collision for specific Model IDs
        for _, id in ipairs(targetMainModels) do
            if modelID == id then
                setElementCollisionsEnabled(obj, false)
            end
        end

        -- Hide specific filler Model IDs
        for _, id in ipairs(targetInvisibleModels) do
            if modelID == id then
                setElementAlpha(obj, 0)
            end
        end
    end

    -- ==========================================================
    -- 2. HANDLE INDIVIDUAL OBJECTS BY CUSTOM ID (Text names) ONLY OBJECTS WITH THESE EXACT NAMES WILL BE AFFECTED
    -- ==========================================================
    
    -- Target the main palm tree by its exact text name from the editor
    local mainPalm = getElementByID("entrancePalmTree")
    if mainPalm then
        setElementCollisionsEnabled(mainPalm, false) -- Make it walk-thru
    end

    -- Target the ballard collision object by its exact text name from the editor
    local invisibleBallard = getElementByID("entrancePalmTreeBallard")
    if invisibleBallard then
        setElementAlpha(invisibleBallard, 0) -- Make it invisible
    end

end)
