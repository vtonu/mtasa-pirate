-- BANK TELLERS
local tellers, pedTellers, sessions, aimReports, decay = {}, {}, {}, {}, {}
local guns = {[22]=true,[23]=true,[24]=true,[25]=true,[26]=true,[27]=true,[28]=true,
    [29]=true,[30]=true,[31]=true,[32]=true,[33]=true,[34]=true}
local payouts = {1000,2500,5000,10000,20000,40000}
local holdDelay, releaseDelay, payoutDelay, starDelay = 3000,5000,5000,45000
local cooldownDelay, resetDelay, decayDelay = 300000,1800000,30000

local function near(player, element, radius)
    if not isElement(player) or not isElement(element) or isPedDead(player)
        or getPedOccupiedVehicle(player) or getElementData(player,"freeroam.passive") == true then return false end
    if getElementInterior(player) ~= getElementInterior(element)
        or getElementDimension(player) ~= getElementDimension(element) then return false end
    local x,y,z = getElementPosition(player)
    local ex,ey,ez = getElementPosition(element)
    return getDistanceBetweenPoints2D(x,y,ex,ey) <= radius and math.abs(z-ez) <= 2
end

local function aiming(player,teller,now)
    local report = aimReports[player]
    local target = isElement(player) and getPedTarget(player)
    return near(player,teller.ped,6) and guns[getPedWeapon(player)] and getPedTotalAmmo(player)>0
        and (not target or target==teller.ped)
        and report and report.ped==teller.ped and now-report.tick<=750
end

local function publish(s)
    setElementData(s.player,"bank:robbery",{state=s.maxed and "max" or (s.started and "robbery" or "hold"),
        total=s.total,stage=s.stage,payout=payouts[s.stage],teller=s.teller.ped})
end

local function animate(teller,state)
    if teller.animation==state then return end
    teller.animation=state
    if state=="hands" then
        setPedAnimation(teller.ped,"ped","handsup",-1,false,false,false,true)
    elseif state=="work" then
        setPedAnimation(teller.ped,"INT_SHOP","shop_cashier",-1,true,false,false,false)
    else setPedAnimation(teller.ped,false) end
end

local function finish(teller,now,completed)
    local s=teller.session
    if not s then return end
    if isElement(s.player) then
        setElementData(s.player,"bank:robbery",false)
        if s.started and not isPedDead(s.player) then
            decay[s.player]={nextDrop=now+decayDelay,expected=getPlayerWantedLevel(s.player)}
            setElementData(s.player,"bank:wantedDecay",{remaining=decayDelay})
        end
    end
    sessions[s.player]=nil
    if s.started then teller.cooldown=now+(completed and resetDelay or cooldownDelay) end
    teller.session=nil
    if isElement(teller.ped) then
        setElementData(teller.ped,"bank:killable",false)
        setElementData(teller.ped,"bank:robber",false)
    end
end

local function setupPed(teller,ped)
    teller.ped,teller.animation=ped,nil
    pedTellers[ped]=teller
    setElementFrozen(ped,true)
    setElementData(ped,"bank:teller",true)
    setElementData(ped,"bank:killable",false)
    setElementData(ped,"bank:robber",teller.session and teller.session.player or false)
    setElementData(teller.marker,"bank:teller",ped)
end

local function restorePed(teller)
    local old,s=teller.ped,teller.spawn
    local ped=createPed(s.model,s.x,s.y,s.z,s.rotation)
    if not isElement(ped) then return end
    setElementParent(ped,resourceRoot)
    setElementInterior(ped,s.interior)
    setElementDimension(ped,s.dimension)
    setElementHealth(ped,s.health)
    setPedArmor(ped,s.armor)
    pedTellers[old]=nil
    if isElement(old) then destroyElement(old) end
    setElementID(ped,s.id)
    setupPed(teller,ped)
    teller.deadUntil=nil
    if teller.session then
        setElementData(ped,"bank:killable",teller.session.maxed==true)
        publish(teller.session)
    end
end

-- AIM HEARTBEATS; THE SERVER STILL CHECKS CIRCLE, GUN, AMMO AND OWNER
addEvent("bank:aim",true)
addEventHandler("bank:aim",resourceRoot,function(ped)
    if not client or source~=resourceRoot then return end
    local now,previous=getTickCount(),aimReports[client]
    if previous and now-previous.tick<100 then return end
    local teller=pedTellers[ped]
    if teller and near(client,teller.ped,6) and guns[getPedWeapon(client)] and getPedTotalAmmo(client)>0 then
        aimReports[client]={ped=ped,tick=now}
    else aimReports[client]={ped=false,tick=now} end
end)

