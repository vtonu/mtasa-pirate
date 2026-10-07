-- BANK AIM AND STATUS
local markerIds = {"bankMissionPalominoCreek","bankOfficeMissionPalominoCreek"}
local lastReport, reportedPed = 0, false
local hiddenWanted, previousWanted = false, true
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
                z=z+0.65
                local t=((x-sx)*dx+(y-sy)*dy+(z-sz)*dz)/length
                if t>0 and getDistanceBetweenPoints2D(px,py,x,y)<=6
                    and (x-sx-t*dx)^2+(y-sy-t*dy)^2+(z-sz-t*dz)^2<=0.65^2 then
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
        local robber=ped and getElementData(ped,"bank:robber")
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
        end
        local width=math.min(620,w-32)
        local left,top=(w-width)/2,h*0.78
        local scale=math.min(1,(width-24)/dxGetTextWidth(text,1,"unifont"))
        dxDrawText(text,left+12,top,left+width-12,top+46,
            tocolor(127,255,212,255),scale,"unifont","center","center")
    end
    local escape=getElementData(localPlayer,"bank:wantedDecay")
    if star and getPlayerWantedLevel()>0 then
        if not hiddenWanted then
            previousWanted=isPlayerHudComponentVisible("wanted")
            setPlayerHudComponentVisible("wanted",false)
            hiddenWanted=true
        end
        if previousWanted then
            local count=getPlayerWantedLevel()
            local blink=type(escape)=="table" and escape.remaining<=10000 and math.floor(getTickCount()/400)%2==0
            local size=math.max(18,math.min(36,h*0.042))
            for i=1,6 do
                local lit=i>6-count and not blink
                dxDrawImage(w*0.78+(i-1)*size,h*0.23,size,size,star,0,0,0,
                    lit and tocolor(224,171,53,255) or tocolor(55,55,55,220))
            end
        end
    elseif hiddenWanted then
        setPlayerHudComponentVisible("wanted",previousWanted)
        hiddenWanted=false
    end
end)

addEventHandler("onClientResourceStop",resourceRoot,function()
    if hiddenWanted then setPlayerHudComponentVisible("wanted",previousWanted) end
end)
