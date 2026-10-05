-- KEEP MARKERS CLEAR FOR SHOPS, DOORS AND MISSIONS
local function updateSafeZones()
    local markers = getElementsByType("marker")
    local circles = {}
    for _, name in ipairs({"play", "pirate-map"}) do
        local resource = getResourceFromName(name)
        if resource and getResourceState(resource) == "running" then
            for _, circle in ipairs(getElementsByType("colshape", getResourceRootElement(resource))) do
                if getElementData(circle, "play.notificationOnly") ~= true then
                    table.insert(circles, circle)
                end
            end
        end
    end
    for _, player in ipairs(getElementsByType("player")) do
        local x, y, z = getElementPosition(player)
        local interior = getElementInterior(player)
        local dimension = getElementDimension(player)
        local inside = false
        for _, marker in ipairs(markers) do
            if interior == 0 and getElementInterior(marker) == interior and getElementDimension(marker) == dimension then
                local mx, my, mz = getElementPosition(marker)
                local radius = math.max(3, getMarkerSize(marker) + 2)
                if math.abs(z - mz) <= 3 and getDistanceBetweenPoints2D(x, y, mx, my) <= radius then
                    inside = true
                    break
                end
            end
        end
        if interior == 0 and not inside then
            for _, circle in ipairs(circles) do
                if getElementInterior(circle) == interior and getElementDimension(circle) == dimension
                    and isElementWithinColShape(player, circle) then
                    inside = true
                    break
                end
            end
        end
        setPlayerSafeZoneState(player, inside)
    end
end

setTimer(updateSafeZones, 200, 0)
addEventHandler("onResourceStart", resourceRoot, updateSafeZones)
addEventHandler("onMarkerHit", root, updateSafeZones)
addEventHandler("onMarkerLeave", root, updateSafeZones)
addEventHandler("onColShapeHit", root, updateSafeZones)
addEventHandler("onColShapeLeave", root, updateSafeZones)
