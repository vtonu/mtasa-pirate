-- RESTORE SAVED TEMPLATES AFTER A MISSION RESOURCE RESTART
function createMissionTemplate(elementType, id)
    local settings = exports["pirate-map"]:getMapSettings(elementType, id)
    if not settings then return false end
    local element
    if elementType == "ped" then
        element = createPed(tonumber(settings.model), tonumber(settings.posX), tonumber(settings.posY),
            tonumber(settings.posZ), tonumber(settings.rotZ) or 0)
    elseif elementType == "vehicle" then
        element = createVehicle(tonumber(settings.model), tonumber(settings.posX), tonumber(settings.posY),
            tonumber(settings.posZ), tonumber(settings.rotX) or 0, tonumber(settings.rotY) or 0,
            tonumber(settings.rotZ) or 0)
    end
    if not isElement(element) then return false end
    setElementID(element, id)
    setElementInterior(element, tonumber(settings.interior) or 0)
    setElementDimension(element, tonumber(settings.dimension) or 0)
    setElementHealth(element, tonumber(settings.health) or (elementType == "ped" and 100 or 1000))
    if elementType == "ped" then setPedArmor(element, tonumber(settings.armor) or 0) end
    return element
end
