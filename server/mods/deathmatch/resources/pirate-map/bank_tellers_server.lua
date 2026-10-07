-- BANK TELLERS
local tellers, pedTellers, sessions, aimReports, decay = {}, {}, {}, {}, {}
local nextRobbery={}
local successUntil={}
local pending={}
local bank={cooldown=0}

local function clearLoot(player,pay)
    local loot=pending[player]
    pending[player]=nil
    if not loot then return end
    if isElement(loot.bag) then destroyElement(loot.bag) end
    if isElement(player) then
        setElementData(player,"bank:pending",false)
        if pay and not isPedDead(player) then
            local reward=math.max(0,loot.total-loot.claimed)
            givePlayerMoney(player,reward)
            triggerClientEvent(player,"bank:cashout",resourceRoot,reward,loot.completed)
        end
    end
end
local guns = {[22]=true,[23]=true,[24]=true,[25]=true,[26]=true,[27]=true,[28]=true,
    [29]=true,[30]=true,[31]=true,[32]=true,[33]=true,[34]=true}
local payouts = {2500,5000,10000,20000,40000,80000}
local holdDelay, releaseDelay, payoutDelay, starDelay = 3000,5000,5000,45000
local cooldownDelay, resetDelay, decayDelay = 300000,1800000,10000

local function near(player, element, radius, visitor)
    if not isElement(player) or not isElement(element) or isPedDead(player)
        or getPedOccupiedVehicle(player) or (not visitor and getElementData(player,"freeroam.passive") == true) then return false end
    if getElementInterior(player) ~= getElementInterior(element)
        or getElementDimension(player) ~= getElementDimension(element) then return false end
    local x,y,z = getElementPosition(player)
    local ex,ey,ez = getElementPosition(element)
    return getDistanceBetweenPoints2D(x,y,ex,ey) <= radius and math.abs(z-ez) <= 2
end

local function aiming(player,teller,now)
    local report = aimReports[player]
    return near(player,teller.ped,6) and guns[getPedWeapon(player)] and getPedTotalAmmo(player)>0
        and report and report.ped==teller.ped and now-report.tick<=750
end

local function cash(teller,count)
    for index,item in ipairs(teller.cash or {}) do
        if isElement(item.element) then
            setElementAlpha(item.element,index<=count and item.alpha or 0)
        end
    end
end

local function publish(s)
    cash(s.teller,s.revealed or 0)
    setElementData(s.player,"bank:robbery",{state=s.maxed and "max" or (s.started and "robbery" or "hold"),
        total=s.total,stage=s.stage,payout=payouts[s.stage],teller=s.teller.ped})
end

local function animate(teller,state)
    if state=="hands" then
        local now=getTickCount()
        if not teller.reactionStarted then teller.reactionStarted=now end
        local elapsed=now-teller.reactionStarted
        state=elapsed<1800 and "cower" or (math.floor((elapsed-1800)/6000)%2==1 and "duck" or "hands")
    elseif state~="hands" then
        teller.reactionStarted=nil
    end
    if teller.animation==state then return end
    teller.animation=state
    if state=="hands" then
        setPedAnimation(teller.ped,"ped","handsup",-1,false,false,false,true)
    elseif state=="cower" then
        setPedAnimation(teller.ped,"ped","handscower",1800,false,false,false,false)
    elseif state=="duck" then
        setPedAnimation(teller.ped,"ped","DUCK_cower",-1,true,false,false,false)
    elseif state=="work" then
        setPedAnimation(teller.ped,"ped","IDLE_chat",-1,true,false,false,false)
    else setPedAnimation(teller.ped,false) end
    setElementRotation(teller.ped,0,0,teller.spawn.rotation)
end

local function finish(teller,now,completed)
    local s=teller.session
    if not s then return end
    if isElement(s.player) then
        if s.total>0 and not isPedDead(s.player) then
            local x,y,z=getElementPosition(s.player)
            local bag=createObject(1550,x,y,z)
            if isElement(bag) then
                setElementParent(bag,resourceRoot)
                setObjectScale(bag,0.45)
                setElementFrozen(bag,true)
                setElementCollisionsEnabled(bag,false)
                setElementInterior(bag,getElementInterior(s.player))
                setElementDimension(bag,getElementDimension(s.player))
                setElementData(bag,"bank:bagOwner",s.player)
            end
            local claimed=getBankBountyClaimed and getBankBountyClaimed(s.player) or 0
            pending[s.player]={total=s.total,claimed=claimed,bag=bag,completed=completed==true and s.maxed==true}
            setElementData(s.player,"bank:pending",{total=s.total,claimed=claimed})
        end
        setElementData(s.player,"bank:robbery",false)
        if s.started and not isPedDead(s.player) then
            decay[s.player]={nextDrop=now+decayDelay,expected=getPlayerWantedLevel(s.player),health=getElementHealth(s.player)}
            setElementData(s.player,"bank:wantedDecay",{remaining=decayDelay})
        end
    end
    sessions[s.player]=nil
    if completed and s.maxed and isElement(s.player) and not isPedDead(s.player) then
        nextRobbery[s.player]=now+resetDelay
        successUntil[getPlayerSerial(s.player)]=now+resetDelay
        setElementData(s.player,"bank:robberyCooldown",math.ceil(resetDelay/1000))
    end
    if s.started then bank.cooldown=now+(completed and resetDelay or cooldownDelay) end
    if bank.session==s then bank.session=nil end
    teller.session=nil
    cash(teller,0)
    teller.reactionStarted=nil
    if isElement(teller.ped) then
        setElementData(teller.ped,"bank:killable",false)
        setElementData(teller.ped,"bank:robber",false)
    end
