-- SAVED MAP DATA FOR WORLD AND MISSION RESOURCES
local mapSettings = {}

addEventHandler("onResourceStart", resourceRoot, function()
    local map = xmlLoadFile("pirate-map.map")
    if not map then
        outputDebugString("MAP SETTINGS COULD NOT BE LOADED", 1)
        return
    end
    for _, node in ipairs(xmlNodeGetChildren(map)) do
        local settings = xmlNodeGetAttributes(node)
        settings.elementType = xmlNodeGetName(node)
        mapSettings[#mapSettings + 1] = settings
    end
    xmlUnloadFile(map)
end)

function getMapSettings(elementType, id)
    local result = {}
    for _, saved in ipairs(mapSettings) do
        if saved.elementType == elementType and (not id or saved.id == id) then
            local settings = {}
            for key, value in pairs(saved) do settings[key] = value end
            if id then return settings end
            result[#result + 1] = settings
        end
    end
    return not id and result or false
end
