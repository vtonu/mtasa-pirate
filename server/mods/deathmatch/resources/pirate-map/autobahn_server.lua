-- AUTOBAHN PARKING LOT
addEventHandler("onResourceStart",resourceRoot,function()
    local x,y,z=2120.53345,1385.60352,10.33460
    local marker=createMarker(x,y,z-1,"cylinder",1.5,255,230,109,150)
    if not isElement(marker) then return end
    setElementID(marker,"autobahnParking")
    setElementData(marker,"play.notificationOnly",true)
    local blip=createBlipAttachedTo(marker,53,2,255,255,255,255,0,65535)
    if isElement(blip) then
        setElementID(blip,"autobahnParkingBlip")
        setElementData(blip,"blipName","Autobahn")
    end
end)
