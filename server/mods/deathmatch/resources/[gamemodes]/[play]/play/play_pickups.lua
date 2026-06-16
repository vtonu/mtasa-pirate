-- ==========================================
-- PICKUP MANAGEMENT
-- ==========================================
local pickupTimers = {}
local pickupsToSpawn = {}

local RESPAWN_MS = 5000

-- ==========================================
-- CREATION
-- ==========================================

local function createPlayPickup(pickupData)

    local pickupType, posX, posY, posZ = unpack(pickupData)

    if not pickupType then
        return false
    end

    local pickupElement
    local blipIcon = 0
    local red, green, blue = 255, 255, 255
    local createMapBlip = true

    -- Health Pickup
    if pickupType == "health" then

        pickupElement = createPickup(posX, posY, posZ, 0, 100, 0)

        blipIcon = 21
        red, green, blue = 255, 0, 0

        -- Armor Pickup
    elseif pickupType == "armor" then

        pickupElement = createPickup(posX, posY, posZ, 1, 100, 0)

        blipIcon = 45
        red, green, blue = 0, 120, 255

        -- Loco Skull Pickup
    elseif pickupType == "loco" then

        pickupElement = createPickup(posX, posY, posZ, 3, 1254, 0)

        blipIcon = 23
        red, green, blue = 127, 255, 212
    else
        return false
    end

    if pickupElement then

        local blip

        if createMapBlip then
            blip = createBlipAttachedTo(pickupElement, blipIcon, 2, red, green, blue, 255, 0, 99999)
        end

        pickupsToSpawn[pickupElement] = {
            type = pickupType,
            spawnData = pickupData,
            blip = blip
        }
    end

    return pickupElement
end

-- ==========================================
-- WORLD INITIALIZATION
-- ==========================================

function createPlayPickups()

    if not pickupSpawns then
        playMessage(root, "configMissingPickups")
        return
    end

    for i = 1, #pickupSpawns do
        createPlayPickup(pickupSpawns[i])
    end
end

-- ==========================================
-- CLEANUP
-- ==========================================

local function destroyPickup(pickupElement)

    local pickupInfo = pickupsToSpawn[pickupElement]

    if pickupInfo and isElement(pickupInfo.blip) then
        destroyElement(pickupInfo.blip)
    end

    if isElement(pickupElement) then
        destroyElement(pickupElement)
    end

    pickupsToSpawn[pickupElement] = nil
end

-- ==========================================
-- INTERACTION
-- ==========================================

local function onPickupHit(playerElement)

    if getElementType(playerElement) ~= "player" then
        return false
    end

    local pickupInfo = pickupsToSpawn[source]

    if not pickupInfo then
        return false
    end

    -- Health Pickup
    if pickupInfo.type == "health" then

        setElementHealth(playerElement, math.min(100, getElementHealth(playerElement) + 50))

        -- Armor Pickup
    elseif pickupInfo.type == "armor" then

        setPedArmor(playerElement, 100)

        -- Loco Skull Pickup
    elseif pickupInfo.type == "loco" then

        giveWeapon(playerElement, 18, 10, true)

        playMessage(playerElement, "locoPickup")

        setElementData(playerElement, "locoMissionActive", true)

        if refreshLocoMissionAccess then
            refreshLocoMissionAccess(playerElement)
        end
    end

    local spawnData = pickupInfo.spawnData

    destroyPickup(source)

    local existingTimer = pickupTimers[spawnData]

    if existingTimer and isTimer(existingTimer) then
        killTimer(existingTimer)
    end

    pickupTimers[spawnData] = setTimer(function()
        createPlayPickup(spawnData)
        pickupTimers[spawnData] = nil
    end, RESPAWN_MS, 1)
end

addEventHandler("onPickupHit", root, onPickupHit)
