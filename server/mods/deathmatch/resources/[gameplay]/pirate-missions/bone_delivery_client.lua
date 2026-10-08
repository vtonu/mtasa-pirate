-- TEXT ONLY DELIVERY PROMPTS
local resultText,resultUntil=nil,0
local pickupMarker,pickupZ
local deliveryDeadline
local cargoObjects={}
local cargoVisible={}
local cargoIds={"securiVehicleBCMissionCrate1","securiVehicleBCMissionCrate2","securiVehicleBCMissionCrate3"}

-- LOCAL CARGO KEEPS EACH PLAYER'S LOAD SEPARATE
local function updateCargo(data)
    local count=type(data)=="table" and (data.collected or 0) or 0
    local show=type(data)=="table" and (data.state=="collect" or data.state=="cargo" or data.state=="loading")
    for index,id in ipairs(cargoIds) do
        local visible=show and index<=count
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
        if data.state=="collect" and not data.taking and isElement(data.marker) then
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

local takingDeadline
addEventHandler("onClientElementDataChange",localPlayer,function(key)
    if key~="bone:delivery" then return end
    local data=getElementData(localPlayer,key)
    updateCargo(data)
    takingDeadline=type(data)=="table" and data.taking
        and getTickCount()+(data.takingRemaining or 2000) or nil
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
            text=(data.taking and "TAKING OUT THE CARGO | " or "PRESS 'H' AT THE SHED TO TAKE OUT THE CARGO | ")
                ..(data.collected or 0).." / 3"
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
            text=isElement(getElementData(resourceRoot,"bone:pickupArrow"))
                and "PRESS 'H' BEHIND THE SECURICAR TO LOAD THE CARGO" or "WAIT FOR THE NEXT SECURICAR"
        elseif data.state=="vehicle" then
            text=isElement(data.vehicle) and "ENTER THE SECURICAR" or "WAIT FOR THE NEXT SECURICAR"
        elseif data.state=="delivery" then
            if not deliveryDeadline then deliveryDeadline=now+(data.remaining or 300000) end
            local remaining=math.max(0,math.ceil((deliveryDeadline-now)/1000))
            text="DELIVER TO "..data.name.."  |  "..math.floor(remaining/60)..":"..string.format("%02d",remaining%60)
        end
        emmetBlinkMissionBlip(data.blip,now)
    elseif resultUntil>now then text=resultText
    elseif nearbyStart() then text="PRESS 'H' TO START THE DELIVERY" end
    if text then
        local w,h=guiGetScreenSize()
        local loading=type(data)=="table" and data.taking
        local extra=loading and 48 or 0
        local scale=math.min(1,(w-32-extra)/dxGetTextWidth(text,1,"unifont"))
        local textWidth=dxGetTextWidth(text,scale,"unifont")
        local left,top=(w-textWidth-extra)/2,h*0.82
        dxDrawText(text,left,top,left+textWidth,top+36,tocolor(127,255,212,255),
            scale,"unifont","center","center")
        if loading then
            if not takingDeadline then takingDeadline=now+(data.takingRemaining or 2000) end
            local progress=math.max(0,math.min(1,1-(takingDeadline-now)/2000))
            for i=1,3 do
                local x=left+textWidth+12+(i-1)*12
                dxDrawRectangle(x,top+15,9,6,tocolor(127,255,212,45))
                local fill=math.max(0,math.min(1,progress*3-(i-1)))
                if fill>0 then dxDrawRectangle(x,top+15,9*fill,6,tocolor(127,255,212,255)) end
            end
        else takingDeadline=nil end
    end
end)
