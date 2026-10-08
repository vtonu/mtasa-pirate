-- ==========================================
-- PLAY VEHICLE MANAGEMENT
-- ==========================================
local vehicleTimers = {}
local playerVehicles = {}
local vehicleOwners = {}
local vehiclesToSpawn = {}
local spawnDistance = 30
local aircraftSpawnDistance = 50
local sportsCarModels = {
    [402] = true, [411] = true, [415] = true, [429] = true, [451] = true,
    [477] = true, [480] = true, [502] = true, [506] = true, [541] = true,
    [555] = true, [558] = true, [559] = true, [560] = true, [562] = true,
    [565] = true, [587] = true, [602] = true, [603] = true
}

-- ==========================================
-- VEHICLE CREATION
-- ==========================================

-- Spawn All Configured Vehicles From play_config.lua
function createVehicles()
    for vehicleID = 1, #vehicleSpawns do
        createPlayVehicle(vehicleSpawns[vehicleID])
    end
end

-- Create A Single Spawn Vehicle
function createPlayVehicle(vehicleData)
    local modelID, posX, posY, posZ, rotZ = unpack(vehicleData)

    local vehicleElement = createVehicle(modelID, posX, posY, posZ, 0, 0, rotZ)

    if not vehicleElement then
        return false
    end

    setVehicleDamageProof(vehicleElement, true)
    setElementFrozen(vehicleElement, true)
    setElementCollisionsEnabled(vehicleElement, false)

    -- Vehicle Color (Aquamarine)
    local vehicleType = getVehicleType(vehicleElement)
    if vehicleType == "Plane" or vehicleType == "Helicopter" then
        setVehicleColor(vehicleElement, 3, 0, 0, 217, 5, 60, 0, 0, 0, 0, 0, 0)
    elseif modelID == 411 or modelID == 539 or modelID == 457 then
        setVehicleColor(vehicleElement, 127, 255, 212, 127, 255, 212, 127, 255, 212, 127, 255, 212)
    end

    -- Vehicle Settings
    if sportsCarModels[modelID] then
        -- SPORTS CAR SPEED TUNING
        setElementData(vehicleElement, "play.sportsCarSpeedLimit", true)
        setVehicleHandling(vehicleElement, "maxVelocity", 350)
        setVehicleHandling(vehicleElement, "engineAcceleration", 18)
        setVehicleHandling(vehicleElement, "dragCoeff", 1.2)
        addVehicleUpgrade(vehicleElement, 1010)
    end

    if modelID == 411 or modelID == 457 then
        setVehicleHeadLightColor(vehicleElement, 127, 255, 212) -- Headlights
        addVehicleUpgrade(vehicleElement, 1010) -- Nitro
        addVehicleUpgrade(vehicleElement, 1080) -- Wheels
    end

    vehiclesToSpawn[vehicleElement] = vehicleData

    return vehicleElement
end

-- ==========================================
-- VEHICLE CLEANUP
-- ==========================================

function destroyVehicle(vehicleElement)
    if isElement(vehicleElement) and (getElementData(vehicleElement, "emmet:missionVan") == true or getElementData(vehicleElement, "bone:missionVan") == true) then return end
    local owner = vehicleOwners[vehicleElement]

    if owner and playerVehicles[owner] then
        playerVehicles[owner][vehicleElement] = nil
    end

    vehicleOwners[vehicleElement] = nil

    if isElement(vehicleElement) then
        destroyElement(vehicleElement)
    end

    destroyVehicleTimer(vehicleElement)
end

function destroyVehicleTimer(vehicleElement)
    local vehicleTimer = vehicleTimers[vehicleElement]

    if vehicleTimer and isTimer(vehicleTimer) then
        killTimer(vehicleTimer)
    end

    vehicleTimers[vehicleElement] = nil
end

-- ==========================================
-- PLAYER VEHICLE TRACKING
-- ==========================================

function assignVehicleToPlayer(playerElement, vehicleElement)
    local savedVehicles = playerVehicles[playerElement]

    if not savedVehicles then
        playerVehicles[playerElement] = {}
        savedVehicles = playerVehicles[playerElement]
    end

    savedVehicles[vehicleElement] = true
    vehicleOwners[vehicleElement] = playerElement
