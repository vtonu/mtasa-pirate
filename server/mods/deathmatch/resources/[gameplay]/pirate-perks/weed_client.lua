-- STRAIN MOVEMENT PERKS
local SATIVA_RUN_SPEED_LIMIT = 1.65
local SATIVA_RUN_ACCELERATION = 2.10
local SATIVA_SWIM_SPEED_LIMIT = 0.36
local SATIVA_SWIM_ACCELERATION = 1.25
local INDICA_MOVEMENT_SPEED_LIMIT = 0.010

local function boostHorizontalVelocity(speedLimit, acceleration, timeSlice)
    local velocityX, velocityY, velocityZ = getElementVelocity(localPlayer)
    local horizontalSpeed = math.sqrt(velocityX * velocityX + velocityY * velocityY)

    if horizontalSpeed < 0.005 or horizontalSpeed >= speedLimit then
        return
    end

    local frameAcceleration = 1 + ((acceleration - 1) * math.min(timeSlice / 16.6667, 2))
    local boostedSpeed = math.min(speedLimit, horizontalSpeed * frameAcceleration)
    local multiplier = boostedSpeed / horizontalSpeed

    setElementVelocity(localPlayer, velocityX * multiplier, velocityY * multiplier, velocityZ)
end

local function limitHorizontalVelocity(speedLimit)
    local velocityX, velocityY, velocityZ = getElementVelocity(localPlayer)
    local horizontalSpeed = math.sqrt(velocityX * velocityX + velocityY * velocityY)

    if horizontalSpeed <= speedLimit then
        return
    end

    local multiplier = speedLimit / horizontalSpeed
    setElementVelocity(localPlayer, velocityX * multiplier, velocityY * multiplier, velocityZ)
end

local function updateWeedMovement(timeSlice)
    if isPedDead(localPlayer) or isPedInVehicle(localPlayer) then
        return
    end

    local activePerk = getElementData(localPlayer, "weed.perk")

    if activePerk == "indica" and isPedOnGround(localPlayer) and not isElementInWater(localPlayer) and
        (getPedControlState(localPlayer, "forwards") or getPedControlState(localPlayer, "backwards") or
            getPedControlState(localPlayer, "left") or getPedControlState(localPlayer, "right")) then
        limitHorizontalVelocity(INDICA_MOVEMENT_SPEED_LIMIT)
        return
    end

    if activePerk == "sativa" and isPedOnGround(localPlayer) and
        (getPedControlState(localPlayer, "forwards") or getPedControlState(localPlayer, "backwards") or
            getPedControlState(localPlayer, "left") or getPedControlState(localPlayer, "right")) then
        boostHorizontalVelocity(SATIVA_RUN_SPEED_LIMIT, SATIVA_RUN_ACCELERATION, timeSlice)
        return
    end

    if activePerk == "sativa" and isElementInWater(localPlayer) and
        (getPedControlState(localPlayer, "forwards") or getPedControlState(localPlayer, "backwards")) then
        boostHorizontalVelocity(SATIVA_SWIM_SPEED_LIMIT, SATIVA_SWIM_ACCELERATION, timeSlice)
    end
end

addEventHandler("onClientPreRender", root, updateWeedMovement)
