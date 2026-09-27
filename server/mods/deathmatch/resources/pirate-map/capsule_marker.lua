-- CAPSULE MISSION MARKERS
local missions = {}
local deskZone
local targetZone

addEventHandler("onResourceStart", resourceRoot, function()
    local marker = createMarker(2000.7, 1522.5, 16.0, "cylinder", 0.8, 127, 255, 212, 150)
    setElementID(marker, "greenCapsuleMarker")
    deskZone = createColSphere(2000.7, 1522.5, 16.7, 1.5)
    setElementData(resourceRoot, "airyard:desk", deskZone)
    local box = getElementByID("rustlerLootBox")
    if not isElement(box) then
        outputDebugString("AIRYARD: RUSTLER LOOT BOX NOT FOUND", 1)
        return
    end
    local x, y, z = getElementPosition(box)
    setElementData(resourceRoot, "airyard:target", {x, y, z})
    createMarker(2024, 1437.6, 9.6, "cylinder", 0.8, 127, 255, 212, 150)
    targetZone = createColSphere(2024, 1437.6, 10.3, 1.5)
    addEventHandler("onColShapeHit", targetZone, function(player, matchingDimension)
        if not matchingDimension or not missions[player] then return end
        if getElementInterior(player) ~= 0 or isPedDead(player) or isPedInVehicle(player) then return end
        missions[player] = nil
        triggerClientEvent(player, "airyard:finished", resourceRoot)
    end)
end)

addEvent("airyard:start", true)
addEventHandler("airyard:start", resourceRoot, function()
    if not client or source ~= resourceRoot then return end
    if isPedDead(client) or isPedInVehicle(client) or not isElement(deskZone) then return end
    if getElementDimension(client) ~= 0 or getElementInterior(client) ~= 0 then return end
    if not isElementWithinColShape(client, deskZone) then return end
    if not isElement(targetZone) then return end
    missions[client] = true
    triggerClientEvent(client, "airyard:started", resourceRoot)
end)

addEventHandler("onPlayerWasted", root, function()
    missions[source] = nil
    triggerClientEvent(source, "airyard:finished", resourceRoot)
end)
addEventHandler("onPlayerQuit", root, function() missions[source] = nil end)
