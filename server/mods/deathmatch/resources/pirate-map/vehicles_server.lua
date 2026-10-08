-- MAP VEHICLES
local vehicles = {}
local stopping = false
local idleDelay = 600000
local wreckDelay = 5000
local respawnDelay = 10000
local spawnDistance = 30
local aircraftSpawnDistance = 50
local paintjobCounts = {
    [483] = 1, [534] = 3, [535] = 3, [536] = 3, [558] = 3,
    [559] = 3, [560] = 3, [561] = 3, [562] = 3, [565] = 3,
    [567] = 3, [575] = 2, [576] = 3
}
local fixedPaintjobs = {
    [534] = 0, [536] = 2, [575] = 1, [483] = 0
}
local remingtonUpgrades = {1086, 1124, 1180, 1179, 1010, 1100, 1127}
local sportsCarModels = {
    [402] = true, [411] = true, [415] = true, [429] = true, [451] = true,
    [477] = true, [480] = true, [502] = true, [506] = true, [541] = true,
    [555] = true, [558] = true, [559] = true, [560] = true, [562] = true,
    [565] = true, [587] = true, [602] = true, [603] = true
}
-- LIGHT POINTS: X, Y, Z, RED, GREEN, BLUE, ALPHA, MINIMUM ALPHA
local vehicleSirens = {
    vehicleStafford = {
        type = 2, allDirections = true, checkVisible = false, randomise = true, silent = true,
        points = {
            { -0.3, -1.5, 0.8, 255, 0, 0, 255, 255 },
            { 0.3, -1.5, 0.8, 0, 0, 255, 255, 255 },
        },
    },
    vehicleHuntley = {
        type = 3, allDirections = true, checkVisible = false, randomise = true, silent = false,
        points = {
            { -0.3, 0, 1.05, 255, 0, 0, 255, 255 },
            { 0.3, 0, 1.05, 0, 0, 255, 255, 255 },
        },
    },
}

