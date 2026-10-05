-- SHARED COUNTERS FOR AMMU-NATION INTERIOR 1
local counters = {}
local function closeShop(player)
    local shop = getResourceFromName("booty-ui")
    if shop and getResourceState(shop) == "running" then exports["booty-ui"]:closeBootyUI(player) end
end

addEventHandler("onResourceStart", resourceRoot, function()
    local marker = getElementByID("ammuNationCounter1")
    local clerk = getElementByID("ammuNationCounterClerkVet")
    if not isElement(marker) or not isElement(clerk) then
        outputDebugString("AMMU COUNTER MARKER OR CLERK MISSING", 1)
        return
    end
    local mx, my, mz = getElementPosition(marker)
    local px, py, pz = getElementPosition(clerk)
    local _, _, rz = getElementRotation(clerk)
    local r, g, b, a = getMarkerColor(marker)
    for index, dimension in ipairs({12022, 12024}) do
        local shopMarker, shopClerk = marker, clerk
        if index > 1 then
            shopMarker = createMarker(mx, my, mz, getMarkerType(marker), getMarkerSize(marker), r, g, b, a)
            shopClerk = createPed(getElementModel(clerk), px, py, pz, rz)
            setElementParent(shopMarker, resourceRoot)
            setElementParent(shopClerk, resourceRoot)
        end
        setElementInterior(shopMarker, 1)
        setElementInterior(shopClerk, 1)
        setElementDimension(shopMarker, dimension)
        setElementDimension(shopClerk, dimension)
        setElementFrozen(shopClerk, true)
        setElementData(shopClerk, "ammu:clerk", true)
        local col = createColSphere(mx, my, mz + 1, 1.6)
        setElementParent(col, resourceRoot)
        setElementInterior(col, 1)
        setElementDimension(col, dimension)
        setElementData(col, "ammu:counterClerk", shopClerk)
        counters[#counters + 1] = col
        addEventHandler("onColShapeHit", col, function(player, matchingDimension)
            if not matchingDimension or getElementType(player) ~= "player" or getElementInterior(player) ~= 1 then return end
            setElementData(player, "ammu:shopClerk", shopClerk)
        end)
        addEventHandler("onColShapeLeave", col, function(player)
            if getElementType(player) ~= "player" or getElementData(player, "ammu:shopClerk") ~= shopClerk then return end
            setElementData(player, "ammu:shopClerk", false)
            closeShop(player)
        end)
    end
end)

-- DIMENSION CHANGES AND RESOURCE RESTARTS ALSO UPDATE ACCESS
setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        local clerk = false
        if not isPedDead(player) and not isPedInVehicle(player) then
            for _, col in ipairs(counters) do
                if isElement(col) and getElementInterior(player) == getElementInterior(col)
                    and getElementDimension(player) == getElementDimension(col) and isElementWithinColShape(player, col) then
                    clerk = getElementData(col, "ammu:counterClerk")
                    break
                end
            end
        end
        local previous = getElementData(player, "ammu:shopClerk")
        if previous ~= clerk then
            setElementData(player, "ammu:shopClerk", clerk)
            if isElement(previous) then closeShop(player) end
        end
    end
end, 500, 0)

addEventHandler("onResourceStop", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        if isElement(getElementData(player, "ammu:shopClerk")) then
            setElementData(player, "ammu:shopClerk", false)
            closeShop(player)
        end
    end
end)
