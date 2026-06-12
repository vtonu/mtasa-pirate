-- radar_blips.lua
-- GTA San Andreas / MTA:SA Radar Blip Reference
-- Used with createBlip, createBlipAttachedTo, getBlipIcon, setBlipIcon

--[[
INTRODUCTION
This file contains all blip icon IDs and their associated names/images.
You can use these IDs with the following functions:
    - createBlip
    - createBlipAttachedTo
    - getBlipColor
    - getBlipIcon
    - getBlipOrdering
    - getBlipSize
    - getBlipVisibleDistance
    - setBlipColor
    - setBlipIcon
    - setBlipOrdering
    - setBlipSize
    - setBlipVisibleDistance

Example usage:
    local blip = createBlip(x, y, z, 6) -- Creates a Gun blip at the given coordinates
]]

local radarBlips = {
    [0] = "Marker",
    [1] = "White_square",
    [2] = "Centre",
    [3] = "Map_here",
    [4] = "North",
    [5] = "Airyard",
    [6] = "Gun",
    [7] = "Barbers",
    [8] = "Big_smoke",
    [9] = "Boatyard",
    [10] = "Burgershot",
    [11] = "Bulldozer",
    [12] = "Cat_pink",
    [13] = "Cesar",
    [14] = "Chicken",
    [15] = "Cj",
    [16] = "Crash1",
    [17] = "Diner",
    [18] = "Emmetgun",
    [19] = "Enemyattack",
    [20] = "Fire",
    [21] = "Girlfriend",
    [22] = "Hospital",
    [23] = "Loco",
    [24] = "Madd Dogg",
    [25] = "Mafia",
    [26] = "Mcstrap",
    [27] = "Mod_garage",
    [28] = "Ogloc",
    [29] = "Pizza",
    [30] = "Police",
    [31] = "Property_green",
    [32] = "Property_red",
    [33] = "Race",
    [34] = "Ryder",
    [35] = "Savehouse",
    [36] = "School",
    [37] = "Mystery",
    [38] = "Sweet",
    [39] = "Tattoo",
    [40] = "Truth",
    [41] = "Waypoint",
    [42] = "Toreno_ranch",
    [43] = "Triads",
    [44] = "Triads_casino",
    [45] = "Tshirt",
    [46] = "Woozie",
    [47] = "Zero",
    [48] = "Date_disco",
    [49] = "Date_drink",
    [50] = "Date_food",
    [51] = "Truck",
    [52] = "Cash",
    [53] = "Flag",
    [54] = "Gym",
    [55] = "Impound",
    [56] = "Runway_light",
    [57] = "Runway",
    [58] = "Gang_b",
    [59] = "Gang_p",
    [60] = "Gang_y",
    [61] = "Gang_n",
    [62] = "Gang_g",
    [63] = "Spray"
}

-- Optional utility functions for scripting
local radarBlipUtils = {}

-- Get blip name by ID
function radarBlipUtils.getName(id)
    return radarBlips[id] or "Unknown Blip"
end

-- Get blip ID by name
function radarBlipUtils.getID(name)
    for id, n in pairs(radarBlips) do
        if n == name then return id end
    end
    return nil
end

return {
    blips = radarBlips,
    utils = radarBlipUtils
}