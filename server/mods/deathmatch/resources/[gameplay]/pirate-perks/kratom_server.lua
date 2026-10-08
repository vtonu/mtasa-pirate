-- GREEN MARKER CATALOG; WEED STOCK AND PERKS STAY SEPARATE
local shops,active,requests={},{},{}
local reserveLimit=8000
local varieties={
    {name="WHITE",symbol="W",type="white",price=1500,duration=300000,description="SLOW MOVEMENT / DOUBLE HYBRID JUMP / WHITE NIGHT VISION / CONTINUOUS RED ZOMBIE SILHOUETTES.",white=100,green=0,purple=0},
    {name="GREEN",symbol="G",type="green",price=2000,duration=360000,description="MINT NIGHT VISION / CONTINUOUS GREEN ZOMBIE SILHOUETTES.",white=0,green=100,purple=0},
    {name="PURPLE",symbol="P",type="purple",price=3000,duration=240000,description="8,000 HEALTH RESERVE / POWER MELEE.",white=0,green=0,purple=100}
}
local byName={}
for _,variety in ipairs(varieties) do
    variety.prices={cart=variety.price}
    byName[variety.name]=variety
end

local function nearShop(player)
    if not isElement(player) or isPedDead(player) or isPedInVehicle(player) then return false end
    local x,y,z=getElementPosition(player)
    for _,id in ipairs({"specialShopWeedGarden","specialShopRedCounty","specialShopNorthLV","specialShopAngelPine","specialShopLSHospital"}) do
        local marker=getElementByID(id)
        if isElement(marker) and getElementData(marker,"specialShop:catalog")=="kratom"
            and getElementInterior(marker)==getElementInterior(player)
            and getElementDimension(marker)==getElementDimension(player) then
            local mx,my,mz=getElementPosition(marker)
            if getDistanceBetweenPoints3D(x,y,z,mx,my,mz+1)<=1.25 then return true end
        end
    end
    return false
end

local function preview(player)
    local perk=active[player]
    return {type=perk and perk.type or false,duration=perk and perk.duration or 0,
        remaining=perk and math.max(0,perk.expires-getTickCount()) or 0}
end

local function sendShop(player,note,reset)
    triggerClientEvent(player,"kratom:openUI",resourceRoot,{shopMode="kratom",title="KRATOM SHOP",zone="SPECIAL PERKS",
        note=note or "SELECT A VARIETY.",resetSelection=reset==true,strains=varieties,actions={"BUY"},
        buySizes={},
        perkPreview=preview(player)})
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
    perk.reserve=math.max(100,(perk.reserve or reserveLimit)-math.min(loss,1000))
    setElementHealth(player,perk.reserve/reserveLimit*100)
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
        if perk.type=="purple" then setPedFightingStyle(player,perk.baseFightingStyle) end
        setElementData(player,"kratom:perk",false)
        triggerClientEvent(player,"kratom:perkClock",resourceRoot,preview(player))
        if note then triggerClientEvent(player,"weedGarden:notification",resourceRoot,note) end
    end
end

function clearKratomPerks(player)
    clearPerk(player)
end

local function equip(player,variety,package)
    clearPerk(player)
    clearWeedPerks(player)
    local perk={type=variety.type,duration=package.duration,expires=getTickCount()+package.duration,baseGravity=getElementData(player,"weed.perk") and 0.008 or getPedGravity(player)}
    perk.baseFightingStyle=getPedFightingStyle(player)
    active[player]=perk
    if perk.type=="white" then setPedGravity(player,isPedInVehicle(player) and 0.008 or 0.0015) end
    if perk.type=="purple" then
        perk.reserve=reserveLimit
        setElementHealth(player,100)
        setPedFightingStyle(player,5)
    end
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
        local variety=byName[state.variety]
        if not variety then sendShop(client,"SELECT A VARIETY.") return end
        local package={price=variety.price,duration=variety.duration}
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

-- AMBULANCE ENTRY USES SERVER PERK STATE; EXPIRY DOES NOT EJECT OCCUPANTS
local ambulanceNotices={}
local function canEnterAmbulance(player)
    local perk=active[player]
    return perk and perk.expires>getTickCount() and not isPedDead(player) or false
end
local function denyAmbulance(player)
    local now=getTickCount()
    if now>=(ambulanceNotices[player] or 0) then
        ambulanceNotices[player]=now+2000
        outputChatBox("Only #7FFF00Kratom#FFE66D players can use this vehicle.",player,255,230,109,true)
    end
end
addEventHandler("onVehicleStartEnter",root,function(player)
    if getElementModel(source)==416 and getElementType(player)=="player" and not canEnterAmbulance(player) then
        cancelEvent()
        denyAmbulance(player)
    end
end)
-- ALSO COVER WARP ENTRY FROM OTHER RESOURCES
addEventHandler("onVehicleEnter",root,function(player)
    if getElementModel(source)==416 and getElementType(player)=="player" and not canEnterAmbulance(player) then
        removePedFromVehicle(player)
        denyAmbulance(player)
    end
end)
addEventHandler("onPlayerQuit",root,function() ambulanceNotices[source]=nil end)
