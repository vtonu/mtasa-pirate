-- BONE COUNTY SECURICAR DELIVERY
local destinations={
    {name="NORTH LV AMMU-NATION",x=2580.63257,y=2068.74414,z=10.82031},
    {name="SOUTH LV AMMU-NATION",x=2201.87158,y=931.23120,z=10.82031}
}
local sessions,vehicleSessions,requests,lastDestination={},{},{},{}
local startMarker,pickupVan,home,stopping
local finish
local nextVanAt=0
local cargoIds={"securiVehicleBCMissionCrate1","securiVehicleBCMissionCrate2","securiVehicleBCMissionCrate3"}

local function near(player,element,radius)
    if not isElement(player) or not isElement(element) or isPedDead(player)
        or getElementInterior(player)~=getElementInterior(element)
        or getElementDimension(player)~=getElementDimension(element) then return false end
    local x,y,z=getElementPosition(player)
    local ex,ey,ez=getElementPosition(element)
    return getDistanceBetweenPoints2D(x,y,ex,ey)<=radius and math.abs(z-ez)<=3
end

local function publish(s)
    if isElement(s.player) then
        setElementData(s.player,"bone:delivery",{state=s.state,marker=s.marker,vehicle=s.vehicle,
            name=s.destination and s.destination.name,blip=s.blip,collected=s.collected or 0,
            remaining=s.endsAt-getTickCount()})
    end
end

local function remove(element)
    if isElement(element) then destroyElement(element) end
end

local function isLoadingVan(vehicle)
    for _,s in pairs(sessions) do
        if s.loading and s.loadingVehicle==vehicle then return true end
    end
    return false
end

local function updateRearDoors(vehicle)
    if not isElement(vehicle) then return end
    local ratio=isLoadingVan(vehicle) and 1 or 0
    setVehicleDoorOpenRatio(vehicle,4,ratio,500)
    setVehicleDoorOpenRatio(vehicle,5,ratio,500)
end

local function releasePlayer(s)
    if s.loading and isElement(s.player) then
        setPedAnimation(s.player,false)
        setElementFrozen(s.player,s.wasFrozen)
    end
    s.loading=false
    updateRearDoors(s.loadingVehicle)
    s.loadingVehicle=nil
end

local function waitingReady()
    for _,s in pairs(sessions) do if s.state=="vehicle" then return true end end
    return false
end

local function refreshVan()
    if not isElement(pickupVan) then return end
    local ready=waitingReady() and not isLoadingVan(pickupVan)
    setVehicleLocked(pickupVan,not ready)
    setElementFrozen(pickupVan,true)
    setVehicleDamageProof(pickupVan,true)
    for _,s in pairs(sessions) do
        if s.state=="vehicle" and s.vehicle~=pickupVan then
            remove(s.blip)
            s.vehicle=pickupVan
            s.blip=createBlipAttachedTo(pickupVan,0,2,255,40,40,255,0,65535,s.player)
            publish(s)
        end
    end
end

local function setupVan(van)
    if not emmetConfigureMissionVan(van) then
        outputDebugString("BONE SECURICAR SETUP MISSING",1)
        return false
    end
    setElementParent(van,resourceRoot)
    setElementData(van,"bone:missionVan",true)
    setVehicleRespawnPosition(van,home.x,home.y,home.z)
    toggleVehicleRespawn(van,false)
    pickupVan=van
    startMarker=createMarker(774.53442,1884.24646,5.7,"arrow",0.8,127,255,212,255)
    if not isElement(startMarker) then
        pickupVan=nil
        remove(van)
        return false
    end
    setElementParent(startMarker,resourceRoot)
    setElementData(startMarker,"bone:start",true)
    setElementData(resourceRoot,"bone:pickupArrow",startMarker)
    refreshVan()
    return true
end

local function ensureVan()
    if stopping or not home or isElement(pickupVan) or getTickCount()<nextVanAt then return end
    for _,vehicle in ipairs(getElementsByType("vehicle")) do
        if getElementInterior(vehicle)==0 and getElementDimension(vehicle)==0 then
            local x,y,z=getElementPosition(vehicle)
            if getDistanceBetweenPoints2D(x,y,home.x,home.y)<7 and math.abs(z-home.z)<4 then return end
        end
    end
    local van=createVehicle(428,home.x,home.y,home.z,0,0,home.rotation)
    if isElement(van) then
        setupVan(van)
    end
end

