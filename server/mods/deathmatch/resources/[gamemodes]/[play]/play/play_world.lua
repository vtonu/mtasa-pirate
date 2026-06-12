-- ==========================================
-- PLAY WORLD SETTINGS
-- ==========================================

local DEFAULT_WORLD_SETTINGS = {
    gameType = "Custom",
    mapName = "Las Venturas Freeroam",
    time = {0, 0},
    minuteDuration = 999999999,
    weather = 11,
    cloudsEnabled = true,
    gravity = 0.008,
    explosionsEnabled = true
}

local safeZoneCols = {}

local function getWorldSetting(settingName)
    if playWorldSettings and playWorldSettings[settingName] ~= nil then
        return playWorldSettings[settingName]
    end

    return DEFAULT_WORLD_SETTINGS[settingName]
end

local function isPositionInPlaySafeZone(posX, posY, posZ)
    for i = 1, #safeZoneCols do
        local colShape = safeZoneCols[i]

        if isElement(colShape) and isInsideColShape(colShape, posX, posY, posZ) then
            return true
        end
    end

    return false
end

local function isElementInPlaySafeZone(element)
    if not isElement(element) then
        return false
    end

    return isPositionInPlaySafeZone(getElementPosition(element))
end

local function initPlaySafeZones()
    if not playSafeZones then
        return false
    end

    for i = 1, #playSafeZones do
        local zone = playSafeZones[i]
        local colShape = createColSphere(zone.x, zone.y, zone.z, zone.radius)

        if colShape then
            setElementData(colShape, "play.safeZone.name", zone.name or "Safe Zone")
            safeZoneCols[#safeZoneCols + 1] = colShape
        end
    end

    return true
end

local function onPlaySafeZonePlayerDamage()
    if isElementInPlaySafeZone(source) then
        cancelEvent()
    end
end

local function onPlaySafeZoneExplosion(posX, posY, posZ)
    if not getWorldSetting("explosionsEnabled") then
        cancelEvent()
        return
    end

    if isPositionInPlaySafeZone(posX, posY, posZ) then
        cancelEvent()
    end
end

function initPlayWorld()
    local time = getWorldSetting("time")

    setGameType(getWorldSetting("gameType"))
    setMapName(getWorldSetting("mapName"))
    resetMapInfo()

    setMinuteDuration(getWorldSetting("minuteDuration"))
    setTime(time[1], time[2])
    setWeather(getWorldSetting("weather"))
    setCloudsEnabled(getWorldSetting("cloudsEnabled"))
    setGravity(getWorldSetting("gravity"))

    initPlaySafeZones()
    addEventHandler("onPlayerDamage", root, onPlaySafeZonePlayerDamage)
    addEventHandler("onExplosion", root, onPlaySafeZoneExplosion)
end

function arePlayExplosionsEnabled()
    return getWorldSetting("explosionsEnabled")
end
