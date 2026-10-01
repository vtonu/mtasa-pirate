-- ==========================================
-- PICKUP MANAGEMENT
-- ==========================================
local pickupTimers = {}
local pickupsToSpawn = {}

local RESPAWN_MS = 5000
local LOCO_RESPAWN_MS = 30000
local LOCO_AMMO_LIMIT = 1000

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

        local ammo = 0
        if getPedWeapon(playerElement, 8) == 18 then
            ammo = getPedTotalAmmo(playerElement, 8)
        end

        local grant = math.min(10, math.max(0, LOCO_AMMO_LIMIT - ammo))
        if grant > 0 then
            giveWeapon(playerElement, 18, grant, true)
            playMessage(playerElement, "locoPickup")
        else
            playMessage(playerElement, "locoAmmoLimit")
        end

        setElementData(playerElement, "locoMissionActive", true)

        if refreshLocoMissionAccess then
            refreshLocoMissionAccess(playerElement)
        end
    end

    local spawnData = pickupInfo.spawnData
    local respawnMs = pickupInfo.type == "loco" and LOCO_RESPAWN_MS or RESPAWN_MS

    destroyPickup(source)

    local existingTimer = pickupTimers[spawnData]

    if existingTimer and isTimer(existingTimer) then
        killTimer(existingTimer)
    end

    pickupTimers[spawnData] = setTimer(function()
        createPlayPickup(spawnData)
        pickupTimers[spawnData] = nil
    end, respawnMs, 1)
end

addEventHandler("onPickupHit", root, onPickupHit)
