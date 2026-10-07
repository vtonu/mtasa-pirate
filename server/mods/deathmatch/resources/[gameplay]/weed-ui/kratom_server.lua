-- GREEN MARKER CATALOG; WEED STOCK AND PERKS STAY SEPARATE
local shops,active,requests={},{},{}
local packages={cart={price=2000,duration=300000},eighth={price=4500,duration=600000},
    ounce={price=8000,duration=1200000},qp={price=12000,duration=1800000}}
local varieties={
    {name="WHITE",symbol="W",type="white",description="SPRINT WITHOUT STAMINA DRAIN.",white=100,green=0,red=0},
    {name="GREEN",symbol="G",type="green",description="REVEAL ZOMBIES WITHIN 35 METERS FOR 3 SECONDS EVERY 15 SECONDS.",white=0,green=100,red=0},
    {name="RED",symbol="R",type="red",description="SURVIVE ONE FATAL BODY HIT AT 1 HP. THE PERK THEN ENDS. HEADSHOTS ARE NOT COVERED.",white=0,green=0,red=100}
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
    triggerClientEvent(player,"kratom:openUI",resourceRoot,{shopMode="kratom",title="KRATOM",zone="SPECIAL PERKS",
        note=note or "SELECT A VARIETY.",resetSelection=reset==true,strains=varieties,actions={"BUY","CART"},
        buySizes={{label="1/8",value="eighth"},{label="OUNCE",value="ounce"},{label="QP",value="qp"}},
        packageDurations=durations,perkPreview=preview(player)})
end

local function stopSprint(player)
    local block,animation=getPedAnimation(player)
    if block and block:lower()=="ped" and animation and animation:lower()=="sprint_civi" then setPedAnimation(player,false) end
end

local function clearPerk(player,note)
    local perk=active[player]
    if not perk then return end
    active[player]=nil
    if isTimer(perk.timer) then killTimer(perk.timer) end
    if isElement(player) then
        if perk.type=="white" then stopSprint(player) end
        setElementData(player,"kratom:perk",false)
        triggerClientEvent(player,"kratom:perkClock",resourceRoot,preview(player))
        if note then triggerClientEvent(player,"weedGarden:notification",resourceRoot,note) end
    end
end

local function equip(player,variety,package)
    clearPerk(player)
    local perk={type=variety.type,duration=package.duration,expires=getTickCount()+package.duration,nextPulse=0}
    active[player]=perk
    setElementData(player,"kratom:perk",perk.type)
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
    local size=action:match("^buy:(.+)$")
    if name and byName[name] then state.variety=name state.package=nil
    elseif size and packages[size] then state.package=size
    elseif action=="CART" then state.package="cart"
    elseif action=="BUY" then
        local variety,package=byName[state.variety],packages[state.package]
        if not variety then sendShop(client,"SELECT A VARIETY.") return end
        if not package then sendShop(client,"SELECT A SIZE.") return end
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

addEvent("kratom:bodyHit",true)
addEventHandler("kratom:bodyHit",resourceRoot,function(attacker,weapon,bodypart,loss)
    local perk=client and active[client]
    if source~=resourceRoot or not perk or perk.type~="red" or perk.expires<=getTickCount() or isPedDead(client) then return end
    if type(bodypart)~="number" or bodypart<3 or bodypart>8 or type(loss)~="number" or loss~=loss or loss<=0 or loss>1000 or loss<getElementHealth(client) then return end
    if not isElement(attacker) or (getElementType(attacker)~="player" and getElementType(attacker)~="ped") then return end
    if weapon~=getPedWeapon(attacker) or weapon>46 or weapon<0 then return end
    if getElementInterior(attacker)~=getElementInterior(client) or getElementDimension(attacker)~=getElementDimension(client) then return end
    local x,y,z=getElementPosition(client)
    local ax,ay,az=getElementPosition(attacker)
    if getDistanceBetweenPoints3D(x,y,z,ax,ay,az)>(weapon<=15 and 4 or 200) then return end
    clearPerk(client,"RED KRATOM USED. 1 HP REMAINS.")
    setElementHealth(client,1)
end)

addEvent("kratom:sprint",true)
addEventHandler("kratom:sprint",resourceRoot,function(enabled)
    local perk=client and active[client]
    if source~=resourceRoot or not perk or perk.type~="white" then return end
    if enabled~=true then stopSprint(client) perk.sprintUntil=nil return end
    if isPedDead(client) or isPedInVehicle(client) or isElementFrozen(client) then return end
    local block,animation=getPedAnimation(client)
    if block and animation and animation:lower()~="sprint_civi" then return end
    perk.sprintUntil=getTickCount()+1500
    if not animation then setPedAnimation(client,"ped","sprint_civi",-1,true,true,false,false) end
end)

setTimer(function()
    local now=getTickCount()
    for player,perk in pairs(active) do
        if not isElement(player) then active[player]=nil
        elseif isPedDead(player) or now>=perk.expires then clearPerk(player)
        elseif perk.type=="white" and perk.sprintUntil and (now>=perk.sprintUntil or isPedInVehicle(player) or isElementFrozen(player)) then
            stopSprint(player) perk.sprintUntil=nil
        elseif perk.type=="green" and now>=perk.nextPulse then
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
