-- TEXT ONLY DELIVERY PROMPTS
local resultText,resultUntil=nil,0
local pickupMarker,pickupZ
local deliveryDeadline

local function nearbyStart()
    if isPedDead(localPlayer) or getPedOccupiedVehicle(localPlayer) then return false end
    local x,y,z=getElementPosition(localPlayer)
    for _,marker in ipairs(getElementsByType("marker",resourceRoot)) do
        if getElementData(marker,"bone:start")==true
            and getElementInterior(marker)==getElementInterior(localPlayer)
            and getElementDimension(marker)==getElementDimension(localPlayer) then
            local mx,my,mz=getElementPosition(marker)
            if getDistanceBetweenPoints2D(x,y,mx,my)<=1.8 and math.abs(z-mz)<=3 then return true end
        end
    end
    return false
end

bindKey("h","down",function()
    if not nearbyStart() or getElementData(localPlayer,"bone:delivery")
        or isCursorShowing() or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() then return end
    triggerServerEvent("bone:load",resourceRoot)
end)

addEvent("bone:result",true)
addEventHandler("bone:result",resourceRoot,function(success)
    resultText=success and "DELIVERY COMPLETE: +$500000" or "DELIVERY ENDED"
    resultUntil=getTickCount()+5000
end)

addEventHandler("onClientElementDataChange",localPlayer,function(key)
    if key~="bone:delivery" then return end
    local data=getElementData(localPlayer,key)
    if type(data)=="table" and data.state=="delivery" then
        deliveryDeadline=getTickCount()+(data.remaining or 300000)
    else deliveryDeadline=nil end
end)

addEventHandler("onClientRender",root,function()
    local now=getTickCount()
    local data=getElementData(localPlayer,"bone:delivery")
    local text
    if type(data)=="table" then
        if data.state=="loading" then text="LOADING THE SECURICAR"
        elseif data.state=="collect" then
            text="COLLECT THE LOAD AT THE SHED"
            if isElement(data.marker) then
                if pickupMarker~=data.marker then
                    pickupMarker=data.marker
                    local _,_,z=getElementPosition(pickupMarker)
                    pickupZ=z
                end
                local x,y=getElementPosition(pickupMarker)
                setElementPosition(pickupMarker,x,y,pickupZ+math.sin(now/700)*0.08)
            end
        elseif data.state=="vehicle" then
            text=isElement(data.vehicle) and "ENTER THE SECURICAR" or "WAIT FOR THE NEXT SECURICAR"
        elseif data.state=="delivery" then
            if not deliveryDeadline then deliveryDeadline=now+(data.remaining or 300000) end
            local remaining=math.max(0,math.ceil((deliveryDeadline-now)/1000))
            text="DELIVER TO "..data.name.."  |  "..math.floor(remaining/60)..":"..string.format("%02d",remaining%60)
        end
        if isElement(data.blip) then
            setBlipColor(data.blip,255,40,40,math.floor(now/400)%2==0 and 255 or 60)
        end
    elseif resultUntil>now then text=resultText
    elseif nearbyStart() then text="PRESS 'H' TO LOAD THE SECURICAR" end
    if text then
        local w,h=guiGetScreenSize()
        dxDrawText(text,16,h*0.82,w-16,h*0.82+36,tocolor(127,255,212,255),
            math.min(1,(w-32)/dxGetTextWidth(text,1,"unifont")),"unifont","center","center")
    end
end)