end

function destroyPlayerVehicles(playerElement)
    local savedVehicles = playerVehicles[playerElement]

    if not savedVehicles then
        return false
    end

    for vehicleElement in pairs(savedVehicles) do
        if isElement(vehicleElement) then
            destroyElement(vehicleElement)
        end

        destroyVehicleTimer(vehicleElement)
        vehicleOwners[vehicleElement] = nil
    end

    playerVehicles[playerElement] = nil
end

-- ==========================================
-- VEHICLE EVENTS
-- ==========================================

function onVehicleEnter(playerElement)

    -- Cancel Any Existing Abandonment Timer
    destroyVehicleTimer(source)

    local vehicleData = vehiclesToSpawn[source]

    if not vehicleData then
        return false
    end

    -- Remove Spawn Tracking Once Taken
    vehiclesToSpawn[source] = nil

    setVehicleDamageProof(source, false)
    setElementFrozen(source, false)
    setElementCollisionsEnabled(source, true)

    assignVehicleToPlayer(playerElement, source)

    local _, spawnX, spawnY, spawnZ = unpack(vehicleData)
    local vehicleElement = source
    local vehicleType = getVehicleType(vehicleElement)
    local distanceRequired = (vehicleType == "Plane" or vehicleType == "Helicopter")
        and aircraftSpawnDistance or spawnDistance

    -- Wait Until The Vehicle Leaves The Spawn Pad
    local checkTimer

    checkTimer = setTimer(function()

        if not isElement(vehicleElement) then
            createPlayVehicle(vehicleData)
            if isTimer(checkTimer) then
                killTimer(checkTimer)
            end
            return
        end

        local currentX, currentY, currentZ = getElementPosition(vehicleElement)

        local distance = getDistanceBetweenPoints3D(spawnX, spawnY, spawnZ, currentX, currentY, currentZ)

        if distance > distanceRequired then
            createPlayVehicle(vehicleData)

            if isTimer(checkTimer) then
                killTimer(checkTimer)
            end
        end

    end, 3000, 0)
end

function onVehicleExit()
    if getElementData(source, "emmet:missionVan") == true or getElementData(source, "bone:missionVan") == true then return end

    -- Remove Existing Timer
    destroyVehicleTimer(source)

    -- Keep The Vehicle While Any Seat Is Occupied
    for seat = 0, getVehicleMaxPassengers(source) do
        if getVehicleOccupant(source, seat) then
            return
        end
    end

    -- KEEP PARKED VEHICLES FOR TEN MINUTES
    vehicleTimers[source] = setTimer(function(vehicle)
        if isElement(vehicle) and not next(getVehicleOccupants(vehicle)) then destroyVehicle(vehicle) end
    end, 600000, 1, source)
end

function onVehicleExplode()
    if not isElement(source) or getElementType(source) ~= "vehicle" then return end
    if getElementData(source, "emmet:missionVan") == true or getElementData(source, "bone:missionVan") == true then return end
    if arePlayExplosionsEnabled and not arePlayExplosionsEnabled() then
        return false
    end

    local vehicleElement = source
    local owner = vehicleOwners[vehicleElement]

    if isElement(owner) then
        addPlayerPlayStat(owner, "vehiclesDestroyed", 1)
    end

    local vehicleData = vehiclesToSpawn[vehicleElement]

    if vehicleData then
        vehiclesToSpawn[vehicleElement] = nil

        -- Respawn A Fresh Vehicle At The Spawn Point
        setTimer(createPlayVehicle, 5000, 1, vehicleData)
    end

    -- Remove The Destroyed Wreck
    setTimer(function()
        destroyVehicle(vehicleElement)
    end, 5000, 1)
end

function onVehicleElementDestroy()

    if getElementType(source) ~= "vehicle" then
        return false
    end

    local owner = vehicleOwners[source]

    if owner and playerVehicles[owner] then
        playerVehicles[owner][source] = nil
    end

    destroyVehicleTimer(source)
    vehicleOwners[source] = nil
    local vehicleData = vehiclesToSpawn[source]
    vehiclesToSpawn[source] = nil
    if vehicleData then
        setTimer(createPlayVehicle, 5000, 1, vehicleData)
    end
end
