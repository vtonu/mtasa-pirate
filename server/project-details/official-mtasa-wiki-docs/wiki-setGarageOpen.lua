--[[ 
    setGarageOpen.lua

    Demonstrates usage of the setGarageOpen function in MTA: San Andreas.

    This function opens or closes a specified garage door in the game world.
    Note: Garage ID 32 (Pay 'n' Spray near Royal Casino) is disabled by Rockstar due to collision issues.
    You can remove and recreate its door with removeWorldModel and moveObject.

    Function syntax:
        bool setGarageOpen(int garageID, bool isOpen)
    
    Returns:
        true  - garage successfully opened/closed
        false - invalid garageID
]]--

-- ===============================
-- Example 1: Single Garage
-- ===============================

local GARAGE_ID = 25 -- ID of the garage to control

-- Create a collision shape near the garage and attach event handlers
addEventHandler("onResourceStart", resourceRoot, function()
    local garageCube = createColCuboid(1337, 194, 28, 6, 10, 4)

    -- Event: Player enters collision shape
    addEventHandler("onColShapeHit", garageCube, function(hitElement)
        if getElementType(hitElement) ~= "player" then return end
        -- Toggle garage door open/closed
        setGarageOpen(GARAGE_ID, not isGarageOpen(GARAGE_ID))
    end)

    -- Event: Player leaves collision shape
    addEventHandler("onColShapeLeave", garageCube, function(leaveElement)
        if getElementType(leaveElement) ~= "player" then return end
        -- Toggle garage door open/closed
        setGarageOpen(GARAGE_ID, not isGarageOpen(GARAGE_ID))
    end)
end)


-- ===============================
-- Example 2: Multiple Garages
-- ===============================

-- List of garage positions in the world {x, y, z}
local garages = {
    {1643.43, -1520.3, 14.3438},
    {1877.41, -2096.51, 14.0391},
    {1843.37, -1856.32, 13.875},
    {1798.69, -2146.73, 14},
    {1698.91, -2088.74, 14.1406},
    {2741.07, -2004.78, 14.875},
    {2644.86, -2039.23, 14.0391},
    {2071.48, -1831.42, 14.5625},
    {2505.52, -1690.99, 14.3281},
    -- add the remaining garages as needed
}

-- Function to create a collision shape for each garage
local function createGarageColShape(x, y, z, ID)
    local col = createColSphere(x, y, z, 7) -- radius 7

    -- Event: Player enters garage collision
    addEventHandler("onColShapeHit", col, function(hitElement)
        if getElementType(hitElement) ~= "player" then return end
        setGarageOpen(ID, not isGarageOpen(ID)) -- toggle open/close
    end)

    -- Event: Player leaves garage collision
    addEventHandler("onColShapeLeave", col, function(leaveElement)
        if getElementType(leaveElement) ~= "player" then return end
        setGarageOpen(ID, not isGarageOpen(ID)) -- toggle open/close
    end)
end

-- Initialize all garage collision shapes when resource starts
addEventHandler("onResourceStart", resourceRoot, function()
    for ID, pos in ipairs(garages) do
        createGarageColShape(pos[1], pos[2], pos[3], ID)
    end
end)


-- ===============================
-- References
-- ===============================
-- See Also:
--  isGarageOpen
--  removeWorldModel
--  restoreWorldModel
--  setWorldSpecialPropertyEnabled
--  resetWorldProperties
--  setInteriorSoundsEnabled
--  setTrafficLightsLocked
--  setWeather
--  setTime