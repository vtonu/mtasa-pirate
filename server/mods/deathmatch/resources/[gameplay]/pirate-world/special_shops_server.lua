-- RESERVED FOR SPECIAL SHOPS AND PERKS
addEventHandler("onResourceStart", resourceRoot, function()
    for _, shop in ipairs({
        {"specialShopAngelPine", -2203.56470, -2312.25146, 30.61813},
        {"specialShopLSHospital", 1181.31555, -1292.03101, 14.21022}
    }) do
        local marker = createMarker(shop[2], shop[3], shop[4] - 1,
            "cylinder", 0.8, 127, 255, 0, 180)
        setElementID(marker, shop[1])
        setElementData(marker, "specialShop:reserved", true)
        setElementData(marker, "specialShop:catalog", "kratom")
    end
    -- PUMP MARKERS ONLY; NO REFUEL ACTION
    for index, position in ipairs({
        {-2248.72754, -2558.67139, 31.92188},
        {-2244.20337, -2560.79346, 31.92188},
        {-2239.59277, -2563.30737, 31.92188}
    }) do
        local marker = createMarker(position[1], position[2], position[3] - 1,
            "cylinder", 2.5, 255, 153, 51, 150)
        setElementID(marker, "gasStationChiliadPump" .. index)
    end
    local northLV = createMarker(1857.84424, 2234.88062, 10.12500,
        "cylinder", 0.8, 127, 255, 0, 180)
    setElementID(northLV, "specialShopNorthLV")
    setElementData(northLV, "specialShop:reserved", true)
    setElementData(northLV, "specialShop:catalog", "kratom")
    local sprunk=getElementByID("object (CJ_SPRUNK1) (1)")
    if isElement(sprunk) then
        local green=createMarker(2274.52637,-77.58170,25.62993,"cylinder",0.8,127,255,0,180)
        setElementID(green,"specialShopWeedGarden")
        setElementInterior(green,getElementInterior(sprunk))
        setElementDimension(green,getElementDimension(sprunk))
        setElementData(green,"specialShop:reserved",true)
        setElementData(green,"specialShop:catalog","kratom")
    end
    local machine = getElementByID("RedCountyBlackVendingMachine")
    if not isElement(machine) then
        outputDebugString("SPECIAL SHOP MACHINE MISSING", 1)
        return
    end
    local marker = createMarker(2237.20288, 49.77655, 25.48438,
        "cylinder", 0.8, 127, 255, 0, 180)
    setElementID(marker, "specialShopRedCounty")
    setElementInterior(marker, getElementInterior(machine))
    setElementDimension(marker, getElementDimension(machine))
    setElementData(marker, "specialShop:reserved", true)
    setElementData(marker,"specialShop:catalog","kratom")
end)