end

local function setupPed(teller,ped)
    teller.ped,teller.animation=ped,nil
    pedTellers[ped]=teller
    setElementFrozen(ped,true)
    setElementRotation(ped,0,0,teller.spawn.rotation)
    setElementData(ped,"bank:teller",true)
    setElementData(ped,"bank:requiresKill",teller.requiresKill)
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
    setElementData(teller.marker,"bank:dead",false)
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
            local teller={marker=marker,requiresKill=index==2,spawn={id=layout[1],model=getElementModel(ped),
                x=x,y=y,z=z,rotation=rotation,interior=getElementInterior(ped),
                dimension=getElementDimension(ped),health=getElementHealth(ped),armor=getPedArmor(ped)}}
            tellers[#tellers+1]=teller
            teller.cash={}
            local prefix="bankCash"..index
            for _,object in ipairs(getElementsByType("object",resourceRoot)) do
                local id=getElementID(object) or ""
                if id==prefix or id:sub(1,#prefix+1)==prefix.."_" then
                    teller.cash[#teller.cash+1]={element=object,alpha=getElementAlpha(object),id=id}
                    setElementCollisionsEnabled(object,false)
                end
            end
            table.sort(teller.cash,function(a,b) return a.id<b.id end)
            cash(teller,0)
            setupPed(teller,ped)
            setElementData(marker,"bank:robberyMarker",true)
            setElementData(marker,"bank:cooldown",0)
            setElementData(marker,"bank:dead",false)
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
    setPedAnimation(source,false)
    setElementFrozen(source,false)
    local s,now=teller.session,getTickCount()
    if s and s.maxed and killer==s.player and near(killer,teller.marker,1.6) then
        finish(teller,now,true)
        teller.deadUntil=now+resetDelay
    else
        finish(teller,now,true)
        teller.deadUntil=now+resetDelay
        bank.cooldown=teller.deadUntil
    end
    setElementData(teller.marker,"bank:dead",true)
end)

-- ONLY THE ROBBER'S FINAL HEADSHOT CAN FINISH THE OPEN COUNTER
addEvent("bank:headshot",true)
addEventHandler("bank:headshot",resourceRoot,function(ped,weapon)
    if not client or source~=resourceRoot then return end
    local teller=pedTellers[ped]
    local s=teller and teller.session
    if not s or not s.maxed or not teller.requiresKill or s.player~=client
        or isPedDead(ped) or not near(client,teller.marker,1.6)
        or not guns[weapon] or getPedWeapon(client)~=weapon then return end
    setPedAnimation(ped,false)
    setElementFrozen(ped,false)
    killPed(ped,client,weapon,9)
end)

-- SERVER MONEY, STAGES AND COOLDOWNS
setTimer(function()
    local now,players=getTickCount(),getElementsByType("player")
    for _,teller in ipairs(tellers) do
        if teller.deadUntil and now>=teller.deadUntil then restorePed(teller) end
        if isElement(teller.ped) and not isPedDead(teller.ped) and not teller.deadUntil then
            local threatened,visitor=false,false
            for _,player in ipairs(players) do
                if near(player,teller.marker,1.6,true) then visitor=player end
                if aiming(player,teller,now) then
                    threatened=true
                    if not bank.session and now>=bank.cooldown and now>=(nextRobbery[player] or 0) and not sessions[player] and not pending[player]
                        and near(player,teller.marker,1.6) then
                        local s={player=player,teller=teller,held=0,activeTime=0,paidTime=0,
                            total=0,stage=1,lastTick=now,lastAim=now}
                        teller.session,sessions[player]=s,teller
                        bank.session=s
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
                            s.revealed=(s.revealed or 0)+1
                            publish(s)
                        end
                        if s.stage==6 then
                            s.maxed=true
                            if teller.requiresKill then
                                setElementData(teller.ped,"bank:killable",true)
                                publish(s)
                            else finish(teller,now,true) end
                        end
                    end
                else
                    if not s.started then s.held=0 end
                    if now-s.lastAim>=releaseDelay then finish(teller,now) end
                end
            end
            animate(teller,threatened and "hands" or (teller.session and "hands" or (visitor and "work" or "idle")))
            local facing=teller.session and teller.session.player or visitor
            if teller.requiresKill and facing and near(facing,teller.marker,1.6,true) then
                local x,y=getElementPosition(teller.ped)
                local px,py=getElementPosition(facing)
                setElementRotation(teller.ped,0,0,(-math.deg(math.atan2(px-x,py-y)))%360)
            end
        end
    end
    local remaining=math.max(0,math.ceil((bank.cooldown-now)/1000))
    local robber=bank.session and bank.session.player or false
    local alarm=bank.session and bank.session.started==true or false
    if getElementData(resourceRoot,"bank:alarm")~=alarm then setElementData(resourceRoot,"bank:alarm",alarm) end
    for _,teller in ipairs(tellers) do
        if getElementData(teller.marker,"bank:cooldown")~=remaining then
            setElementData(teller.marker,"bank:cooldown",remaining)
        end
        if getElementData(teller.marker,"bank:robber")~=robber then
            setElementData(teller.marker,"bank:robber",robber)
        end
    end
    for player,d in pairs(decay) do
        if not isElement(player) or isPedDead(player) then
            decay[player]=nil
            if isElement(player) then setElementData(player,"bank:wantedDecay",false) end
        else
            local stars=getPlayerWantedLevel(player)
            local health=getElementHealth(player)
            if health<d.health then d.nextDrop=now+decayDelay end
            d.health=health
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
    for player,loot in pairs(pending) do
        if not isElement(player) or isPedDead(player) then clearLoot(player,false)
        elseif getPlayerWantedLevel(player)==0 then
            loot.claimed=getBankBountyClaimed and getBankBountyClaimed(player) or loot.claimed
            clearLoot(player,true)
        elseif isElement(loot.bag) then
            local x,y,z=getElementPosition(player)
            setElementPosition(loot.bag,x,y,z)
            setElementInterior(loot.bag,getElementInterior(player))
            setElementDimension(loot.bag,getElementDimension(player))
        end
    end
    for player,endsAt in pairs(nextRobbery) do
        if isElement(player) then
            local seconds=math.max(0,math.ceil((endsAt-now)/1000))
            if getElementData(player,"bank:robberyCooldown")~=seconds then
                setElementData(player,"bank:robberyCooldown",seconds)
            end
            if seconds==0 then nextRobbery[player]=nil end
        else nextRobbery[player]=nil end
    end
    for serial,endsAt in pairs(successUntil) do
        if endsAt<=now then successUntil[serial]=nil end
    end
end,250,0)

addEventHandler("onPlayerJoin",root,function()
    local endsAt=successUntil[getPlayerSerial(source)]
    if endsAt and endsAt>getTickCount() then
        nextRobbery[source]=endsAt
        setElementData(source,"bank:robberyCooldown",math.ceil((endsAt-getTickCount())/1000))
    end
end)

addEventHandler("onPlayerWeaponFire",root,function()
    local escape=decay[source]
    if escape then escape.nextDrop=getTickCount()+decayDelay end
end)

addEventHandler("onPlayerDamage",root,function()
    local escape=decay[source]
    if escape then escape.nextDrop=getTickCount()+decayDelay end
end)

local function clearPlayer()
    local teller=sessions[source]
    if teller then finish(teller,getTickCount()) end
    clearLoot(source,false)
    aimReports[source],decay[source]=nil,nil
    if isElement(source) then
        setElementData(source,"bank:wantedDecay",false)
        setElementData(source,"bank:robbery",false)
        setPlayerWantedLevel(source,0)
    end
end
addEventHandler("onPlayerQuit",root,clearPlayer)
addEventHandler("onPlayerWasted",root,clearPlayer)
addEventHandler("onPlayerSpawn",root,clearPlayer)

addEventHandler("onResourceStop",resourceRoot,function()
    setElementData(resourceRoot,"bank:alarm",false)
    for _,teller in ipairs(tellers) do
        finish(teller,getTickCount())
        if isElement(teller.marker) then
            removeElementData(teller.marker,"bank:robberyMarker")
            removeElementData(teller.marker,"bank:teller")
            removeElementData(teller.marker,"bank:cooldown")
            removeElementData(teller.marker,"bank:dead")
            removeElementData(teller.marker,"bank:robber")
        end
        if isElement(teller.ped) then setPedAnimation(teller.ped,false) end
        for _,item in ipairs(teller.cash or {}) do
            if isElement(item.element) then setElementAlpha(item.element,item.alpha) end
        end
    end
    for player in pairs(decay) do
        if isElement(player) then setElementData(player,"bank:wantedDecay",false) end
    end
    for player in pairs(nextRobbery) do
        if isElement(player) then setElementData(player,"bank:robberyCooldown",false) end
    end
    for player in pairs(pending) do clearLoot(player,false) end
end)
