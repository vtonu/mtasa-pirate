-- SPORTS CAR SPEED LIMITS
local mphFactor = 111.84681456
local lastVehicle = nil
local lastSpeed = 0

addEventHandler("onClientPreRender", root, function(timeSlice)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle or getPedOccupiedVehicleSeat(localPlayer) ~= 0
        or not (getElementData(vehicle, "play.sportsCarSpeedLimit")
            or getElementData(vehicle, "play.infernusSpeedLimit")) then
        lastVehicle = nil
        lastSpeed = 0
        return
    end

    local vx, vy, vz = getElementVelocity(vehicle)
    local speed = math.sqrt(vx * vx + vy * vy) * mphFactor
    if vehicle ~= lastVehicle then
        lastVehicle = vehicle
        lastSpeed = speed
    end

    local seconds = math.min(timeSlice / 1000, 0.1)
    local limit
    if isVehicleNitroActivated(vehicle) then
        -- SLOW BOOST GAIN ABOVE 160 MPH
        limit = math.min(200, math.max(160, lastSpeed + 0.6 * seconds))
    elseif lastSpeed > 160 then
        -- EASE BACK TO 160 MPH AFTER BOOST
        limit = math.max(160, lastSpeed - 8 * seconds)
    else
        -- SLOW SPEED GAIN FROM 140 TO 160 MPH
        limit = math.min(160, math.max(140, lastSpeed + seconds))
    end

    if isVehicleOnGround(vehicle) and speed > limit and speed > 0 then
        local ratio = limit / speed
        setElementVelocity(vehicle, vx * ratio, vy * ratio, vz)
        speed = limit
    end
    lastSpeed = speed
end)