finish=function(s,success)
    if sessions[s.player]~=s then return end
    sessions[s.player]=nil
    releasePlayer(s)
    if isTimer(s.timer) then killTimer(s.timer) end
    remove(s.marker)
    remove(s.blip)
    remove(s.publicBlip)
    if isElement(s.player) then
        setElementData(s.player,"bone:delivery",false)
        triggerClientEvent(s.player,"bone:result",resourceRoot,success==true)
    end
    if s.vehicle and vehicleSessions[s.vehicle]==s then
        vehicleSessions[s.vehicle]=nil
        remove(s.vehicle)
    end
    refreshVan()
end

addEvent("bone:load",true)
addEventHandler("bone:load",resourceRoot,function()
    if not client or source~=resourceRoot or sessions[client] or not near(client,startMarker,1.8)
        or getPedOccupiedVehicle(client) then return end
    local now=getTickCount()
    if requests[client] and now-requests[client]<1000 then return end
    requests[client]=now
    ensureVan()
    if not isElement(pickupVan) then return end
    local s={player=client,state="collect",collected=0,endsAt=now+90000}
    sessions[client]=s
    s.marker=createMarker(767.82452,1889.92102,5.78,"arrow",0.8,127,255,212,255,client)
    if not isElement(s.marker) then finish(s,false) return end
    setElementParent(s.marker,resourceRoot)
    setElementData(s.marker,"bone:markerOwner",client)
    s.blip=createBlipAttachedTo(s.marker,0,2,127,255,212,255,0,16383,client)
    if not isElement(s.blip) then finish(s,false) return end
    publish(s)
end)

addEvent("bone:collect",true)
addEventHandler("bone:collect",resourceRoot,function()
    local s=client and sessions[client]
    if source~=resourceRoot or not s or s.state~="collect" or getPedOccupiedVehicle(client)
        or not near(client,s.marker,1.3) then return end
    s.collected=s.collected+1
    if s.collected<#cargoIds then publish(s) return end
    remove(s.marker)
    s.marker=nil
    remove(s.blip)
    s.blip=nil
    s.state="cargo"
    publish(s)
end)

addEvent("bone:store",true)
addEventHandler("bone:store",resourceRoot,function()
    local s=client and sessions[client]
    if source~=resourceRoot or not s or s.state~="cargo" or getPedOccupiedVehicle(client)
        or not near(client,startMarker,1.8) then return end
    ensureVan()
    if not isElement(pickupVan) then return end
    s.state,s.loading,s.wasFrozen="loading",true,isElementFrozen(client)
    s.loadingVehicle=pickupVan
    setElementFrozen(client,true)
    setElementRotation(client,0,0,home.rotation)
    setPedAnimation(client,"INT_HOUSE","wash_up",-1,true,false,false,false)
    updateRearDoors(pickupVan)
    refreshVan()
    publish(s)
    s.timer=setTimer(function()
        s.timer=nil
        if sessions[s.player]~=s then return end
        if not near(s.player,startMarker,1.8) or s.loadingVehicle~=pickupVan
            or not isElement(pickupVan) then finish(s,false) return end
        releasePlayer(s)
        s.state="vehicle"
        publish(s)
        ensureVan()
        refreshVan()
    end,8000,1)
end)

addEventHandler("onVehicleStartEnter",root,function(player,seat)
    if getElementData(source,"bone:missionVan")~=true then return end
    local s=sessions[player]
    if source~=pickupVan or seat~=0 or not s or s.state~="vehicle" or isLoadingVan(source) then
        local owner=vehicleSessions[source]
        if not owner or owner.player~=player or seat~=0 then cancelEvent() end
    end
end)

