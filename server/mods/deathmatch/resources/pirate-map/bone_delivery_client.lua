-- TEXT ONLY DELIVERY PROMPTS
local resultText,resultUntil=nil,0
local pickupMarker,pickupZ
local deliveryDeadline
local cargoObjects={}
local cargoVisible={}
local cargoIds={"securiVehicleBCMissionCrate1","securiVehicleBCMissionCrate2","securiVehicleBCMissionCrate3"}

-- LOCAL CARGO KEEPS EACH PLAYER'S LOAD SEPARATE
local function updateCargo(data)
    local visible=type(data)=="table" and (data.state=="cargo" or data.state=="loading")
    for _,id in ipairs(cargoIds) do
        local object=cargoObjects[id]
        if visible and not isElement(object) then
            local template=getElementByID(id)
            if isElement(template) then
                local x,y,z=getElementPosition(template)
                local rx,ry,rz=getElementRotation(template)
                object=createObject(getElementModel(template),x,y,z,rx,ry,rz)
                if isElement(object) then
                    setElementParent(object,resourceRoot)
                    setObjectScale(object,getObjectScale(template))
                    setElementInterior(object,getElementInterior(template))
                    setElementDimension(object,getElementDimension(template))
                    setElementFrozen(object,true)
                    setElementDoubleSided(object,true)
                    setObjectBreakable(object,false)
                    cargoObjects[id]=object
                end
            end
        end
        if isElement(object) and cargoVisible[id]~=visible then
            setElementAlpha(object,visible and 255 or 0)
            setElementCollisionsEnabled(object,visible==true)
            cargoVisible[id]=visible
        end
    end
end

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
    if isPedDead(localPlayer) or getPedOccupiedVehicle(localPlayer)
        or isCursorShowing() or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() then return end
    local data=getElementData(localPlayer,"bone:delivery")
    if type(data)=="table" then
        if data.state=="collect" and isElement(data.marker) then
            local x,y,z=getElementPosition(localPlayer)
            local mx,my,mz=getElementPosition(data.marker)
            if getElementInterior(localPlayer)==getElementInterior(data.marker)
                and getElementDimension(localPlayer)==getElementDimension(data.marker)
                and getDistanceBetweenPoints2D(x,y,mx,my)<=1.3 and math.abs(z-mz)<=3 then
                triggerServerEvent("bone:collect",resourceRoot)
            end
        elseif data.state=="cargo" and nearbyStart() then
            triggerServerEvent("bone:store",resourceRoot)
        end
    elseif nearbyStart() then triggerServerEvent("bone:load",resourceRoot) end
end)

addEvent("bone:result",true)
addEventHandler("bone:result",resourceRoot,function(success)
    resultText=success and "DELIVERY COMPLETE: +$500000" or "DELIVERY ENDED"
    resultUntil=getTickCount()+5000
end)

addEventHandler("onClientElementDataChange",localPlayer,function(key)
    if key~="bone:delivery" then return end
    local data=getElementData(localPlayer,key)
    updateCargo(data)
    if type(data)=="table" and data.state=="delivery" then
        deliveryDeadline=getTickCount()+(data.remaining or 300000)
    else deliveryDeadline=nil end
end)

addEventHandler("onClientRender",root,function()
    local now=getTickCount()
    local data=getElementData(localPlayer,"bone:delivery")
    updateCargo(data)
    local text
    if type(data)=="table" then
        if data.state=="loading" then text="LOADING THE SECURICAR"
        elseif data.state=="collect" then
            text="PRESS 'H' AT THE SHED TO TAKE OUT THE CARGO"
            if isElement(data.marker) then
                if pickupMarker~=data.marker then
                    pickupMarker=data.marker
                    local _,_,z=getElementPosition(pickupMarker)
                    pickupZ=z
                end
                local x,y=getElementPosition(pickupMarker)
                setElementPosition(pickupMarker,x,y,pickupZ+math.sin(now/700)*0.08)
            end
        elseif data.state=="cargo" then
            text="PRESS 'H' BEHIND THE SECURICAR TO LOAD THE CARGO"
        elseif data.state=="vehicle" then
            text=isElement(data.vehicle) and "ENTER THE SECURICAR" or "WAIT FOR THE NEXT SECURICAR"
        elseif data.state=="delivery" then
            if not deliveryDeadline then deliveryDeadline=now+(data.remaining or 300000) end
            local remaining=math.max(0,math.ceil((deliveryDeadline-now)/1000))
            text="DELIVER TO "..data.name.."  |  "..math.floor(remaining/60)..":"..string.format("%02d",remaining%60)
        end
        if isElement(data.blip) then
            if data.state=="delivery" then
                setBlipVisibleDistance(data.blip,math.floor(now/600)%2==0 and 16383 or 0)
            else
                setBlipColor(data.blip,255,40,40,math.floor(now/400)%2==0 and 255 or 60)
            end
        end
    elseif resultUntil>now then text=resultText
    elseif nearbyStart() then text="PRESS 'H' TO START THE DELIVERY" end
    if text then
        local w,h=guiGetScreenSize()
        dxDrawText(text,16,h*0.82,w-16,h*0.82+36,tocolor(127,255,212,255),
            math.min(1,(w-32)/dxGetTextWidth(text,1,"unifont")),"unifont","center","center")
    end
end)
