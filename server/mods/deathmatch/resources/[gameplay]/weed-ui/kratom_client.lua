-- LOCAL PERK EFFECTS; PURCHASE AND EXPIRY ARE SERVER OWNED
local revealed={}
local redUsed=false
local sprinting=false
local nextSprintReport=0

addEvent("kratom:reveal",true)
addEventHandler("kratom:reveal",resourceRoot,function(targets)
    revealed={}
    if getElementData(localPlayer,"kratom:perk")~="green" or type(targets)~="table" then return end
    local untilTick=getTickCount()+3000
    for _,ped in ipairs(targets) do
        if isElement(ped) then revealed[ped]=untilTick end
    end
end)

addEventHandler("onClientRender",root,function()
    local now=getTickCount()
    for ped,untilTick in pairs(revealed) do
        if now>=untilTick or not isElement(ped) or isPedDead(ped) or getElementData(localPlayer,"kratom:perk")~="green" then revealed[ped]=nil
        elseif isElementStreamedIn(ped) and getElementInterior(ped)==getElementInterior(localPlayer) and getElementDimension(ped)==getElementDimension(localPlayer) then
            local x,y,z=getElementPosition(ped)
            local sx,sy=getScreenFromWorldPosition(x,y,z+1.1)
            if sx then
                dxDrawRectangle(sx-5,sy-5,10,10,tocolor(127,255,0,220))
                dxDrawText("Z",sx-5,sy-16,sx+5,sy-5,tocolor(127,255,0,235),1,"default-bold","center","center")
            end
        end
    end
end)

addEventHandler("onClientPlayerDamage",localPlayer,function(attacker,weapon,bodypart,loss)
    if redUsed or wasEventCancelled() or getElementData(localPlayer,"kratom:perk")~="red" then return end
    if bodypart<3 or bodypart>8 or not loss or loss<getElementHealth(localPlayer) or weapon>46 or weapon<0 then return end
    if not isElement(attacker) or (getElementType(attacker)~="player" and getElementType(attacker)~="ped") then return end
    if getElementData(localPlayer,"freeroam.passive")==true then return end
    cancelEvent()
    redUsed=true
    triggerServerEvent("kratom:bodyHit",resourceRoot,attacker,weapon,bodypart,loss)
end,false,"low")

addEventHandler("onClientElementDataChange",localPlayer,function(key)
    if key=="kratom:perk" then redUsed=false revealed={} end
end)

local function stopSprint()
    if not sprinting then return end
    sprinting=false
    triggerServerEvent("kratom:sprint",resourceRoot,false)
    local block,animation=getPedAnimation(localPlayer)
    if block and animation and animation:lower()=="sprint_civi" then setPedAnimation(localPlayer,false) end
end

addEventHandler("onClientPreRender",root,function()
    local block,animation=getPedAnimation(localPlayer)
    local ownAnimation=block and animation and animation:lower()=="sprint_civi"
    local allowed=getElementData(localPlayer,"kratom:perk")=="white" and not isPedDead(localPlayer)
        and not isPedInVehicle(localPlayer) and not isElementFrozen(localPlayer) and isPedOnGround(localPlayer)
        and not isElementInWater(localPlayer) and not isCursorShowing() and not isChatBoxInputActive()
        and not isConsoleActive() and not isMainMenuActive() and not getPedControlState(localPlayer,"aim_weapon")
        and not getPedControlState(localPlayer,"fire") and not getPedControlState(localPlayer,"jump")
        and getPedControlState(localPlayer,"sprint") and getPedControlState(localPlayer,"forwards")
        and (not animation or ownAnimation)
    if not allowed then stopSprint() return end
    if not sprinting then
        sprinting=true
        setPedAnimation(localPlayer,"ped","sprint_civi",-1,true,true,false,false)
        nextSprintReport=0
    end
    if getTickCount()>=nextSprintReport then
        nextSprintReport=getTickCount()+1000
        triggerServerEvent("kratom:sprint",resourceRoot,true)
    end
    local x,y,_,tx,ty=getCameraMatrix()
    local angle=-math.deg(math.atan2(tx-x,ty-y))
    if getPedControlState(localPlayer,"left") then angle=angle+45
    elseif getPedControlState(localPlayer,"right") then angle=angle-45 end
    setElementRotation(localPlayer,0,0,angle,"ZYX",true)
end)

addEventHandler("onClientResourceStop",resourceRoot,stopSprint)
