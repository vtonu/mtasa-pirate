-- GREEN MARKER CATALOG; WEED STOCK AND PERKS STAY SEPARATE
local shops,active,requests={},{},{}
local packages={cart={price=2000,duration=300000}}
local varieties={
    {name="WHITE",symbol="W",type="white",description="SLOW MOVEMENT / DOUBLE HYBRID JUMP / WHITE NIGHT VISION / RED ZOMBIE SILHOUETTES.",white=100,green=0,purple=0},
    {name="GREEN",symbol="G",type="green",description="GREEN NIGHT VISION / ZOMBIE SILHOUETTES: 35 METERS, 3 SECONDS EVERY 15 SECONDS.",white=0,green=100,purple=0},
    {name="PURPLE",symbol="P",type="purple",description="10,000 HEALTH RESERVE / PURPLE IMPACT: POWER PUNCHES, MELEE AND KNOCKDOWN / FATAL HIT GUARDS / 5 MINUTES.",white=0,green=0,purple=100}
}
local byName={}
for _,variety in ipairs(varieties) do
    variety.prices={}
    for name,package in pairs(packages) do variety.prices[name]=package.price end
    byName[variety.name]=variety
end

local function nearShop(player)
    if not isElement(player) or isPedDead(player) or isPedInVehicle(player) then return false end
    local marker=getElementByID("specialShopWeedGarden")
    if not isElement(marker) or getElementData(marker,"specialShop:catalog")~="kratom" then return false end
    if getElementInterior(player)~=getElementInterior(marker) or getElementDimension(player)~=getElementDimension(marker) then return false end
    local x,y,z=getElementPosition(player)
    local mx,my,mz=getElementPosition(marker)
    return getDistanceBetweenPoints3D(x,y,z,mx,my,mz+1)<=1.25
end

local function preview(player)
    local perk=active[player]
    return {type=perk and perk.type or false,duration=perk and perk.duration or 0,
        remaining=perk and math.max(0,perk.expires-getTickCount()) or 0}
end

local function sendShop(player,note,reset)
    local durations={}
    for name,package in pairs(packages) do durations[name]=package.duration end
    triggerClientEvent(player,"kratom:openUI",resourceRoot,{shopMode="kratom",title="KRATOM SHOP",zone="SPECIAL PERKS",
        note=note or "SELECT A VARIETY.",resetSelection=reset==true,strains=varieties,actions={"BUY"},
        buySizes={},
        packageDurations=durations,perkPreview=preview(player)})
end


local function restoreGravity(player,base)
    if isPedInVehicle(player) then return 0.008 end
    local weed=getElementData(player,"weed.perk")
    return weed=="hybrid" and 0.003 or (weed=="indica" and 0.020 or base or 0.008)
end

function isKratomProtected(player)
    local perk=active[player]
    return perk and perk.type=="purple" and perk.expires>getTickCount() and not isPedDead(player) or false
end

function drainKratomReserve(player,loss)
    if not isKratomProtected(player) or type(loss)~="number" or loss~=loss or loss<=0 or loss==math.huge then return false end
    local perk=active[player]
    perk.reserve=math.max(100,(perk.reserve or 10000)-math.min(loss,1000))
    setElementHealth(player,perk.reserve/100)
    return true
end

addEvent("kratom:requestPerkClock",true)
addEventHandler("kratom:requestPerkClock",resourceRoot,function()
    if source==resourceRoot and client then triggerClientEvent(client,"kratom:perkClock",resourceRoot,preview(client)) end
end)

local function clearPerk(player,note)
    local perk=active[player]
    if not perk then return end
    active[player]=nil
    if isTimer(perk.timer) then killTimer(perk.timer) end
    if isElement(player) then
        if perk.type=="white" then setPedGravity(player,restoreGravity(player,perk.baseGravity)) end
        setElementData(player,"kratom:perk",false)
        triggerClientEvent(player,"kratom:perkClock",resourceRoot,preview(player))
        if note then triggerClientEvent(player,"weedGarden:notification",resourceRoot,note) end
    end
end

local function equip(player,variety,package)
    clearPerk(player)
    local perk={type=variety.type,duration=package.duration,expires=getTickCount()+package.duration,nextPulse=0,baseGravity=getElementData(player,"weed.perk") and 0.008 or getPedGravity(player)}
    active[player]=perk
    if perk.type=="white" then setPedGravity(player,isPedInVehicle(player) and 0.008 or 0.0015) end
    if perk.type=="purple" then perk.reserve=10000 setElementHealth(player,100) end
    setElementData(player,"kratom:perk",perk.type)
    triggerClientEvent(player,"kratom:perkClock",resourceRoot,preview(player))
    perk.timer=setTimer(function()
        if active[player]==perk then clearPerk(player,"KRATOM PERK ENDED.") end
    end,package.duration,1)
