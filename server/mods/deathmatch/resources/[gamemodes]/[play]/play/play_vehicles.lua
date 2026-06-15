-- ==========================================
-- PLAY VEHICLE MANAGEMENT
-- ==========================================

local vehicleTimers = {}
local playerVehicles = {}
local vehicleOwners = {}
local vehiclesToSpawn = {}

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

    local vehicleElement = createVehicle(
        modelID,
        posX,
        posY,
        posZ,
        0,
        0,
        rotZ
    )

    if not vehicleElement then
        return false
    end

    setVehicleDamageProof(vehicleElement, true)
    setElementFrozen(vehicleElement, true)

    -- Vehicle Color (Aquamarine)
    if modelID == 411 or modelID == 539  or modelID == 457 then
        setVehicleColor(
            vehicleElement,
            127, 255, 212,
            127, 255, 212,
            127, 255, 212,
            127, 255, 212
        )
    end

    -- Vehicle Settings
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

    assignVehicleToPlayer(playerElement, source)

    local _, spawnX, spawnY, spawnZ = unpack(vehicleData)
    local vehicleElement = source

    -- Wait Until The Vehicle Leaves The Spawn Pad
    local checkTimer

    checkTimer = setTimer(function()

        if not isElement(vehicleElement) or not isElement(playerElement) then
            if isTimer(checkTimer) then
                killTimer(checkTimer)
            end
            return
        end

        local currentX, currentY, currentZ = getElementPosition(vehicleElement)

        local distance = getDistanceBetweenPoints3D(
            spawnX,
            spawnY,
            spawnZ,
            currentX,
            currentY,
            currentZ
        )

        if distance > 6 then
            createPlayVehicle(vehicleData)

            if isTimer(checkTimer) then
                killTimer(checkTimer)
            end
        end

    end, 3000, 0)
end

function onVehicleExit()

    -- Remove Existing Timer
    destroyVehicleTimer(source)

    -- Keep The Vehicle While Any Seat Is Occupied
    for seat = 0, getVehicleMaxPassengers(source) do
        if getVehicleOccupant(source, seat) then
            return
        end
    end

    -- Start A 60 Second Abandonment Timer
    vehicleTimers[source] = setTimer(
        destroyVehicle,
        60000,
        1,
        source
    )
end

function onVehicleExplode()
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
    vehiclesToSpawn[source] = nil
end
