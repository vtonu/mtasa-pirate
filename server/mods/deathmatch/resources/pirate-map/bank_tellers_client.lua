-- BANK AIM AND STATUS
local markerIds = {"bankMissionPalominoCreek","bankOfficeMissionPalominoCreek"}
local lastReport, reportedPed = 0, false
local hiddenWanted, previousWanted = false, true
local lastWanted=getPlayerWantedLevel()
local gainedStars={}
local payoutProgress={paid=0,delay=5000,tick=0,aiming=false}
addEvent("bank:payoutProgress",true)
addEventHandler("bank:payoutProgress",resourceRoot,function(paid,delay,aiming)
    payoutProgress={paid=paid,delay=delay,tick=getTickCount(),aiming=aiming}
end)
local alarmSound
local nextAlarmAttempt=0
local star = svgCreate(64,64,[[<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><path d="M32 3 L39 23 L61 23 L43 36 L50 58 L32 45 L14 58 L21 36 L3 23 L25 23 Z" fill="white" stroke="black" stroke-width="3"/></svg>]])

local function aimedTeller()
    if isPedDead(localPlayer) or getPedOccupiedVehicle(localPlayer)
        or getElementData(localPlayer,"freeroam.passive")==true or isCursorShowing()
        or isChatBoxInputActive() or isConsoleActive() or isMainMenuActive()
        or not getPedControlState(localPlayer,"aim_weapon") then return false end
    local target=getPedTarget(localPlayer)
    if isElement(target) and getElementData(target,"bank:teller")==true and not isPedDead(target) then
        return target
    end
    -- ONLY THIS COUNTER CAN USE THE AIM RAY THROUGH ITS GLASS
    local px,py,pz=getElementPosition(localPlayer)
    local sx,sy,sz=getPedTargetStart(localPlayer)
    local ex,ey,ez=getPedTargetEnd(localPlayer)
    if not sx or not ex then return false end
    local dx,dy,dz=ex-sx,ey-sy,ez-sz
    local length=dx*dx+dy*dy+dz*dz
    if length<0.001 then return false end
    for _,id in ipairs(markerIds) do
        local marker=getElementByID(id)
        if isElement(marker) and getElementInterior(marker)==getElementInterior(localPlayer)
            and getElementDimension(marker)==getElementDimension(localPlayer) then
            local mx,my,mz=getElementPosition(marker)
            local ped=getElementData(marker,"bank:teller")
            if getDistanceBetweenPoints2D(px,py,mx,my)<=1.6 and math.abs(pz-mz)<=2
                and isElement(ped) and not isPedDead(ped) then
                local x,y,z=getElementPosition(ped)
                -- KEEP AIM DETECTION THROUGH THE TELLER'S HANDS-UP AND CROUCH POSES
                z=z+0.35
                local t=((x-sx)*dx+(y-sy)*dy+(z-sz)*dz)/length
                if t>0 and getDistanceBetweenPoints2D(px,py,x,y)<=6
                    and (x-sx-t*dx)^2+(y-sy-t*dy)^2+(z-sz-t*dz)^2<=1.1^2 then
                    return ped
                end
            end
        end
    end
    return false
end

local function nearbyMarker()
    local x,y,z=getElementPosition(localPlayer)
    for _,id in ipairs(markerIds) do
        local marker=getElementByID(id)
        if isElement(marker) and getElementInterior(marker)==getElementInterior(localPlayer)
            and getElementDimension(marker)==getElementDimension(localPlayer) then
            local mx,my,mz=getElementPosition(marker)
            if getDistanceBetweenPoints2D(x,y,mx,my)<=1.6 and math.abs(z-mz)<=2 then return marker end
        end
    end
end

-- KEEP THE ROBBERY ALARM AT THE BANK
local function updateAlarm()
    local marker=getElementByID(markerIds[1])
    local nearby=false
    if getElementData(resourceRoot,"bank:alarm")==true and isElement(marker)
        and getElementInterior(marker)==getElementInterior(localPlayer)
        and getElementDimension(marker)==getElementDimension(localPlayer) then
        local x,y,z=getElementPosition(localPlayer)
        local mx,my,mz=getElementPosition(marker)
        nearby=getDistanceBetweenPoints3D(x,y,z,mx,my,mz)<=45
    end
    if not nearby then
        if isElement(alarmSound) then destroyElement(alarmSound) end
        alarmSound=nil
    elseif not isElement(alarmSound) and getTickCount()>=nextAlarmAttempt then
        nextAlarmAttempt=getTickCount()+10000
        local x,y,z=getElementPosition(marker)
        alarmSound=playSFX3D("script",36,0,x,y,z,true)
        if isElement(alarmSound) then
            setElementParent(alarmSound,resourceRoot)
            setElementInterior(alarmSound,getElementInterior(marker))
            setElementDimension(alarmSound,getElementDimension(marker))
            setSoundVolume(alarmSound,0.4)
            setSoundMinDistance(alarmSound,5)
            setSoundMaxDistance(alarmSound,35)
        end
    end
end
setTimer(updateAlarm,250,0)

addEventHandler("onClientPedWasted",root,function()
    if getElementData(source,"bank:teller")~=true or not isElementStreamedIn(source)
        or getElementInterior(source)~=getElementInterior(localPlayer)
        or getElementDimension(source)~=getElementDimension(localPlayer) then return end
    setPedAnimation(source,false)
    local x,y,z=getPedBonePosition(source,6)
    if not x then x,y,z=getElementPosition(source) end
    fxAddBlood(x,y,z,0,0,-1,12,1)
end)