end

addEvent("kratom:requestOpen",true)
addEventHandler("kratom:requestOpen",resourceRoot,function()
    if source~=resourceRoot or not nearShop(client) then return end
    local now=getTickCount()
    if now<(requests[client] or 0) then return end
    requests[client]=now+500
    shops[client]={}
    sendShop(client,nil,true)
end)

addEvent("kratom:uiAction",true)
addEventHandler("kratom:uiAction",resourceRoot,function(action)
    if source~=resourceRoot or not client or not shops[client] or type(action)~="string" or #action>40 then return end
    if not nearShop(client) then
        shops[client]=nil
        triggerClientEvent(client,"kratom:closeUI",resourceRoot)
        return
    end
    local state=shops[client]
    local name=action:match("^strain:(.+)$")

    if name and byName[name] then state.variety=name
    elseif action=="BUY" then
        local variety,package=byName[state.variety],packages.cart
        if not variety then sendShop(client,"SELECT A VARIETY.") return end
        if getPlayerMoney(client)<package.price then sendShop(client,"SORRY, INSUFFICIENT FUNDS.") return end
        if not takePlayerMoney(client,package.price) then return end
        equip(client,variety,package)
        shops[client]={}
        sendShop(client,"PURCHASE COMPLETE: "..variety.name.." KRATOM FOR $"..package.price..".",true)
    end
end)

addEvent("kratom:uiClosed",true)
addEventHandler("kratom:uiClosed",resourceRoot,function()
    if source==resourceRoot and client then shops[client]=nil end
end)

-- CLIENT CANCELS THE NATIVE HIT; SERVER OWNS THE ACTIVE PERK
addEvent("kratom:fatalHit",true)
addEventHandler("kratom:fatalHit",resourceRoot,function()
    if source~=resourceRoot or not client or not isKratomProtected(client) then return end
    drainKratomReserve(client,100)
end)

addEvent("kratom:damageHit",true)
addEventHandler("kratom:damageHit",resourceRoot,function(loss)
    if source~=resourceRoot or not client or not isKratomProtected(client) then return end
    local perk=active[client]
    local now=getTickCount()
    if now<(perk.nextDamage or 0) then return end
    perk.nextDamage=now+200
    drainKratomReserve(client,loss)
end)

-- DENY CLIENT CHANGES TO THE PERK FLAG
addEventHandler("onElementDataChange",root,function(key)
    if key=="kratom:perk" and client then
        local perk=active[source]
        setElementData(source,key,perk and perk.type or false)
    end
end)

setTimer(function()
    local now=getTickCount()
    for player,perk in pairs(active) do
        if not isElement(player) then active[player]=nil
        elseif isPedDead(player) or now>=perk.expires then clearPerk(player)
        else
            if perk.type=="white" then
                local gravity=isPedInVehicle(player) and 0.008 or 0.0015
                if getPedGravity(player)~=gravity then setPedGravity(player,gravity) end
            end
            if (perk.type=="green" or perk.type=="white") and now>=perk.nextPulse then
                perk.nextPulse=now+15000
                local zombies=getResourceFromName("new-zombies-zday")
                local targets={}
                if zombies and getResourceState(zombies)=="running" then
                    local x,y,z=getElementPosition(player)
                    for _,ped in ipairs(getElementsByType("ped",getResourceDynamicElementRoot(zombies))) do
                        if not isPedDead(ped) and getElementInterior(ped)==getElementInterior(player) and getElementDimension(ped)==getElementDimension(player) then
                            local px,py,pz=getElementPosition(ped)
                            if getDistanceBetweenPoints3D(x,y,z,px,py,pz)<=35 then targets[#targets+1]=ped end
                        end
                    end
                end
                triggerClientEvent(player,"kratom:reveal",resourceRoot,targets)
            end
        end
    end
    for player in pairs(shops) do
        if not nearShop(player) then
            shops[player]=nil
            if isElement(player) then triggerClientEvent(player,"kratom:closeUI",resourceRoot) end
        end
    end
end,250,0)

addEventHandler("onPlayerWasted",root,function() clearPerk(source) shops[source]=nil end)
addEventHandler("onPlayerQuit",root,function() clearPerk(source) shops[source]=nil requests[source]=nil end)
addEventHandler("onResourceStop",resourceRoot,function()
    for player in pairs(active) do clearPerk(player) end
end)