addEventHandler("onVehicleEnter",root,function(player,seat)
    if getElementData(source,"bone:missionVan")~=true then return end
    if source~=pickupVan then
        local owner=vehicleSessions[source]
        if not owner or owner.player~=player or seat~=0 then removePedFromVehicle(player) end
        return
    end
    if seat~=0 then removePedFromVehicle(player) return end
    local s=sessions[player]
    if not s or s.state~="vehicle" or isLoadingVan(source) then removePedFromVehicle(player) return end
    local van=pickupVan
    pickupVan=nil
    nextVanAt=getTickCount()+30000
    remove(startMarker)
    startMarker=nil
    setElementData(resourceRoot,"bone:pickupArrow",false)
    vehicleSessions[van]=s
    s.vehicle=van
    setElementFrozen(van,false)
    setVehicleDamageProof(van,false)
    setVehicleLocked(van,false)
    remove(s.blip)
    local index=lastDestination[player]==1 and 2 or (lastDestination[player]==2 and 1 or math.random(2))
    lastDestination[player]=index
    s.destination=destinations[index]
    local d=s.destination
    s.state,s.endsAt="delivery",getTickCount()+300000
    s.marker=createMarker(d.x,d.y,d.z-1,"cylinder",4,127,255,212,255,player)
    s.blip=createBlip(d.x,d.y,d.z,51,3,255,40,40,255,0,65535,player)
    if not isElement(s.marker) or not isElement(s.blip) then finish(s,false) return end
    setElementParent(s.marker,resourceRoot)
    s.publicBlip=createBlipAttachedTo(van,41,2,255,255,255,255,0,16383,root)
    if not isElement(s.publicBlip) then finish(s,false) return end
    publish(s)
    addEventHandler("onMarkerHit",s.marker,function(element,matchingDimension)
        if sessions[player]~=s or s.state~="delivery" or not matchingDimension
            or (element~=s.vehicle and element~=player) or getTickCount()>=s.endsAt
            or getPedOccupiedVehicle(player)~=s.vehicle or getVehicleController(s.vehicle)~=player
            or not near(player,s.marker,5) then return end
        givePlayerMoney(player,500000)
        finish(s,true)
    end)
    -- OTHER READY PLAYERS WAIT FOR A CLEAR HOME BEFORE A NEW VAN APPEARS
    for _,other in pairs(sessions) do
        if other~=s and other.state=="vehicle" then
            remove(other.blip)
            other.blip,other.vehicle=nil,nil
            publish(other)
        end
    end
end)

local function lostVan(vehicle)
    if vehicle==pickupVan then
        pickupVan=nil
        nextVanAt=getTickCount()+30000
        remove(startMarker)
        startMarker=nil
        setElementData(resourceRoot,"bone:pickupArrow",false)
        local loaders={}
        for _,waiting in pairs(sessions) do
            if waiting.loadingVehicle==vehicle then loaders[#loaders+1]=waiting
            elseif waiting.state=="vehicle" then
                remove(waiting.blip)
                waiting.blip,waiting.vehicle=nil,nil
                publish(waiting)
            end
        end
        for _,loader in ipairs(loaders) do finish(loader,false) end
        if isElement(vehicle) and isVehicleBlown(vehicle) then
            setTimer(function() remove(vehicle) end,5000,1)
        end
    end
    local s=vehicleSessions[vehicle]
    if s then finish(s,false) end
end
addEventHandler("onVehicleExplode",root,function()
    local s=vehicleSessions[source]
    if s and s.state=="delivery" then emmetDropMissionLoot(source) end
    lostVan(source)
end)
addEventHandler("onElementDestroy",root,function() lostVan(source) end)

local function clearPlayer()
    local s=sessions[source]
    if s then finish(s,false) end
    requests[source],lastDestination[source]=nil,nil
end
addEventHandler("onPlayerQuit",root,clearPlayer)
addEventHandler("onPlayerWasted",root,clearPlayer)
addEventHandler("onPlayerSpawn",root,clearPlayer)

setTimer(function()
    local now=getTickCount()
    local expired={}
    for _,s in pairs(sessions) do
        if not isElement(s.player) or isPedDead(s.player) or now>=s.endsAt
            or getElementInterior(s.player)~=0 or getElementDimension(s.player)~=0 then
            expired[#expired+1]=s
        end
    end
    for _,s in ipairs(expired) do finish(s,false) end
    ensureVan()
    refreshVan()
end,1000,0)

addEventHandler("onResourceStart",resourceRoot,function()
    for _,id in ipairs(cargoIds) do
        local object=getElementByID(id)
        if isElement(object) then
            setElementAlpha(object,0)
            setElementCollisionsEnabled(object,false)
            setElementFrozen(object,true)
        end
    end
    local van=getElementByID("vehicle (Securicar) (1)")
    if not isElement(van) then outputDebugString("BONE SECURICAR MISSING",1) return end
    local x,y,z=getElementPosition(van)
    local _,_,rotation=getElementRotation(van)
    home={x=x,y=y,z=z,rotation=rotation}
    setupVan(van)
end)

addEventHandler("onResourceStop",resourceRoot,function()
    stopping=true
    local all={}
    for _,s in pairs(sessions) do all[#all+1]=s end
    for _,s in ipairs(all) do finish(s,false) end
end)
