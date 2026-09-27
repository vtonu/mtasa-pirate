-- CAPSULE MISSION MARKERS
local missions = {}
local deskZone
local targetZone
local rooftopZone
local rooftopMarker
local parachuteReady = {}
local rooftopRewarded = {}
local landedPlayers = {}
local rooftopPrompt = {}

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
    rooftopMarker = createMarker(2059.08545, 2434.55225, 164.8, "corona", 1.4, 255, 90, 25, 180)
    rooftopZone = createColSphere(2059.08545, 2434.55225, 165.61719, 2.5)
    addEventHandler("onColShapeHit", rooftopZone, function(player, matchingDimension)
        if not matchingDimension or not parachuteReady[player] or rooftopRewarded[player] then return end
        if isPedDead(player) or isPedInVehicle(player) then return end
        rooftopPrompt[player] = true
        triggerClientEvent(player, "airyard:rooftopPrompt", resourceRoot)
    end)
end)

addEvent("airyard:claimRooftop", true)
addEventHandler("airyard:claimRooftop", resourceRoot, function()
    if not client or not rooftopPrompt[client] or rooftopRewarded[client] then return end
    rooftopRewarded[client] = true
    rooftopPrompt[client] = nil
    giveWeapon(client, 37, 100000, true)
    outputChatBox("[!] [NOTIFICATION] The rooftop cache is yours. Use the fire to hold them back.", client, 255, 90, 60)
    triggerClientEvent(client, "airyard:rooftopReward", resourceRoot)
end)

addEvent("airyard:parachute", true)
addEventHandler("airyard:parachute", resourceRoot, function()
    if not client or not landedPlayers[client] then return end
    giveWeapon(client, 46, 1, true)
    parachuteReady[client] = true
    triggerClientEvent(client, "airyard:parachuteReady", resourceRoot)
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
    triggerClientEvent(source, "airyard:finished", resourceRoot)
end)
addEventHandler("onPlayerQuit", root, function() missions[source] = nil end)
