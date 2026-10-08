-- LIFESTYLE ZOMBIES
-- CUSTOM VERSION BY LIFESTYLE
-- CODE ASSISTANCE: OPENAI CODEX
-- BASE RESOURCE CREDIT: DUTCHMAN101

local maxZombies = 220 --Max zombies in TOTAL
local zombieTargets = {}
local zombieProgress = {}
local zombieDeathGrace = {}
local knifeAttempts = {}
local setZombieTarget

local function targetDistance(zombie,player)
	if not isElement(player) or isPedDead(player) or getElementData(player,"freeroam.passive") == true then return math.huge end
	if getElementInterior(player) ~= 0 or getElementInterior(zombie) ~= 0 then return math.huge end
	if getElementDimension(player) ~= getElementDimension(zombie) or getElementInterior(player) ~= getElementInterior(zombie) then return math.huge end
	local x,y,z = getElementPosition(zombie)
	local px,py,pz = getElementPosition(player)
	return getDistanceBetweenPoints3D(x,y,z,px,py,pz)
end

local function isPassive(player)
	local freeroam = getResourceFromName("freeroam")
	return freeroam and getResourceState(freeroam) == "running"
		and call(freeroam, "isPlayerPassive", player) == true
end

local function isZombieWeather()
	return getWeather() == 9
end

local function updateZombieActivity()
	local active = isZombieWeather()
	if getElementData(resourceRoot,"zday.active") ~= active then
		setElementData(resourceRoot,"zday.active",active)
	end
	for zombie,target in pairs(zombieTargets) do
		if isElement(zombie) and not isPedDead(zombie) then
			if active then
				local currentDistance = targetDistance(zombie,target)
				local nearest,nearestDistance = false,120
				for _,player in ipairs(getElementsByType("player")) do
					local distance = targetDistance(zombie,player)
					if distance < nearestDistance then nearest,nearestDistance = player,distance end
				end
				-- SWITCH ONLY WHEN ANOTHER PLAYER IS AT LEAST FIVE METRES CLOSER
				if currentDistance > 120 or (nearest and nearestDistance + 5 < currentDistance) then
					setZombieTarget(zombie,nearest)
					target = nearest
				end
			end
			local paused = not active or targetDistance(zombie,target) > 120
			if isElementFrozen(zombie) ~= paused then setElementFrozen(zombie,paused) end
			if not paused and getElementSyncer(zombie) ~= target then
				setElementSyncer(zombie,target)
			end
		end
	end
end

local function updateZombieTargets()

	if client~=source then return end
	
	triggerClientEvent(client,"Zday:sendZombiesInfo",client,zombieTargets)

end
	
setZombieTarget = function(zombie,target)

	if not isElement(zombie) or getElementParent(zombie) ~= getResourceDynamicElementRoot(getThisResource()) then return end
	if target == false or (target and targetDistance(zombie,target) <= 120) then
		if zombieTargets[zombie] == target then return end
		zombieTargets[zombie] = target
		if target and getElementSyncer(zombie) ~= target then
			setElementSyncer(zombie,target)
		end
		triggerClientEvent(root,"Zday:setZombieTarget",resourceRoot,zombie,target)
	end

end

function destroyZombie(zombie)

	zombie = zombie or source
	
	if not zombie then return end
	zombieProgress[zombie] = nil
	zombieDeathGrace[zombie] = nil
	
	if isElement(zombie) then
		destroyElement(zombie)
	end
	
	zombieTargets[zombie] = nil

end


-- CLEAR DISTANT OR STUCK CHASERS WITHOUT REMOVING NEARBY THREATS
local function cleanZombieChasers()
	local now = getTickCount()
	for zombie,target in pairs(zombieTargets) do
		if not isElement(zombie) then
			zombieTargets[zombie] = nil
			zombieProgress[zombie] = nil
			zombieDeathGrace[zombie] = nil
		elseif getElementInterior(zombie) ~= 0 then
			destroyZombie(zombie)
		elseif not isPedDead(zombie) then
			local x,y,z = getElementPosition(zombie)
			local nearest,nearestDistance
			for _,player in ipairs(getElementsByType("player")) do
				if not isPedDead(player)
					and getElementDimension(player) == getElementDimension(zombie)
					and getElementInterior(player) == getElementInterior(zombie) then
					local px,py,pz = getElementPosition(player)
					local distance = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
					if not nearestDistance or distance < nearestDistance then
						nearest,nearestDistance = player,distance
					end
				end
			end
			local progress = zombieProgress[zombie]
			if now < (zombieDeathGrace[zombie] or 0) then
				zombieProgress[zombie] = nil
			elseif not nearestDistance or nearestDistance > 120 then
				destroyZombie(zombie)
			elseif not isZombieWeather() or isElementFrozen(zombie) then
				zombieProgress[zombie] = nil
			else
				if not progress or getDistanceBetweenPoints3D(x,y,z,progress.x,progress.y,progress.z) > 2 then
					zombieProgress[zombie] = {x=x,y=y,z=z,tick=now}
				elseif now - progress.tick > 30000 and nearestDistance > 40 then
					destroyZombie(zombie)
				end

			end
		end
	end
