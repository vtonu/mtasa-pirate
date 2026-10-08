-- EMMET DELIVERY
local destinations = {
    {id = "markerEmmetDeliveryDropoffLS", location = "DOWNTOWN LOS SANTOS", seconds = 180, reward = 498000},
    {id = "markerEmmetDeliveryDropoffRedCounty", location = "PALOMINO CREEK, RED COUNTY", seconds = 300, reward = 500000},
    {id = "markerEmmetDeliveryDropoffRedCountyWest", location = "BLUEBERRY, RED COUNTY", seconds = 360, reward = 750000}
}
local template, startMarker, home, settings
local sessions, vehicleSessions, lastDestinations, lastRequests, recoveries = {}, {}, {}, {}, {}
local attempts = {}
local cooldownSeconds = 300
local stopping = false
local finish
local pickupVan, pickupRecovery
local loot = {}
-- AVAILABLE BOOTY SHOP WEAPONS AND GEAR, USING SHOP PRICES AND AMMO
local lootPool = {
    {weapon = 1, ammo = 1, price = 2000},
    {weapon = 15, ammo = 1, price = 250},
    {weapon = 10, ammo = 1, price = 250},
    {weapon = 12, ammo = 1, price = 250},
    {weapon = 4, ammo = 1, price = 8000},
    {weapon = 8, ammo = 1, price = 18000},
    {weapon = 5, ammo = 1, price = 1000},
    {weapon = 2, ammo = 1, price = 1000},
    {weapon = 3, ammo = 1, price = 1000},
    {weapon = 6, ammo = 1, price = 250},
    {weapon = 7, ammo = 1, price = 1000},
    {weapon = 22, ammo = 1000, price = 4000},
    {weapon = 23, ammo = 1000, price = 6000},
    {weapon = 24, ammo = 500, price = 12000},
    {weapon = 32, ammo = 1000, price = 15000},
    {weapon = 28, ammo = 1000, price = 15000},
    {weapon = 29, ammo = 500, price = 15000},
    {weapon = 25, ammo = 500, price = 15000},
    {weapon = 26, ammo = 500, price = 25000},
    {weapon = 27, ammo = 500, price = 35000},
    {weapon = 30, ammo = 500, price = 25000},
    {weapon = 31, ammo = 500, price = 30000},
    {weapon = 33, ammo = 500, price = 12000},
    {weapon = 34, ammo = 10, price = 15000},
    {weapon = 16, ammo = 10, price = 6000},
    {weapon = 39, ammo = 10, price = 8000},
    {weapon = 18, ammo = 10, price = 6000},
    {weapon = 17, ammo = 10, price = 3000},
    {weapon = 35, ammo = 10, price = 45000},
    {weapon = 36, ammo = 10, price = 60000},
    {weapon = 37, ammo = 1000, price = 30000},
    {weapon = 38, ammo = 500, price = 100000},
    {weapon = 46, ammo = 1, price = 1000},
    {weapon = 42, ammo = 1000, price = 500},
    {weapon = 44, ammo = 1, price = 5000},
    {weapon = 45, ammo = 1, price = 10000},
    {weapon = 40, ammo = 1, price = 500},
}

