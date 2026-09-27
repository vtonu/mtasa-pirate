local maxZombies = 220 --Max zombies in TOTAL
local zombieTargets = {}
local zombieProgress = {}

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
			local paused = not active or not isElement(target) or isPassive(target) or isPedDead(target)
			if isElementFrozen(zombie) ~= paused then setElementFrozen(zombie,paused) end
		end
	end
end

local function getRandomPlayerWithLowestPing(playerList,excludePlayer)

	local lowestPing = false
	local returnPlayer = false
	local playerCount = #playerList
	
	if playerCount == 0 then
		return false
	elseif playerCount == 1 then
		if excludePlayer ~= playerList[1] then
			return playerList[1]
		else
			return false
		end
	else
		for index,player in ipairs(playerList) do
			if player ~= excludePlayer then
				local ping = player.ping
				if lowestPing == false or ping < lowestPing then
					lowestPing = ping
					returnPlayer = player
				end
			end
		end
		return returnPlayer
	end

end

local function updateZombieTargets()

	if client~=source then return end
	
	triggerClientEvent(client,"Zday:sendZombiesInfo",client,zombieTargets)

end
	
local function destroyChasers()
	
	local clientWeAsk = getRandomPlayerWithLowestPing(getElementsByType("player"),source)
	
	for index,zombie in ipairs(getElementsByType("ped",resourceRoot)) do
		if zombieTargets[zombie] == source and clientWeAsk then
			triggerClientEvent(clientWeAsk,"Zday:askForNewTarget",zombie,source)
		elseif not clientWeAsk then
			destroyZombie(zombie)
		end
	end

end

local function setZombieTarget(zombie,target)

	if not isElement(zombie) or getElementParent(zombie) ~= getResourceDynamicElementRoot(getThisResource()) then return end
	if target and isElement(target) and getElementType(target) == "player" and not isPassive(target) then
		zombieTargets[zombie] = target
		if getElementSyncer(zombie) ~= target then
			setElementSyncer(zombie,target)
		end
		triggerClientEvent(root,"Zday:setZombieTarget",resourceRoot,zombie,target)
	end

end

function destroyZombie(zombie)

	zombie = zombie or source
	
	if not zombie then return end
	zombieProgress[zombie] = nil
	
	if isElement(zombie) then
		destroyElement(zombie)
	end
	
	if zombieTargets[zombie] then
		zombieTargets[zombie] = nil
	end

end

-- CLEAR DISTANT OR STUCK CHASERS WITHOUT REMOVING NEARBY THREATS
local function cleanZombieChasers()
	local now = getTickCount()
	for zombie,target in pairs(zombieTargets) do
		if not isElement(zombie) then
			zombieTargets[zombie] = nil
			zombieProgress[zombie] = nil
		elseif not isPedDead(zombie) then
			local x,y,z = getElementPosition(zombie)
			local nearest,nearestDistance
			for _,player in ipairs(getElementsByType("player")) do
				if not isPedDead(player) and not isPassive(player)
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
			if not isZombieWeather() or isElementFrozen(zombie) then
				zombieProgress[zombie] = nil
			elseif not nearestDistance or nearestDistance > 120 then
				destroyZombie(zombie)
			else
				if not progress or getDistanceBetweenPoints3D(x,y,z,progress.x,progress.y,progress.z) > 2 then
					zombieProgress[zombie] = {x=x,y=y,z=z,tick=now}
				elseif now - progress.tick > 30000 and nearestDistance > 40 then
					destroyZombie(zombie)
				end
				if isElement(zombie) and nearest ~= target then
					local distance = math.huge
					if isElement(target) then
						local tx,ty,tz = getElementPosition(target)
						distance = getDistanceBetweenPoints3D(x,y,z,tx,ty,tz)
					end
					if distance > 120 then setZombieTarget(zombie,nearest) end
				end
			end
		end
	end
end

local function delayDestroyZombie()

	setTimer(destroyZombie,4000,1,source)

end

local function damageZombie(attacker,weapon,bodypart,loss)

	if not client or attacker ~= client or isPassive(client) then return end
	if type(loss) ~= "number" or loss <= 0 then return end
	if (source.health - loss) <= 0 then
		killPed(source,attacker,weapon,bodypart)
	else
		source.health = source.health - loss
	end

	if bodypart == 9 then
		setPedHeadless(source,true)
		if isPedDead(source)==false then killPed(source,attacker,weapon,bodypart) end
	end

end

local function spawnZombie(s,zx,zy,zz,r)

	if #getElementsByType("ped",resourceRoot) >= maxZombies then return end
	if client ~= source then return end
	if not isZombieWeather() or isPassive(client) or isPedDead(client) then return end
	
	local zombie = Ped(s,zx,zy,zz,r,true)
	if not isElement(zombie) then return end
	setElementDimension(zombie,getElementDimension(client))
	setElementInterior(zombie,getElementInterior(client))
	local variant = s % 4
	local weapon = variant == 0 and 4 or (variant == 1 and 9 or (variant == 2 and 0 or 5))
	setElementData(zombie, "zday.variant", variant, true)
	if weapon > 0 then giveWeapon(zombie,weapon,1,true) end
	setZombieTarget(zombie,client)
	updateZombieActivity()
	
	addEventHandler("Zday:damageZombie",zombie,damageZombie)
	addEventHandler("Zday:destroyZombie",zombie,destroyZombie)
	addEventHandler("Zday:setZombieNewTarget",zombie,function(target)
		if not client or (zombieTargets[source] ~= client and getElementSyncer(source) ~= client) then return end
		setZombieTarget(source,target)
	end)
	addEventHandler("Zday:delayDestroyZombie",zombie,delayDestroyZombie)

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
	addEvent("Zday:damageZombie",true)
	addEvent("Zday:delayDestroyZombie",true)
	addEvent("Zday:setZombieNewTarget",true)
	addEventHandler("Zday:spawnZombie",root,spawnZombie)
	addEventHandler("Zday:getZombiesInfo",root,updateZombieTargets)
	
	addEventHandler("onPlayerQuit",root,destroyChasers)
	updateZombieActivity()
	setTimer(updateZombieActivity,250,0)
	setTimer(cleanZombieChasers,5000,0)

end

addEventHandler("onResourceStart",resourceRoot,initScript)

-- PAUSE CHASERS WITHOUT REMOVING THEM
addEventHandler("onElementDataChange",root,function(key)
	if key == "freeroam.passive" then updateZombieActivity() end
end)
