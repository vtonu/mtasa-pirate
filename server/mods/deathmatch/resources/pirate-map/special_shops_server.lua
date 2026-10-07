-- RESERVED FOR SPECIAL SHOPS AND PERKS
addEventHandler("onResourceStart", resourceRoot, function()
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
        "cylinder", 0.8, 127, 255, 212, 150)
    setElementID(marker, "specialShopRedCounty")
    setElementInterior(marker, getElementInterior(machine))
    setElementDimension(marker, getElementDimension(machine))
    setElementData(marker, "specialShop:reserved", true)
end)