local function numbers(value)
    local result = {}
    for part in tostring(value or ""):gmatch("[^,]+") do
        local number = tonumber(part)
        if not number then return {} end
        result[#result + 1] = number
    end
    return result
end

local function clearTimer(data)
    if data.timer and isTimer(data.timer) then killTimer(data.timer) end
    data.timer = nil
end

local function applySettings(vehicle, data)
    local settings = data.settings
    setElementInterior(vehicle, tonumber(settings.interior) or 0)
    setElementDimension(vehicle, tonumber(settings.dimension) or 0)
    setElementAlpha(vehicle, tonumber(settings.alpha) or 255)
    data.used = false
    setElementCollisionsEnabled(vehicle, false)
    setElementFrozen(vehicle, true)
    setVehicleDamageProof(vehicle, true)
    setVehicleLocked(vehicle, settings.locked == "true")
    setElementHealth(vehicle, tonumber(settings.health) or 1000)
    if settings.plate then setVehiclePlateText(vehicle, settings.plate) end
    local model = getElementModel(vehicle)
    local paintjobCount = paintjobCounts[model]
    local paintjob = fixedPaintjobs[model]
    if paintjob == nil then
        paintjob = paintjobCount and math.random(0, paintjobCount - 1) or 3
    end
    setVehiclePaintjob(vehicle, paintjob)
    local vehicleType = getVehicleType(vehicle)
    if vehicleType == "Plane" or vehicleType == "Helicopter" then
        setVehicleColor(vehicle, 3, 0, 0, 217, 5, 60, 0, 0, 0, 0, 0, 0)
    elseif model == 416 then
        setVehicleColor(vehicle, 9, 194, 61, 0, 0, 0, 9, 194, 61, 9, 194, 61)
    elseif model == 411 then
        setVehicleColor(vehicle, 127, 255, 212, 127, 255, 212, 127, 255, 212, 127, 255, 212)
    elseif paintjobCount then
        setVehicleColor(vehicle, 219, 7, 47, 219, 7, 47, 219, 7, 47, 219, 7, 47)
    else
        setVehicleColor(vehicle, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    end
    setVehicleHeadLightColor(vehicle, 127, 255, 212)
    for _, upgrade in ipairs(getVehicleUpgrades(vehicle)) do removeVehicleUpgrade(vehicle, upgrade) end
    for _, upgrade in ipairs(numbers(settings.upgrades)) do addVehicleUpgrade(vehicle, upgrade) end
    if model == 534 then
        for _, upgrade in ipairs(remingtonUpgrades) do addVehicleUpgrade(vehicle, upgrade) end
    end
    if paintjobCount then
        addVehicleUpgrade(vehicle, 1080)
    elseif model ~= 411 and vehicleType == "Automobile" then
        local x, y = tonumber(settings.posX), tonumber(settings.posY)
        if x >= 2095 and x <= 2190 and y >= 1380 and y <= 1425 then
            for _, upgrade in ipairs(getVehicleCompatibleUpgrades(vehicle, 12)) do
                if upgrade == 1085 then
                    addVehicleUpgrade(vehicle, 1085)
                    break
                end
            end
        end
    end
    if sportsCarModels[getElementModel(vehicle)] then
        setElementData(vehicle, "play.sportsCarSpeedLimit", true)
        setVehicleHandling(vehicle, "maxVelocity", 350)
        setVehicleHandling(vehicle, "engineAcceleration", 18)
        setVehicleHandling(vehicle, "dragCoeff", 1.2)
        addVehicleUpgrade(vehicle, 1010)
    end
    local sirens = vehicleSirens[settings.id]
    if sirens then
        removeVehicleSirens(vehicle)
        addVehicleSirens(vehicle, #sirens.points, sirens.type, sirens.allDirections,
            sirens.checkVisible, sirens.randomise, sirens.silent)
        for point, values in ipairs(sirens.points) do
            setVehicleSirens(vehicle, point, unpack(values))
        end
        setVehicleSirensOn(vehicle, getVehicleOccupant(vehicle, 0) ~= false)
    else
        setVehicleSirensOn(vehicle, settings.sirens == "true")
    end
    setVehicleLandingGearDown(vehicle, settings.landingGearDown == "true")
end

local function restoreVehicle(data)
    clearTimer(data)
    local vehicle = data.vehicle
    if not data.isSpawn then
        if isElement(vehicle) and not next(getVehicleOccupants(vehicle)) then
            destroyElement(vehicle)
        end
        return
    end
    if isElement(vehicle) then
        if next(getVehicleOccupants(vehicle)) then return end
        respawnVehicle(vehicle)
    else
        local s = data.settings
        vehicle = createVehicle(tonumber(s.model), tonumber(s.posX), tonumber(s.posY), tonumber(s.posZ),
            tonumber(s.rotX) or 0, tonumber(s.rotY) or 0, tonumber(s.rotZ) or 0)
        if not vehicle then
            outputDebugString("MAP VEHICLE FAILED TO SPAWN: " .. tostring(s.id), 1)
            return
        end
        setElementParent(vehicle, resourceRoot)
        toggleVehicleRespawn(vehicle, false)
        if s.id then setElementID(vehicle, s.id) end
        data.vehicle = vehicle
        vehicles[vehicle] = data
    end
    applySettings(vehicle, data)
end

addEventHandler("onResourceStart", resourceRoot, function()
    local map = xmlLoadFile("pirate-map.map")
    if not map then
        outputDebugString("MAP VEHICLE SETTINGS COULD NOT BE LOADED", 1)
        return
    end
    local mapVehicles = {}
    for _, vehicle in ipairs(getElementsByType("vehicle", resourceRoot)) do
        mapVehicles[getElementID(vehicle)] = vehicle
    end
    for _, node in ipairs(xmlNodeGetChildren(map)) do
        if xmlNodeGetName(node) == "vehicle" then
            local settings = xmlNodeGetAttributes(node)
            local vehicle = settings.id and mapVehicles[settings.id]
            if isElement(vehicle) and settings.id ~= "emmetDeliveryVan" and settings.id ~= "vehicle (Securicar) (1)" then
                local data = { settings = settings, vehicle = vehicle, isSpawn = true }
                vehicles[vehicle] = data
                toggleVehicleRespawn(vehicle, false)
                setVehicleRespawnPosition(vehicle, tonumber(settings.posX), tonumber(settings.posY), tonumber(settings.posZ))
                setVehicleRespawnRotation(vehicle, tonumber(settings.rotX) or 0, tonumber(settings.rotY) or 0, tonumber(settings.rotZ) or 0)
                applySettings(vehicle, data)
            end
        end
    end
    xmlUnloadFile(map)

    -- CATCH EMPTY MAP CARS THAT MISSED THE EXIT TIMER
    setTimer(function()
        for vehicle, data in pairs(vehicles) do
            if isElement(vehicle) and not data.exploded then
                if next(getVehicleOccupants(vehicle)) then
                    clearTimer(data)
                elseif not (data.timer and isTimer(data.timer)) then
                    local settings = data.settings
                    local x, y, z = getElementPosition(vehicle)
                    local distance = getDistanceBetweenPoints3D(x, y, z,
                        tonumber(settings.posX), tonumber(settings.posY), tonumber(settings.posZ))
                    local moved = distance > 3
                        or getElementInterior(vehicle) ~= (tonumber(settings.interior) or 0)
                        or getElementDimension(vehicle) ~= (tonumber(settings.dimension) or 0)
                    local damaged = getElementHealth(vehicle) < (tonumber(settings.health) or 1000)
                    if moved or damaged then
                        data.timer = setTimer(restoreVehicle, idleDelay, 1, data)
                    end
                end
            end
        end
    end, 10000, 0)
end)

addEventHandler("onVehicleEnter", resourceRoot, function(player, seat)
    local data = vehicles[source]
    if not data then return end
    clearTimer(data)
    if not data.used then
        data.used = true
        setElementCollisionsEnabled(source, true)
        setElementFrozen(source, false)
        setVehicleDamageProof(source, false)
    end
    if seat == 0 and vehicleSirens[data.settings.id] then
        setVehicleSirensOn(source, true)
    end
    if not data.isSpawn or (data.spawnTimer and isTimer(data.spawnTimer)) then return end
    local vehicle = source
    local vehicleType = getVehicleType(vehicle)
    local distanceRequired = (vehicleType == "Plane" or vehicleType == "Helicopter")
        and aircraftSpawnDistance or spawnDistance
    -- KEEP THE TAKEN VEHICLE AND REFILL ITS SPAWN SPOT
    data.spawnTimer = setTimer(function()
        if not isElement(vehicle) or data.exploded then return end
        local settings = data.settings
        local x, y, z = getElementPosition(vehicle)
        local distance = getDistanceBetweenPoints3D(x, y, z,
            tonumber(settings.posX), tonumber(settings.posY), tonumber(settings.posZ))
        if distance <= distanceRequired then return end
        killTimer(data.spawnTimer)
        data.spawnTimer = nil
        data.isSpawn = false
        setElementID(vehicle, "")
        restoreVehicle({ settings = settings, isSpawn = true })
    end, 3000, 0)
end)

addEventHandler("onVehicleExit", resourceRoot, function(player, seat)
    local data = vehicles[source]
    if not data then return end
    clearTimer(data)
    if seat == 0 and vehicleSirens[data.settings.id] then
        setVehicleSirensOn(source, false)
    end
    if not next(getVehicleOccupants(source)) then
        data.timer = setTimer(restoreVehicle, idleDelay, 1, data)
    end
end)

addEventHandler("onVehicleExplode", resourceRoot, function()
    local data = vehicles[source]
    if not data then return end
    clearTimer(data)
    data.exploded = true
    data.timer = setTimer(function()
        if isElement(data.vehicle) then destroyElement(data.vehicle) end
    end, wreckDelay, 1)
end)

-- RESTORE MAP CARS REMOVED BY OTHER RESOURCES
addEventHandler("onElementDestroy", resourceRoot, function()
    local data = vehicles[source]
    if not data then return end
    vehicles[source] = nil
    clearTimer(data)
    if data.spawnTimer and isTimer(data.spawnTimer) then killTimer(data.spawnTimer) end
    data.spawnTimer = nil
    data.vehicle = nil
    local delay = data.exploded and respawnDelay or 50
    data.exploded = nil
    if not stopping and data.isSpawn then data.timer = setTimer(restoreVehicle, delay, 1, data) end
end)

addEventHandler("onResourceStop", resourceRoot, function()
    stopping = true
    for _, data in pairs(vehicles) do
        clearTimer(data)
        if data.spawnTimer and isTimer(data.spawnTimer) then killTimer(data.spawnTimer) end
    end
end)
