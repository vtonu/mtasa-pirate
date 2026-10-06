-- SHARED COUNTERS FOR EACH AMMU-NATION LAYOUT
local layouts = {
    {marker = "ammuNation2Counter", clerk = "ammuNation2CounterClerkVet", interior = 4, dimensions = {12031}},
    {marker = "ammuNationCounter1", clerk = "ammuNationCounterClerkVet", interior = 1, dimensions = {12022, 12024}},
    {marker = "ammuNationCounter3", clerk = "ammuNationCounterClerkVet3", interior = 6, dimensions = {12020, 12021, 12023, 12025, 12027, 12028, 12030}},
    {marker = "ammuNationCounter4", clerk = "ammuNationCounterClerkVet4", interior = 6, dimensions = {12026}},
    {marker = "ammuNationCounter5", clerk = "ammuNationCounterClerkVet5", interior = 7, dimensions = {12029}},
    {marker = "ammuNationSpecialClerkMarker", clerk = "ammuNationSpecialClerk1", interior = 7, dimensions = {12029}},
    {marker = "ammuNationSpecialClerkMarker2", clerk = "ammuNationSpecialClerk2", interior = 7, dimensions = {12029}}
}
local counters = {}
local function closeShop(player)
    local shop = getResourceFromName("booty-ui")
    if shop and getResourceState(shop) == "running" then exports["booty-ui"]:closeBootyUI(player) end
end

local function createCounters(layout)
    local marker = getElementByID(layout.marker)
    local clerk = getElementByID(layout.clerk)
    if not isElement(marker) or not isElement(clerk) then
        outputDebugString("AMMU COUNTER MARKER OR CLERK MISSING: " .. layout.marker, 1)
        return
    end
    local mx, my, mz = getElementPosition(marker)
    local px, py, pz = getElementPosition(clerk)
    local _, _, rz = getElementRotation(clerk)
    local r, g, b, a = getMarkerColor(marker)
    for index, dimension in ipairs(layout.dimensions) do
        local shopMarker, shopClerk = marker, clerk
        if index > 1 then
            shopMarker = createMarker(mx, my, mz, getMarkerType(marker), getMarkerSize(marker), r, g, b, a)
            shopClerk = createPed(getElementModel(clerk), px, py, pz, rz)
            setElementParent(shopMarker, resourceRoot)
            setElementParent(shopClerk, resourceRoot)
        end
        setElementInterior(shopMarker, layout.interior)
        setElementInterior(shopClerk, layout.interior)
        setElementDimension(shopMarker, dimension)
        setElementDimension(shopClerk, dimension)
        setElementFrozen(shopClerk, true)
        setElementData(shopClerk, "ammu:clerk", true)
        local col = createColSphere(mx, my, mz + 1, 1.6)
        setElementParent(col, resourceRoot)
        setElementInterior(col, layout.interior)
        setElementDimension(col, dimension)
        setElementData(col, "ammu:counterClerk", shopClerk)
        counters[#counters + 1] = col
        addEventHandler("onColShapeHit", col, function(player, matchingDimension)
            if not matchingDimension or getElementType(player) ~= "player" or getElementInterior(player) ~= layout.interior then return end
            setElementData(player, "ammu:shopClerk", shopClerk)
        end)
        addEventHandler("onColShapeLeave", col, function(player)
            if getElementType(player) ~= "player" or getElementData(player, "ammu:shopClerk") ~= shopClerk then return end
            setElementData(player, "ammu:shopClerk", false)
            closeShop(player)
        end)
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    for _, layout in ipairs(layouts) do createCounters(layout) end
    local clerk = getElementByID("pirateShipClerk")
    if isElement(clerk) then
        setElementFrozen(clerk, true)
        setElementData(clerk, "ammu:clerk", true)
    else
        outputDebugString("PIRATE SHIP CLERK MISSING", 1)
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
