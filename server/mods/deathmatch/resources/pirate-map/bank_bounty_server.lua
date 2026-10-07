-- ONE BOUNTY POOL PER ROBBERY, SHARED BY EVERY MARKED PLAYER
local groups,members={},{}

local function inBank(player)
    if not isElement(player) or isPedDead(player) or getElementInterior(player)~=0
        or getElementDimension(player)~=0 then return false end
    local x,y,z=getElementPosition(player)
    return getDistanceBetweenPoints2D(x,y,2312.68408,-8.94955)<=25 and z>=20 and z<=36
end

local function amount(group)
    return math.max(0,math.floor(group.earned*0.5)-group.claimed)
end

local function publish()
    local count,total=0,0
    for _,group in pairs(groups) do total=total+amount(group) end
    for player,group in pairs(members) do
        if isElement(player) then
            count=count+1
            local value=amount(group)
            local stars=getPlayerWantedLevel(group.robber)
            local old=getElementData(player,"bank:bounty")
            if type(old)~="table" or old.amount~=value or old.stars~=stars then
                setElementData(player,"bank:bounty",{amount=value,stars=stars,robber=group.robber})
            end
        end
    end
    local old=getElementData(resourceRoot,"bank:bounties")
    if type(old)~="table" or old.targets~=count or old.total~=total then
        setElementData(resourceRoot,"bank:bounties",{targets=count,total=total})
    end
end

local function unmark(player)
    local group=members[player]
    if group then group.players[player]=nil end
    members[player]=nil
    if isElement(player) then setElementData(player,"bank:bounty",false) end
end

local function endGroup(group)
    groups[group.robber]=nil
    local players={}
    for player in pairs(group.players) do players[#players+1]=player end
    for _,player in ipairs(players) do unmark(player) end
    publish()
end

local function mark(group,player)
    if members[player] or group.dead[player] then return end
    members[player]=group
    group.players[player]=true
end

local function updateRobber(player)
    local data=getElementData(player,"bank:robbery")
    local group=groups[player]
    if type(data)~="table" or data.state=="hold" then
        if group then endGroup(group) end
        return
    end
    if not group then
        unmark(player)
        group={robber=player,earned=0,claimed=0,players={},dead={}}
        groups[player]=group
        mark(group,player)
    end
    group.earned=tonumber(data.total) or 0
    publish()
end

addEventHandler("onElementDataChange",root,function(key)
    if client or key~="bank:robbery" or getElementType(source)~="player" then return end
    updateRobber(source)
end)

-- REGISTER BEFORE THE BANK DEATH CLEANUP SO THE CLAIM IS SETTLED FIRST
addEventHandler("onPlayerWasted",root,function(_,killer)
    local group=members[source]
    if not group then return end
    for _,active in pairs(groups) do active.dead[source]=true end
    local hunter=killer
    if isElement(hunter) and getElementType(hunter)=="vehicle" then hunter=getVehicleController(hunter) end
    if isElement(hunter) and getElementType(hunter)=="player" and hunter~=source
        and hunter~=group.robber and isElement(group.robber) then
        local reward=math.min(amount(group),math.max(0,getPlayerMoney(group.robber)))
        if reward>0 and takePlayerMoney(group.robber,reward) then
            group.claimed=group.claimed+reward
            givePlayerMoney(hunter,reward)
            triggerClientEvent(hunter,"bank:bountyClaim",resourceRoot,reward)
        end
    end
    if source==group.robber then endGroup(group) else unmark(source);publish() end
end,true,"high+10")

addEventHandler("onPlayerQuit",root,function()
    local group=members[source]
    if group and group.robber==source then endGroup(group) else unmark(source);publish() end
end)

setTimer(function()
    for _,player in ipairs(getElementsByType("player")) do
        if inBank(player) and not members[player] then
            for _,group in pairs(groups) do
                if not groups[player] then mark(group,player) end
                if members[player] then break end
            end
        end
    end
    publish()
end,500,0)

addEventHandler("onResourceStart",resourceRoot,function()
    for _,player in ipairs(getElementsByType("player")) do
        setElementData(player,"bank:bounty",false)
        updateRobber(player)
    end
    publish()
end)

addEventHandler("onResourceStop",resourceRoot,function()
    local all={}
    for _,group in pairs(groups) do all[#all+1]=group end
    for _,group in ipairs(all) do endGroup(group) end
    setElementData(resourceRoot,"bank:bounties",false)
end)
