-- EMMET DELIVERY
local destinations = {
    {id = "markerEmmetDeliveryDropoffLS", name = "LOS SANTOS", seconds = 180, reward = 100000},
    {id = "markerEmmetDeliveryDropoffRedCounty", name = "RED COUNTY", seconds = 300, reward = 100000},
    {id = "markerEmmetDeliveryDropoffRedCountyWest", name = "RED COUNTY WEST", seconds = 360, reward = 100000}
}
local van, startMarker, home, session, lastDestination
local lastRequests = {}
local stopping = false

local function send(player, ...)
    if isElement(player) then triggerClientEvent(player, "emmet:state", resourceRoot, ...) end
end

local function resetVan()
    if not isElement(van) or not home then return end
    for _, player in pairs(getVehicleOccupants(van)) do removePedFromVehicle(player) end
    fixVehicle(van)
    setElementInterior(van, 0)
    setElementDimension(van, 0)
    setElementPosition(van, home.x, home.y, home.z)
    setElementRotation(van, home.rx, home.ry, home.rz)
    setElementVelocity(van, 0, 0, 0)
    setVehicleTurnVelocity(van, 0, 0, 0)
    setVehicleEngineState(van, false)
    setVehicleLocked(van, true)
    setElementFrozen(van, true)
    setElementCollisionsEnabled(van, true)
    setVehicleDamageProof(van, true)
end

local function finish(message, success)
    local current = session
    if not current then return end
    session = nil
    if isTimer(current.timer) then killTimer(current.timer) end
    if isElement(current.destination.marker) then
        if isElement(current.player) then setElementVisibleTo(current.destination.marker, current.player, false) end
        setElementVisibleTo(current.destination.marker, root, false)
    end
    if success and isElement(current.player) then
        givePlayerMoney(current.player, current.destination.reward)
    end
    send(current.player, "finished", message, success)
    setElementData(resourceRoot, "emmet:busy", false)
    resetVan()
end

addEventHandler("onResourceStart", resourceRoot, function()
    van = getElementByID("emmetDeliveryVan")
    startMarker = getElementByID("markerEmmetDelivery")
    if not isElement(van) or not isElement(startMarker) then
        outputDebugString("EMMET DELIVERY VAN OR START MARKER MISSING", 1)
        return
    end
    local x, y, z = getElementPosition(van)
    local rx, ry, rz = getElementRotation(van)
    home = {x = x, y = y, z = z, rx = rx, ry = ry, rz = rz}
    toggleVehicleRespawn(van, false)
    resetVan()
    setElementData(resourceRoot, "emmet:start", startMarker)
    setElementData(resourceRoot, "emmet:busy", false)
    createBlipAttachedTo(startMarker, 51)
    for _, destination in ipairs(destinations) do
        destination.marker = getElementByID(destination.id)
        if isElement(destination.marker) then
            setElementVisibleTo(destination.marker, root, false)
        else
            outputDebugString("EMMET DELIVERY DROPOFF MISSING: " .. destination.id, 1)
        end
    end
end)

addEvent("emmet:start", true)
addEventHandler("emmet:start", resourceRoot, function()
    if source ~= resourceRoot or not isElement(client) or not isElement(startMarker) or not isElement(van) then return end
    local now = getTickCount()
    if lastRequests[client] and now - lastRequests[client] < 1000 then return end
    lastRequests[client] = now
    if isPedDead(client) or isPedInVehicle(client) or getElementInterior(client) ~= 0
        or getElementDimension(client) ~= 0 then return end
    local x, y, z = getElementPosition(client)
    local sx, sy, sz = getElementPosition(startMarker)
    if getDistanceBetweenPoints3D(x, y, z, sx, sy, sz + 1) > 2 then return end
    if session then send(client, "notice", "DELIVERY ALREADY IN PROGRESS.") return end
    local choices = {}
    for _, destination in ipairs(destinations) do
        if isElement(destination.marker) and destination ~= lastDestination then choices[#choices + 1] = destination end
    end
    if #choices == 0 then send(client, "notice", "NO DELIVERY DESTINATION AVAILABLE.") return end
    local destination = choices[math.random(#choices)]
    lastDestination = destination
    session = {player = client, destination = destination, phase = "pickup"}
    session.timer = setTimer(function() finish("DELIVERY FAILED: VAN NOT COLLECTED.") end, 120000, 1)
    setElementData(resourceRoot, "emmet:busy", true)
    setVehicleLocked(van, false)
    setElementFrozen(van, false)
    setVehicleDamageProof(van, false)
    send(client, "pickup", van, "COLLECT THE DELIVERY VAN.")
end)

addEventHandler("onVehicleStartEnter", resourceRoot, function(player, seat)
    if source == van and (not session or player ~= session.player or seat ~= 0) then cancelEvent() end
end)

addEventHandler("onVehicleEnter", resourceRoot, function(player, seat)
    if source ~= van then return end
    if not session or player ~= session.player or seat ~= 0 then removePedFromVehicle(player) return end
    if session.phase ~= "pickup" then return end
    killTimer(session.timer)
    session.phase = "delivery"
    session.timer = setTimer(function() finish("DELIVERY FAILED: TIME EXPIRED.") end, session.destination.seconds * 1000, 1)
    setElementVisibleTo(session.destination.marker, player, true)
    send(player, "delivery", session.destination.marker, session.destination.seconds, session.destination.name)
end)

addEventHandler("onMarkerHit", resourceRoot, function(element, matchingDimension)
    if not matchingDimension or not session or session.phase ~= "delivery" then return end
    if source ~= session.destination.marker or element ~= van then return end
    if getVehicleController(van) ~= session.player or getElementInterior(van) ~= 0 then return end
    finish("DELIVERY COMPLETE: $" .. session.destination.reward .. " RECEIVED.", true)
end)

addEventHandler("onVehicleExplode", resourceRoot, function()
    if source == van then finish("DELIVERY FAILED: VAN DESTROYED.") end
end)
addEventHandler("onElementDestroy", resourceRoot, function()
    if not stopping and session and (source == van or source == session.destination.marker) then
        finish("DELIVERY FAILED: DELIVERY UNAVAILABLE.")
    end
end)
addEventHandler("onPlayerWasted", root, function()
    if session and source == session.player then finish("DELIVERY FAILED.") end
end)
addEventHandler("onPlayerQuit", root, function()
    lastRequests[source] = nil
    if session and source == session.player then finish("DELIVERY CANCELLED.") end
end)
addEventHandler("onResourceStop", resourceRoot, function()
    stopping = true
    finish("DELIVERY CANCELLED.")
end)
