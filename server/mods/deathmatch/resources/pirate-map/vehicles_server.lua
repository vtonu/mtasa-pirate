-- MAP VEHICLES
local vehicles = {}
local stopping = false
local idleDelay = 60000
local wreckDelay = 5000
local respawnDelay = 10000
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
    setElementCollisionsEnabled(vehicle, settings.collisions ~= "false")
    setElementFrozen(vehicle, settings.frozen == "true")
    setVehicleLocked(vehicle, settings.locked == "true")
    setElementHealth(vehicle, tonumber(settings.health) or 1000)
    if settings.plate then setVehiclePlateText(vehicle, settings.plate) end
    setVehiclePaintjob(vehicle, 3)
    setVehicleColor(vehicle, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    setVehicleHeadLightColor(vehicle, 127, 255, 212)
    for _, upgrade in ipairs(getVehicleUpgrades(vehicle)) do removeVehicleUpgrade(vehicle, upgrade) end
    for _, upgrade in ipairs(numbers(settings.upgrades)) do addVehicleUpgrade(vehicle, upgrade) end
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
            if isElement(vehicle) then
                local data = { settings = settings, vehicle = vehicle }
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
    if seat == 0 and vehicleSirens[data.settings.id] then
        setVehicleSirensOn(source, true)
    end
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
    data.vehicle = nil
    local delay = data.exploded and respawnDelay or 50
    data.exploded = nil
    if not stopping then data.timer = setTimer(restoreVehicle, delay, 1, data) end
end)

addEventHandler("onResourceStop", resourceRoot, function()
    stopping = true
    for _, data in pairs(vehicles) do clearTimer(data) end
end)