end

local function delayDestroyZombie()

	setTimer(destroyZombie,4000,1,source)

end

local purpleHits={}
local purpleMelee={[0]=40,[1]=50,[2]=120,[3]=120,[4]=55,[5]=120,[6]=120,[7]=120,[8]=120,[9]=120,[10]=120,[11]=120,[12]=120,[13]=120,[14]=120,[15]=120}

local function purpleImpact(zombie,attacker,alive)
    local x,y,z=getElementPosition(zombie)
    local ax,ay=getElementPosition(attacker)
    local dx,dy=x-ax,y-ay
    local length=math.sqrt(dx*dx+dy*dy)
    if length<0.01 then dx,dy,length=0,1,1 end
    local vx,vy=dx/length*0.13,dy/length*0.13
    setElementVelocity(zombie,vx,vy,0.07)
    if alive then
        setElementData(zombie,"kratom:knocked",true)
        setPedAnimation(zombie,"ped","KO_skid_back",900,false,false,false,true)
        setTimer(function()
            if isElement(zombie) then
                setElementData(zombie,"kratom:knocked",false)
                if not isPedDead(zombie) then setPedAnimation(zombie,false) end
            end
        end,900,1)
    end
    triggerClientEvent(root,"Zday:kratomImpact",resourceRoot,zombie,vx,vy,alive)
end

local function damageZombie(attacker,weapon,bodypart,loss)

	if not client or attacker ~= client or isPassive(client) then return end
	if type(loss) ~= "number" or loss ~= loss or loss <= 0 or loss == math.huge then return end
    local boosted=false
    local shop=getResourceFromName("pirate-perks")
    if purpleMelee[weapon] and shop and getResourceState(shop)=="running" and exports["pirate-perks"]:isKratomProtected(client) then
        if getElementParent(source)~=getResourceDynamicElementRoot(getThisResource()) or isPedDead(source)
            or getPedWeapon(client)~=weapon or isPedInVehicle(client)
            or getElementDimension(source)~=getElementDimension(client)
            or getElementInterior(source)~=getElementInterior(client) then return end
        local x,y,z=getElementPosition(source)
        local ax,ay,az=getElementPosition(client)
        if getDistanceBetweenPoints3D(x,y,z,ax,ay,az)>3.5 then return end
        local now=getTickCount()
        if now<(purpleHits[source] or 0) then return end
        purpleHits[source]=now+250
        loss=purpleMelee[weapon]
        boosted=true
    end
	if (source.health - loss) <= 0 then
		killPed(source,attacker,weapon,bodypart)
	else
		source.health = source.health - loss
	end

	if bodypart == 9 and not boosted then
		setPedHeadless(source,true)
		if isPedDead(source)==false then killPed(source,attacker,weapon,bodypart) end
	end
    if boosted then purpleImpact(source,client,not isPedDead(source)) end

end

addEventHandler("onElementDestroy",resourceRoot,function() purpleHits[source]=nil end)

local function bankLimit()
	local cap
	for _,player in ipairs(getElementsByType("player")) do
		local pressure=getBankZombiePressure(player)
		if pressure then cap=math.max(cap or 0,pressure.cap) end
	end
	return cap
end