-- SHUFFLE WITHOUT DUPLICATES AND KEEP THE TOTAL AT OR BELOW $150K
local function chooseLoot()
    local choices, bundle = {}, {}
    for index, item in ipairs(lootPool) do choices[index] = item end
    for index = #choices, 2, -1 do
        local other = math.random(index)
        choices[index], choices[other] = choices[other], choices[index]
    end
    local target, value = math.random(100000, 150000), 0
    for _, item in ipairs(choices) do
        if value + item.price <= 150000 then
            bundle[#bundle + 1] = item
            value = value + item.price
            if value >= target then break end
        end
    end
    return bundle
end

function emmetDropMissionLoot(vehicle)
    local x, y, z = getElementPosition(vehicle)
    local bundle = chooseLoot()
    for index, item in ipairs(bundle) do
        local angle = (index - 1) * math.pi * 2 / #bundle
        local pickup = createPickup(x + math.cos(angle) * 4, y + math.sin(angle) * 4, z, 2, item.weapon, 180001, item.ammo)
        if isElement(pickup) then
            setElementParent(pickup, resourceRoot)
            setElementInterior(pickup, getElementInterior(vehicle))
            setElementDimension(pickup, getElementDimension(vehicle))
            loot[pickup] = {item = item, timer = setTimer(function()
                loot[pickup] = nil
                if isElement(pickup) then destroyElement(pickup) end
            end, 180000, 1)}
        end
    end
end

-- MANUAL GRANT MAKES EACH PICKUP SINGLE USE FOR ALL PLAYERS
addEventHandler("onPickupHit", resourceRoot, function(player)
    local drop = loot[source]
    if not drop then return end
    cancelEvent()
    if isPedDead(player) or isPedInVehicle(player)
        or getElementDimension(player) ~= getElementDimension(source)
        or getElementInterior(player) ~= getElementInterior(source) then return end
    if not giveWeapon(player, drop.item.weapon, drop.item.ammo, false) then return end
    loot[source] = nil
    if isTimer(drop.timer) then killTimer(drop.timer) end
    destroyElement(source)
end)

local function send(player, ...)
    if isElement(player) then triggerClientEvent(player, "emmet:state", resourceRoot, ...) end
end
local function setPlayerBusy(player, state)
    if isElement(player) then setElementData(player, "emmet:busy", state) end
end

-- KEEP THE SHARED PICKUP AT THE ORIGINAL SPOT
local function findPickupPosition()
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        if getElementDimension(vehicle) == 0 and getElementInterior(vehicle) == 0 then
            local vx, vy, vz = getElementPosition(vehicle)
            if math.abs(vz - home.z) < 5 and getDistanceBetweenPoints2D(home.x, home.y, vx, vy) < 7 then
                return false
            end
        end
    end
    return home.x, home.y, home.z
end

-- SHARED SECURICAR SETUP FOR DELIVERY MISSIONS
function emmetConfigureMissionVan(vehicle)
    if not isElement(vehicle) or not settings then return false end
    if getElementData(vehicle, "emmet:armored") == true then return true end
    setElementData(vehicle, "emmet:armored", true)
    setVehiclePlateText(vehicle, settings.plate or "SECURITY")
    setVehiclePaintjob(vehicle, tonumber(settings.paintjob) or 3)
    local colors = {}
    for number in tostring(settings.color or ""):gmatch("[^,]+") do colors[#colors + 1] = tonumber(number) end
    if #colors == 12 then setVehicleColor(vehicle, unpack(colors)) end
    for upgrade in tostring(settings.upgrades or ""):gmatch("[^,]+") do addVehicleUpgrade(vehicle, tonumber(upgrade)) end
    toggleVehicleRespawn(vehicle, false)
    setVehicleDamageProof(vehicle, false)
    setVehicleLocked(vehicle, false)
    setElementFrozen(vehicle, false)
    setVehicleWheelStates(vehicle, 0, 0, 0, 0)
    setElementHealth(vehicle, 1500)
    local handling = getVehicleHandling(vehicle)
    setVehicleHandling(vehicle, "tractionMultiplier", handling.tractionMultiplier * 1.1)
    setVehicleHandling(vehicle, "engineAcceleration", handling.engineAcceleration * 1.08)
    setVehicleHandling(vehicle, "collisionDamageMultiplier", handling.collisionDamageMultiplier * 0.75)
    return true
end

local function createMissionVan()
    local x, y, z = findPickupPosition()
    if not x then return false end
    local vehicle = createVehicle(tonumber(settings.model), x, y, z, home.rx, home.ry, home.rz, settings.plate or "SECURITY")
    if not isElement(vehicle) then return false end
    setElementParent(vehicle, resourceRoot)
    setElementData(vehicle, "emmet:missionVan", true)
    emmetConfigureMissionVan(vehicle)
    return vehicle
end

local function ensurePickupVan()
    if stopping or not home or isElement(pickupVan) or isTimer(pickupRecovery) then return end
    for _, current in pairs(sessions) do
        if current.phase == "pickup" then
            pickupVan = createMissionVan()
            if isElement(pickupVan) then
                for _, waiting in pairs(sessions) do
                    if waiting.phase == "pickup" then send(waiting.player, "pickupVan", pickupVan) end
                end
            end
            return
        end
    end
end

finish = function(current, message, success, wreck)
    if not current or sessions[current.player] ~= current then return end
    local access = attempts[current.serial]
    if access and access.count >= 2 and not access.untilTime then
        access.untilTime = getRealTime().timestamp + cooldownSeconds
    end
    sessions[current.player] = nil
    if current.van then vehicleSessions[current.van] = nil end
    if isTimer(current.timer) then killTimer(current.timer) end
    if isElement(current.publicBlip) then destroyElement(current.publicBlip) end
    if isElement(current.destination.marker) and isElement(current.player) then
        -- HIDE ONLY THIS PLAYER'S MARKER
        setElementVisibleTo(current.destination.marker, current.player, false)
    end
    if success and isElement(current.player) then givePlayerMoney(current.player, current.destination.reward) end
    send(current.player, "finished", message, success)
    if wreck and not stopping then
        setPlayerBusy(current.player, true)
        local timer
        timer = setTimer(function()
            recoveries[timer] = nil
            if isElement(current.van) then destroyElement(current.van) end
            setPlayerBusy(current.player, false)
        end, 5000, 1)
        recoveries[timer] = current
    else
        if isElement(current.van) then destroyElement(current.van) end
        setPlayerBusy(current.player, false)
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    template = getElementByID("emmetDeliveryVan")
    startMarker = getElementByID("markerEmmetDelivery")
    settings = exports["pirate-map"]:getMapSettings("vehicle", "emmetDeliveryVan")
    if not isElement(startMarker) or not settings then
        outputDebugString("EMMET DELIVERY TEMPLATE OR START MARKER MISSING", 1)
        return
    end
    home = {x = tonumber(settings.posX), y = tonumber(settings.posY), z = tonumber(settings.posZ),
        rx = tonumber(settings.rotX) or 0, ry = tonumber(settings.rotY) or 0, rz = tonumber(settings.rotZ) or 0}
    -- REMOVE THE MAP VAN; THE SHARED PICKUP HAS ONE OWNER AFTER ENTRY
    if isElement(template) then destroyElement(template) end
    template = nil
    pickupVan = createMissionVan()
    setElementData(resourceRoot, "emmet:start", startMarker)
    setElementData(resourceRoot, "emmet:busy", false)
    createBlipAttachedTo(startMarker, 51)
    for _, destination in ipairs(destinations) do
        destination.marker = getElementByID(destination.id)
        if isElement(destination.marker) then setElementVisibleTo(destination.marker, root, false)
        else outputDebugString("EMMET DELIVERY DROPOFF MISSING: " .. destination.id, 1) end
    end
    for _, player in ipairs(getElementsByType("player")) do setPlayerBusy(player, false) end
end)

addEvent("emmet:start", true)
addEventHandler("emmet:start", resourceRoot, function()
    if source ~= resourceRoot or not isElement(client) or not isElement(startMarker) or not home then return end
    local now = getTickCount()
    if lastRequests[client] and now - lastRequests[client] < 1000 then return end
    lastRequests[client] = now
    if isPedDead(client) or isPedInVehicle(client) or getElementInterior(client) ~= 0 or getElementDimension(client) ~= 0 then return end
    local x, y, z = getElementPosition(client)
    local sx, sy, sz = getElementPosition(startMarker)
    if getDistanceBetweenPoints3D(x, y, z, sx, sy, sz + 1) > 2 then return end
    if sessions[client] then send(client, "notice", "DELIVERY ALREADY IN PROGRESS.") return end
    local serial = getPlayerSerial(client)
    local access = attempts[serial]
    if access and access.untilTime and getRealTime().timestamp >= access.untilTime then
        attempts[serial] = nil
        access = nil
    end
    if access and access.count >= 2 then
        send(client, "notice", "SORRY, EMMET ISN'T AVAILABLE RIGHT NOW. TRY AGAIN LATER.")
        return
    end
    if getElementData(client, "emmet:busy") then send(client, "notice", "DELIVERY VAN RESETTING. TRY AGAIN SHORTLY.") return end
    local choices, available = {}, {}
    for _, destination in ipairs(destinations) do
        if isElement(destination.marker) then
            available[#available + 1] = destination
            if destination ~= lastDestinations[client] then choices[#choices + 1] = destination end
        end
    end
    if #choices == 0 then choices = available end
    if #choices == 0 then send(client, "notice", "NO DELIVERY DESTINATION AVAILABLE.") return end
    local destination = choices[math.random(#choices)]
    lastDestinations[client] = destination
    access = access or {count = 0}
    access.count = access.count + 1
    attempts[serial] = access
    local current = {player = client, serial = serial, destination = destination, phase = "pickup"}
    sessions[client] = current
    setPlayerBusy(client, true)
    current.timer = setTimer(function() finish(current, "DELIVERY FAILED: VAN NOT COLLECTED.") end, 30000, 1)
    send(client, "pickup", pickupVan, "COLLECT THE DELIVERY VAN.")
    ensurePickupVan()
end)

addEventHandler("onVehicleStartEnter", resourceRoot, function(player, seat)
    if getElementData(source, "emmet:missionVan") ~= true then return end
    if source == pickupVan then
        local waiting = sessions[player]
        if seat ~= 0 or not waiting or waiting.phase ~= "pickup" or isVehicleBlown(source) then cancelEvent() end
        return
    end
    local current = vehicleSessions[source]
    if not current or player ~= current.player or seat ~= 0 then cancelEvent() end
end)
addEventHandler("onVehicleEnter", resourceRoot, function(player, seat)
    if getElementData(source, "emmet:missionVan") ~= true then return end
    if source == pickupVan then
        local waiting = sessions[player]
        if seat ~= 0 or not waiting or waiting.phase ~= "pickup" or isVehicleBlown(source) then
            removePedFromVehicle(player)
            return
        end
        waiting.van = source
        vehicleSessions[source] = waiting
        setElementData(source, "emmet:owner", player)
        pickupVan = nil
        for _, active in pairs(sessions) do
            if active ~= waiting and active.phase == "pickup" then send(active.player, "pickupVan", false) end
        end
    end
    local current = vehicleSessions[source]
    if not current or player ~= current.player or seat ~= 0 then removePedFromVehicle(player) return end
    if current.phase ~= "pickup" then return end
    if isTimer(current.timer) then killTimer(current.timer) end
    current.phase = "delivery"
    current.publicBlip = createBlipAttachedTo(current.van, 41, 2, 255, 255, 255, 255, 0, 16383, root)
    current.timer = setTimer(function() finish(current, "DELIVERY FAILED: TIME EXPIRED.") end, current.destination.seconds * 1000, 1)
    setElementVisibleTo(current.destination.marker, player, true)
    send(player, "delivery", current.destination.marker, current.destination.seconds, current.destination.location)
end)
addEventHandler("onMarkerHit", root, function(element, matchingDimension)
    local current = vehicleSessions[element]
    if not matchingDimension or not current or current.phase ~= "delivery" then return end
    if source ~= current.destination.marker or getVehicleController(current.van) ~= current.player or getElementInterior(current.van) ~= 0 then return end
    finish(current, "DELIVERY COMPLETE: $" .. current.destination.reward .. " RECEIVED.", true)
end)
addEventHandler("onVehicleExplode", resourceRoot, function()
    if source == pickupVan then
        local wreck = pickupVan
        pickupVan = nil
        for _, waiting in pairs(sessions) do
            if waiting.phase == "pickup" then send(waiting.player, "pickupVan", false) end
        end
        pickupRecovery = setTimer(function()
            pickupRecovery = nil
            if isElement(wreck) then destroyElement(wreck) end
            ensurePickupVan()
        end, 5000, 1)
        return
    end
    local current = vehicleSessions[source]
    if current and current.phase == "delivery" then emmetDropMissionLoot(source) end
    finish(current, "DELIVERY FAILED: VAN DESTROYED.", false, true)
end)
addEventHandler("onElementDestroy", resourceRoot, function()
    if stopping then return end
    if source == pickupVan then
        pickupVan = nil
        for _, waiting in pairs(sessions) do
            if waiting.phase == "pickup" then send(waiting.player, "pickupVan", false) end
        end
        return
    end
    local current = vehicleSessions[source]
    if current then
        vehicleSessions[source] = nil
        current.van = false
        finish(current, "DELIVERY FAILED: DELIVERY UNAVAILABLE.")
        return
    end
    local affected = {}
    for _, active in pairs(sessions) do
        if active.destination.marker == source then affected[#affected + 1] = active end
    end
    for _, active in ipairs(affected) do finish(active, "DELIVERY FAILED: DELIVERY UNAVAILABLE.") end
end)
addEventHandler("onPlayerWasted", root, function() finish(sessions[source], "DELIVERY FAILED.") end)

-- PROTECT THE CABIN FROM THE HEADSHOT RESOURCE
addEventHandler("onPlayerPreHeadshot", root, function(_, weapon)
    local vehicle = getPedOccupiedVehicle(source)
    if isElement(vehicle) and getElementData(vehicle, "emmet:armored") == true and type(weapon) == "number"
        and ((weapon >= 22 and weapon <= 34) or weapon == 38) then cancelEvent() end
end)
-- KEEP TIRES AND WINDSCREEN INTACT WITHOUT REPAIRING THE BODY
setTimer(function()
    ensurePickupVan()
    for _, vehicle in ipairs(getElementsByType("vehicle", resourceRoot)) do
        if getElementData(vehicle, "emmet:armored") == true and not isVehicleBlown(vehicle) then
            local a, b, c, d = getVehicleWheelStates(vehicle)
            if a ~= 0 or b ~= 0 or c ~= 0 or d ~= 0 then setVehicleWheelStates(vehicle, 0, 0, 0, 0) end
            if getVehiclePanelState(vehicle, 4) ~= 0 then setVehiclePanelState(vehicle, 4, 0) end
        end
    end
end, 250, 0)
addEventHandler("onPlayerQuit", root, function()
    finish(sessions[source], "DELIVERY CANCELLED.")
    for timer, current in pairs(recoveries) do
        if current.player == source then
            if isTimer(timer) then killTimer(timer) end
            recoveries[timer] = nil
            if isElement(current.van) then destroyElement(current.van) end
        end
    end
    lastRequests[source], lastDestinations[source] = nil, nil
end)
addEventHandler("onResourceStop", resourceRoot, function()
    stopping = true
    if isTimer(pickupRecovery) then killTimer(pickupRecovery) end
    for pickup, drop in pairs(loot) do
        if isTimer(drop.timer) then killTimer(drop.timer) end
        if isElement(pickup) then destroyElement(pickup) end
    end
    local active = {}
    for _, current in pairs(sessions) do active[#active + 1] = current end
    for _, current in ipairs(active) do finish(current, "DELIVERY CANCELLED.") end
    for timer, current in pairs(recoveries) do
        if isTimer(timer) then killTimer(timer) end
        if isElement(current.van) then destroyElement(current.van) end
        setPlayerBusy(current.player, false)
    end
end)
