-- CAPSULE MISSION MARKERS
local missions = {}
local deskZone
local targetZone
local rooftopZone
local parachuteReady = {}
local rooftopRewarded = {}
local landedPlayers = {}
local rooftopPrompt = {}
local hunters = {}

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
        landedPlayers[player] = true
        triggerClientEvent(player, "airyard:finished", resourceRoot)
    end)
    rooftopZone = createColSphere(2059.08545, 2434.55225, 165.61719, 2.5)
end)

addEvent("airyard:parachute", true)
addEventHandler("airyard:parachute", resourceRoot, function()
    if not client or source ~= resourceRoot or not landedPlayers[client] then return end
    local player = client
    landedPlayers[player] = nil
    giveWeapon(client, 46, 1, true)
    setPedWeaponSlot(client, 11)
    outputChatBox("[NOTIFICATION] Get the gift at the Emerlad Isle rooftop!", client, 127, 255, 212)
    parachuteReady[client] = true
    rooftopPrompt[client] = nil
    local hunter = createVehicle(425, 2059.08545, 2434.55225, 166.5, 0, 0, 180)
    if hunter then
        setVehicleColor(hunter, 0, 0, 0, 0, 0, 0)
        setElementData(hunter, "airyard.owner", client)
        hunters[client] = hunter
        local function clearHunter()
            if hunters[player] ~= source then return end
            hunters[player] = nil
            if isElement(player) then
                triggerClientEvent(player, "airyard:hunterGone", resourceRoot)
            end
        end
        addEventHandler("onElementDestroy", hunter, clearHunter)
        addEventHandler("onVehicleExplode", hunter, clearHunter)
    end
    triggerClientEvent(client, "airyard:parachuteReady", resourceRoot, hunter)
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
    landedPlayers[source] = nil
    parachuteReady[source] = nil
    if isElement(hunters[source]) then destroyElement(hunters[source]) end
    hunters[source] = nil
    triggerClientEvent(source, "airyard:finished", resourceRoot)
end)
addEventHandler("onPlayerQuit", root, function() missions[source] = nil end)