addEventHandler("onResourceStart",resourceRoot,function()
    for index,layout in ipairs({{"bankTeller1","bankMissionPalominoCreek"},
        {"bankTeller2","bankOfficeMissionPalominoCreek"}}) do
        local ped,marker=getElementByID(layout[1]),getElementByID(layout[2])
        if isElement(ped) and isElement(marker) then
            local x,y,z=getElementPosition(ped)
            local _,_,rotation=getElementRotation(ped)
            local teller={marker=marker,cooldown=0,spawn={id=layout[1],model=getElementModel(ped),
                x=x,y=y,z=z,rotation=rotation,interior=getElementInterior(ped),
                dimension=getElementDimension(ped),health=getElementHealth(ped),armor=getPedArmor(ped)}}
            tellers[#tellers+1]=teller
            setupPed(teller,ped)
            setElementData(marker,"bank:robberyMarker",true)
            setElementData(marker,"bank:cooldown",0)
            if index==1 then
                local blip=createBlipAttachedTo(marker,52,2,255,255,255,255,0,65535)
                if isElement(blip) then
                    setElementID(blip,"bankPalominoCreek")
                    setElementInterior(blip,getElementInterior(marker))
                    setElementDimension(blip,getElementDimension(marker))
                end
            end
        else outputDebugString("BANK TELLER OR MARKER MISSING: "..layout[1],1) end
    end
end)

addEventHandler("onPedWasted",root,function(_,killer)
    local teller=pedTellers[source]
    if not teller then return end
    local s,now=teller.session,getTickCount()
    if s and s.maxed and killer==s.player and near(killer,teller.marker,1.6) then
        finish(teller,now,true)
        teller.deadUntil=now+resetDelay
    else
        -- REPLACE EARLY OR UNAUTHORIZED DEATHS WITHOUT A REWARD
        teller.deadUntil=now
    end
end)

-- SERVER MONEY, STAGES AND COOLDOWNS
setTimer(function()
    local now,players=getTickCount(),getElementsByType("player")
    for _,teller in ipairs(tellers) do
        if teller.deadUntil and now>=teller.deadUntil then restorePed(teller) end
        local remaining=math.max(0,math.ceil((teller.cooldown-now)/1000))
        if getElementData(teller.marker,"bank:cooldown")~=remaining then
            setElementData(teller.marker,"bank:cooldown",remaining)
        end
        if isElement(teller.ped) and not isPedDead(teller.ped) and not teller.deadUntil then
            local threatened,visitor=false,false
            for _,player in ipairs(players) do
                if near(player,teller.marker,1.6) then visitor=true end
                if aiming(player,teller,now) then
                    threatened=true
                    if not teller.session and now>=teller.cooldown and not sessions[player]
                        and near(player,teller.marker,1.6) then
                        local s={player=player,teller=teller,held=0,activeTime=0,paidTime=0,
                            total=0,stage=1,lastTick=now,lastAim=now}
                        teller.session,sessions[player]=s,teller
                        decay[player]=nil
                        setElementData(player,"bank:wantedDecay",false)
                        setElementData(teller.ped,"bank:robber",player)
                        publish(s)
                    end
                end
            end
            local s=teller.session
            if s then
                local player,elapsed=s.player,now-s.lastTick
                s.lastTick=now
                if not near(player,teller.marker,1.6) then finish(teller,now)
                elseif aiming(player,teller,now) then
                    s.lastAim=now
                    if not s.started then
                        s.held=s.held+elapsed
                        if s.held>=holdDelay then
                            s.started=true
                            setPlayerWantedLevel(player,math.min(6,getPlayerWantedLevel(player)+1))
                            publish(s)
                        end
                    elseif not s.maxed then
                        s.activeTime=s.activeTime+elapsed
                        s.paidTime=s.paidTime+elapsed
                        local stage=math.min(6,1+math.floor(s.activeTime/starDelay))
                        if stage>s.stage then
                            s.stage=stage
                            setPlayerWantedLevel(player,math.min(6,getPlayerWantedLevel(player)+1))
                        end
                        if s.paidTime>=payoutDelay then
                            s.paidTime=s.paidTime-payoutDelay
                            s.total=s.total+payouts[s.stage]
                            givePlayerMoney(player,payouts[s.stage])
                            publish(s)
                        end
                        if s.stage==6 then
                            s.maxed=true
                            setElementData(teller.ped,"bank:killable",true)
                            publish(s)
                        end
                    end
                else
                    if not s.started then s.held=0 end
                    if now-s.lastAim>=releaseDelay then finish(teller,now) end
                end
            end
            animate(teller,threatened and "hands" or (teller.session and "hands" or (visitor and "work" or "idle")))
        end
    end
    for player,d in pairs(decay) do
        if not isElement(player) or isPedDead(player) then
            decay[player]=nil
            if isElement(player) then setElementData(player,"bank:wantedDecay",false) end
        else
            local stars=getPlayerWantedLevel(player)
            -- LEAVE NEW WANTED STARS FROM OTHER SYSTEMS ALONE
            if stars>d.expected or stars==0 then
                decay[player]=nil
                setElementData(player,"bank:wantedDecay",false)
            else
                if now>=d.nextDrop then
                    stars=math.max(0,stars-1)
                    setPlayerWantedLevel(player,stars)
                    d.nextDrop=now+decayDelay
                end
                d.expected=stars
                setElementData(player,"bank:wantedDecay",stars>0 and {remaining=d.nextDrop-now} or false)
                if stars==0 then decay[player]=nil end
            end
        end
    end
end,250,0)

local function clearPlayer()
    local teller=sessions[source]
    if teller then finish(teller,getTickCount()) end
    aimReports[source],decay[source]=nil,nil
    if isElement(source) then setElementData(source,"bank:wantedDecay",false) end
end
addEventHandler("onPlayerQuit",root,clearPlayer)
addEventHandler("onPlayerWasted",root,clearPlayer)
addEventHandler("onPlayerSpawn",root,clearPlayer)

addEventHandler("onResourceStop",resourceRoot,function()
    for _,teller in ipairs(tellers) do
        finish(teller,getTickCount())
        if isElement(teller.marker) then
            removeElementData(teller.marker,"bank:robberyMarker")
            removeElementData(teller.marker,"bank:teller")
            removeElementData(teller.marker,"bank:cooldown")
        end
        if isElement(teller.ped) then setPedAnimation(teller.ped,false) end
    end
    for player in pairs(decay) do
        if isElement(player) then setElementData(player,"bank:wantedDecay",false) end
    end
end)