local function bankChasers()
	local result={}
	for _,zombie in ipairs(getElementsByType("ped",resourceRoot)) do
		if not isPedDead(zombie) and getElementInterior(zombie)==0 and getElementDimension(zombie)==0 then
			local x,y,z=getElementPosition(zombie)
			if getDistanceBetweenPoints2D(x,y,2312.68408,-8.94955)<=45 and z>=20 and z<=36 then
				result[#result+1]=zombie
			end
		end
	end
	return result
end

-- INCLUDE EXISTING CHASERS SO EXTRA BANK VISITORS DO NOT MULTIPLY THE CAP
setTimer(function()
	local cap=bankLimit()
	if not cap or not isZombieWeather() then return end
	local chasers=bankChasers()
	for index=cap+1,#chasers do destroyZombie(chasers[index]) end
end,1000,0)

local function spawnZombie(s,zx,zy,zz,r)

	if #getElementsByType("ped",resourceRoot) >= maxZombies then return end
	if client ~= source then return end
	if not isZombieWeather() or isPedDead(client) then return end
	if getElementInterior(client) ~= 0 then return end
	local pressure=getBankZombiePressure(client)
	if pressure then
		if #bankChasers()>=(bankLimit() or pressure.cap) then return end
	end
	
	local zombie = Ped(s,zx,zy,zz,r,true)
	if not isElement(zombie) then return end
	setElementDimension(zombie,getElementDimension(client))
	setElementInterior(zombie,getElementInterior(client))
	local variant = s % 4
	local weapon = variant == 0 and 4 or (variant == 1 and 9 or (variant == 2 and 0 or 5))
	setElementData(zombie, "zday.variant", variant, true)
	if weapon > 0 then giveWeapon(zombie,weapon,1,true) end
	setZombieTarget(zombie,false)
	updateZombieActivity()
	
	addEventHandler("Zday:damageZombie",zombie,damageZombie)
	addEventHandler("Zday:destroyZombie",zombie,destroyZombie)

	addEventHandler("Zday:delayDestroyZombie",zombie,delayDestroyZombie)

end

-- CHECK KNIFE NECK STABS ON THE SERVER
local function murderPlayer(zombie)
	if not client or client ~= source then return end
	if not isZombieWeather() or isPassive(client) or getElementData(client,"freeroam.passive") == true or isPedDead(client) or getPedOccupiedVehicle(client) then return end
	if not isElement(zombie) or zombieTargets[zombie] ~= client or isPedDead(zombie) or getPedWeapon(zombie) ~= 4 then return end
	if targetDistance(zombie,client) > 1.2 then return end
	local now = getTickCount()
	if now < (knifeAttempts[client] or 0) then return end
	knifeAttempts[client] = now + 3500
	if math.random(1,100) <= 35 then
		local shop=getResourceFromName("pirate-perks")
		if shop and getResourceState(shop)=="running" and exports["pirate-perks"]:isKratomProtected(client) then
			setElementHealth(client,math.max(1,getElementHealth(client)))
			return
		end
		killPed(client,zombie,55,9,true)
	end
end

local function initScript()

	local thisResourceName = getResourceName(getThisResource())
	
	if hasObjectPermissionTo("resource."..thisResourceName,"function.setServerConfigSetting") then
		setServerConfigSetting("ped_sync_interval",100)
	elseif tonumber(getServerConfigSetting("ped_sync_interval")) > 100 then
		outputDebugString(thisResourceName:upper()..": ped_sync_interval is +100 and "..thisResourceName:lower().." cant set it to 100 due to not having permission to, give it ACL.")
		outputDebugString(thisResourceName:upper()..": Zombies may be buggy")
	end

	addEvent("Zday:getZombiesInfo",true)
	addEvent("Zday:spawnZombie",true)
	addEvent("Zday:destroyZombie",true)
	addEvent("Zday:murderPlayer",true)
	addEvent("Zday:damageZombie",true)
	addEvent("Zday:delayDestroyZombie",true)
	addEventHandler("Zday:spawnZombie",root,spawnZombie)
	addEventHandler("Zday:murderPlayer",root,murderPlayer)
	addEventHandler("Zday:getZombiesInfo",root,updateZombieTargets)
	
	-- TARGETS ARE CHECKED BY THE SERVER TIMER
	updateZombieActivity()
	setTimer(updateZombieActivity,250,0)
	setTimer(cleanZombieChasers,5000,0)

end

addEventHandler("onResourceStart",resourceRoot,initScript)
addEventHandler("onPlayerQuit",root,function() knifeAttempts[source] = nil end)
-- KEEP LIVING CHASERS FOR THIRTY SECONDS AFTER THEIR TARGET DIES
addEventHandler("onPlayerWasted",root,function()
	local expires = getTickCount() + 30000
	for zombie,target in pairs(zombieTargets) do
		if target == source and isElement(zombie) and not isPedDead(zombie) then
			zombieDeathGrace[zombie] = expires
			zombieProgress[zombie] = nil
		end
	end
end)

addEventHandler("onPlayerSpawn",root,function() knifeAttempts[source] = nil end)

-- UPDATE TARGETS WHEN PASSIVE MODE CHANGES
addEventHandler("onElementDataChange",root,function(key)
	if key == "freeroam.passive" then updateZombieActivity() end
end)