addEventHandler("onClientPreRender",root,function()
    local ped,now=aimedTeller(),getTickCount()
    if now-lastReport>=250 and (ped or reportedPed) then
        triggerServerEvent("bank:aim",resourceRoot,ped)
        lastReport,reportedPed=now,ped
    end
end)

-- TELLERS CAN ONLY BE KILLED BY THEIR ROBBER AT THE FINAL STAGE
addEventHandler("onClientPedDamage",root,function(attacker,weapon,bodypart)
    if getElementData(source,"bank:teller")~=true then return end
    if getElementData(source,"bank:killable")~=true
        or attacker~=getElementData(source,"bank:robber") then cancelEvent()
    elseif bodypart==9 and attacker==localPlayer and getElementData(source,"bank:requiresKill")==true then
        cancelEvent()
        triggerServerEvent("bank:headshot",resourceRoot,source,weapon)
    end
end)

addEventHandler("onClientRender",root,function()
    local w,h=guiGetScreenSize()
    local ped,marker=aimedTeller(),nearbyMarker()
    local dead=marker and getElementData(marker,"bank:dead")==true
    if marker and (dead or (ped and getElementData(marker,"bank:teller")==ped)) then
        local session=getElementData(localPlayer,"bank:robbery")
        local cooldown=tonumber(getElementData(marker,"bank:cooldown")) or 0
        local playerCooldown=tonumber(getElementData(localPlayer,"bank:robberyCooldown")) or 0
        local robber=getElementData(marker,"bank:robber")
        local text="KEEP AIMING TO START ROBBERY"
        if dead then
            text="SORRY, THE ZOMBIES GOT HIM. COME TRY LATER."
        elseif playerCooldown>0 then
            text="YOUR NEXT ROBBERY IS IN "..math.ceil(playerCooldown/60).." MIN"
        elseif cooldown>0 then
            text="BANK RESETS IN "..math.ceil(cooldown/60).." MIN"
        elseif robber and robber~=localPlayer then
            text="TELLER IS BEING ROBBED"
        elseif type(session)=="table" and session.teller==ped then
            if session.state=="max" then text="MAX STARS - KILL THE TELLER TO FINISH"
            elseif session.state=="robbery" then
                text="KEEP AIMING | PENDING CASH: $"..tostring(session.total)
                    .."  |  +$"..tostring(session.payout).." / 5 SEC"
            end
        elseif robber==localPlayer then text="ROBBERY IN PROGRESS AT THE OTHER COUNTER"
        end
        local width=math.min(620,w-32)
        local left,top=(w-width)/2,h*0.78
        local loading=type(session)=="table" and session.state=="robbery" and session.teller==ped
        local extra=loading and 48 or 0
        local scale=math.min(1,(width-24-extra)/dxGetTextWidth(text,1,"unifont"))
        local textWidth=dxGetTextWidth(text,scale,"unifont")
        local textLeft=(w-textWidth-extra)/2
        dxDrawText(text,textLeft,top,textLeft+textWidth,top+46,
            tocolor(127,255,212,255),scale,"unifont","center","center")
        if loading then
            local clock=payoutProgress
            local elapsed=clock.aiming and math.min(500,getTickCount()-clock.tick) or 0
            local progress=math.min(1,(clock.paid+elapsed)/clock.delay)
            for i=1,3 do
                local x=textLeft+textWidth+12+(i-1)*12
                dxDrawRectangle(x,top+20,9,6,tocolor(127,255,212,45))
                local fill=math.max(0,math.min(1,progress*3-(i-1)))
                if fill>0 then dxDrawRectangle(x,top+20,9*fill,6,tocolor(127,255,212,255)) end
            end
        end
    end
    local escape=getElementData(localPlayer,"bank:wantedDecay")
    local count,now=getPlayerWantedLevel(),getTickCount()
    local robbery=getElementData(localPlayer,"bank:robbery")
    local building=type(robbery)=="table" and robbery.state=="robbery" and count<6
    if count>lastWanted then
        for level=lastWanted+1,count do gainedStars[level]=now+2400 end
    elseif count<lastWanted then
        for level=count+1,6 do gainedStars[level]=nil end
    end
    lastWanted=count
    if star and getPlayerWantedLevel()>0 then
        if not hiddenWanted then
            previousWanted=isPlayerHudComponentVisible("wanted")
            setPlayerHudComponentVisible("wanted",false)
            hiddenWanted=true
        end
        if previousWanted then
            local blink=type(escape)=="table" and math.floor(getTickCount()/400)%2==0
            local size=math.max(18,math.min(36,h*0.042))
            local rowWidth=w*0.17
            local gap=(rowWidth-size*6)/5
            for i=1,6 do
                local level=7-i
                local rising=building or (type(robbery)~="table" and gainedStars[level] and now<gainedStars[level])
                local gained=rising and math.floor(now/400)%2==0
                local lit=i>6-count and not blink and not gained
                dxDrawImage(w*0.78+(i-1)*(size+gap),h*0.23,size,size,star,0,0,0,
                    lit and tocolor(224,171,53,255) or tocolor(55,55,55,220))
            end
        end
    elseif hiddenWanted then
        setPlayerHudComponentVisible("wanted",previousWanted)
        hiddenWanted=false
    end
end)

addEventHandler("onClientResourceStop",resourceRoot,function()
    if isElement(alarmSound) then destroyElement(alarmSound) end
    if hiddenWanted then setPlayerHudComponentVisible("wanted",previousWanted) end
end)
