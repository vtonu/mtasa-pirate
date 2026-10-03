-- LIFESTYLE ZOMBIES
-- CUSTOM VERSION BY LIFESTYLE
-- CODE ASSISTANCE: OPENAI CODEX
-- BASE RESOURCE CREDIT: DUTCHMAN101

local maxZombies = 8 --Max zombies to chase local player
local minDistance = 10 -- MINIMUM SPAWN DISTANCE
local maxDistance = 30 -- MAXIMUM SPAWN DISTANCE
local minInterval = 2000 --Minium time between spawning zombies
local maxInterval = 7000 --Maximum time between spawning zombies

local zombieData = {skins={13,22,56,67,68,69,70,84,92,97,105,107,108,111,126,127,128,152,162,167,188,192,195,206,209,212,229,230,258,264,274,277,280,287}}
local zombiesChasingMe = {}
local playersDoomed = {}
local timesExecuted = 0
local playersEatable = {}
local playerEated = {}
local colshapes = {}
local mySteps = {}
local nextTargetRequest = 0
local groundReadyAt = 0

-- MELEE APPROACH RANGES
local attackRanges = {[0] = 1.0, [4] = 1.0, [5] = 1.3, [9] = 1.1}
local stuckDelay = 2000
local jumpDelay = 900

local function requestZombieTargets()
	if getTickCount() < nextTargetRequest then return end
	nextTargetRequest = getTickCount() + 2000
	triggerServerEvent("Zday:getZombiesInfo",localPlayer)
end

local function isPassive(player)
	return getElementData(player,"freeroam.passive") == true
end

local function isZombieWeather()
	return getElementData(resourceRoot,"zday.active") == true
end

local function resetZombieChase(zombie,data)
	data.hunting = nil
	data.paths = {}
	data.positions = 0
	data.changingTarget = nil
	data.changingPath = nil
	data.changePathTick = nil
	data.lastPosition = nil
	data.eating = nil
	data.progressPosition = nil
	data.progressTick = nil
	data.nextJumpTick = nil
	data.recoveryUntil = nil
	data.recoverySide = nil
	data.knifeReachTick = nil
	setPedAnimation(zombie)
	for _,control in ipairs({"forwards","backwards","left","right","fire","aim_weapon","sprint","jump"}) do
		setPedControlState(zombie,control,false)
	end
end

local function rot( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

local function getZombieCalculatedPathDistance(zombie)

	local data = zombieData[zombie]
	if not data or not data.paths then return 0 end
	local x,y = getElementPosition(zombie)
	local distance = 0
	for index = (data.positions or 0) + 1,#data.paths do
		local nx,ny = unpack(data.paths[index])
		distance = distance + getDistanceBetweenPoints2D(x,y,nx,ny)
		x,y = nx,ny
	end

	return distance
	
end

local function isZombieChasingMe(zombieToCheck,removeIt)

	for index,zombie in ipairs(zombiesChasingMe) do
		if zombie == zombieToCheck then
			if removeIt then table.remove(zombiesChasingMe,index) end
			return zombie
		end
	end

end

local function onDamage(attacker,weapon,bodypart,loss)

	if type(loss) ~= "number" or loss ~= loss or loss <= 0 or loss == math.huge then return end
	if attacker and isElement(attacker) and attacker == localPlayer then
		triggerServerEvent("Zday:damageZombie",source,attacker,weapon,bodypart,loss)
	end

end

local function onWasted(killer)

	if not zombieData[source] or zombieData[source].doomed then return end
	zombieData[source].doomed = true
	triggerServerEvent("Zday:delayDestroyZombie",source)

end

local function onDestroy()

	isZombieChasingMe(source,true)
	local data = zombieData[source]
	if data and data.syncCol then
		colshapes[data.syncCol] = nil
		if isElement(data.syncCol) then destroyElement(data.syncCol) end
	end
	zombieData[source] = nil

end

local function resetPlayer()

	playersDoomed[source] = nil
	playersEatable[source] = nil
	playerEated[source] = nil
	for zombie,data in pairs(zombieData) do
		if isElement(zombie) and data.target == source then
			resetZombieChase(zombie,data)
		end
	end

end

local function setPlayerEatable(player)

	playersEatable[player] = true

end

local function arePedLegsBlocked(zombie)

	local upperTorsoVec = Vector3(getPedBonePosition(zombie,4))
	local legVec = Vector3(getPedBonePosition(zombie,54))
	local forwardVec = zombie.matrix.position + zombie.matrix.forward * 1.1
	
	local x,y = upperTorsoVec.x,upperTorsoVec.y
	local x2,y2 = forwardVec.x,forwardVec.y
	local notClear = false
	for z=legVec.z,upperTorsoVec.z,0.05 do
		if not isLineOfSightClear(x,y,z,x2,y2,z,true,true,false,true,false,true,true,zombie) then
			notClear=true
			break
		end
	end
	
	return notClear

end

local function checkPlayer(player,col)

	if not isElement(player) then return false end
	if not isElement(col) then return end
	if not colshapes[col] then return false end
	if player.type ~= "player" then return false end
	if isPassive(player) or isPedDead(player) then return false end
	if player.dimension ~= col.dimension then return false end
	if player.interior ~= col.interior then return false end

	return true,colshapes[col]
	
end

local function resetZombieAnimation(zombie)

	if zombie and isElement(zombie) and zombieData[zombie] then
		setPedAnimation(zombie)
		zombieData[zombie].eating = nil
	end

end

local function trackMe()
	
	local zombies = getElementsByType("ped",resourceRoot,true)
	
	for index,zombie in ipairs(zombies) do
		local data = zombieData[zombie]
		if data and not isPedDead(zombie) and not isElement(data.groanSound) and math.random(1,40) == 5 then
			local soundIndex = math.random(1,15)
			if soundIndex == data.lastGroan then soundIndex = soundIndex % 15 + 1 end
			data.lastGroan = soundIndex
			data.groanSound = playSound3D("sounds/zombie"..tostring(soundIndex)..".ogg",zombie.position)
		end
		local variant = tonumber(getElementData(zombie, "zday.variant")) or 0
		local zombieTarget = data and data.target
		if not data or zombieTarget == nil then requestZombieTargets() end
		if isZombieWeather() and isElement(zombieTarget) and not isPassive(zombieTarget) and not isPedDead(zombieTarget) and not isPedDead(zombie) then
			if data.paused then
				resetZombieChase(zombie,data)
				data.paused = nil
				playersDoomed[zombieTarget] = nil
			end
			local lx,ly,lz = getElementPosition(zombieTarget)
			local lVector = Vector3(lx,ly,lz)
			local hVector = Vector3(getPedBonePosition(zombie,6))
			local zVector = Vector3(getElementPosition(zombie))
			local doesZombieSeePlayer = isLineOfSightClear(hVector,lVector,true,false,false,true,false,true,true,zombie)
			local distanceToPlayer = getDistanceBetweenPoints2D(zVector.x,zVector.y,lVector.x,lVector.y)
			local attackRange = attackRanges[getPedWeapon(zombie)] or 1.0
			local inReach = getDistanceBetweenPoints3D(zVector,lVector) < attackRange and doesZombieSeePlayer
			local now = getTickCount()
			local moveState = getPedMoveState(zombie)
			local climbing = moveState == "climb" or moveState == "hanging"
			for _,control in ipairs({"backwards","left","right"}) do
				setPedControlState(zombie,control,false)
			end

			-- RETRY A STALLED CHASE WITHOUT REMOVING THE ZOMBIE
			if data.hunting and not inReach and not data.eating then
				if not data.progressPosition or getDistanceBetweenPoints3D(data.progressPosition,zVector) > 0.25 then
					data.progressPosition = zVector
					data.progressTick = now
				elseif now - data.progressTick >= stuckDelay then
					data.paths = {}
					data.positions = 0
					data.changingPath = nil
					data.changePathTick = nil
					data.progressPosition = zVector
					data.progressTick = now
					if not climbing and moveState ~= "jump" and moveState ~= "fall" and not zombie.inWater then
						data.recoveryUntil = now + 650
						data.recoverySide = data.recoverySide == "left" and "right" or "left"
					end
				end
			else
				data.progressPosition = nil
				data.progressTick = nil
			end


			if zombieData[zombie].hunting then
				if not zombieData[zombie].positions then zombieData[zombie].positions = 0 end
				if not zombieData[zombie].paths then zombieData[zombie].paths = {} end
				local dist = false
				if #zombieData[zombie].paths > 1 then
					local llx,lly,llz = unpack(zombieData[zombie].paths[#zombieData[zombie].paths-1])
					dist = getDistanceBetweenPoints3D(llx,lly,llz,lx,ly,lz)
				end
				if dist and dist > 0.7 then
					table.insert(zombieData[zombie].paths,{lx,ly,lz,getPedControlState(zombieTarget,"jump"),getPedControlState(zombieTarget,"sprint")})
				elseif not dist then
					table.insert(zombieData[zombie].paths,{lx,ly,lz,getPedControlState(zombieTarget,"jump"),getPedControlState(zombieTarget,"sprint")})
				end
				if zombieData[zombie].paths[zombieData[zombie].positions+1] and not zombieData[zombie].eating then
					local nx,ny,nz,jump,sprint = unpack(zombieData[zombie].paths[zombieData[zombie].positions+1])
					local nVector = Vector3(nx,ny,nz)
					local isClear = isLineOfSightClear(zVector,nVector,true,true,false,true,false,true,true,zombie)
					local needToJump = not inReach and not zombie.inWater and (climbing or jump or arePedLegsBlocked(zombie))
					if needToJump and moveState ~= "jump" and moveState ~= "fall" and not (data.recoveryUntil and now < data.recoveryUntil) and now >= (data.nextJumpTick or 0) then
						setPedControlState(zombie,"jump",true)
						data.nextJumpTick = now + jumpDelay
					else
						setPedControlState(zombie,"jump",false)
					end
					local dist = getDistanceBetweenPoints2D(zVector.x,zVector.y,nVector.x,nVector.y)
					local pathDistance = getZombieCalculatedPathDistance(zombie)
					local diff = pathDistance/math.max(distanceToPlayer,0.01)
					if pathDistance > distanceToPlayer and diff > 1.1 and doesZombieSeePlayer then
						zombieData[zombie].paths = {}
						zombieData[zombie].positions = 0
						zombieData[zombie].changingPath = true
						zombieData[zombie].changePathTick = getTickCount()
					end
					if zombieData[zombie].changingPath then
						if (getTickCount() - zombieData[zombie].changePathTick) > 500 then
							zombieData[zombie].changingPath = nil
							zombieData[zombie].changePathTick = nil
						end
					end
					local angle = rot(zVector.x,zVector.y,nVector.x,nVector.y)
					setPedCameraRotation(zombie,-angle)
					setPedControlState(zombie,"forwards",true)
					setPedControlState(zombie,"sprint",variant == 2 or (variant ~= 1 and sprint == true))
					if zombie.inWater then
						setElementRotation(zombie,0,0,angle)
						setPedControlState(zombie,"sprint",true)
					end
					zombieData[zombie].lastPosition = Vector3(getElementPosition(zombie))
					if isClear and dist < 1 then
						zombieData[zombie].positions = zombieData[zombie].positions + 1
					end
				else
					if getDistanceBetweenPoints3D(zVector,lVector) < 1 and ((isPedDead(zombieTarget) or zombieTarget.health<1) and playersEatable[zombieTarget] and not playerEated[zombieTarget]) then
						playerEated[zombieTarget] = true
						zombieData[zombie].eating = true
						setPedAnimation(zombie,"MEDIC","cpr",-1,false,true,false)
						setTimer(resetZombieAnimation,10000,1,zombie)
					end
					setPedControlState(zombie,"forwards",false)
				end
			else
				if doesZombieSeePlayer and not zombieData[zombie].hunting then
					zombieData[zombie].hunting = true
					zombieData[zombie].positions = 0

				end
				if not zombieData[zombie].changingPath then
					setPedControlState(zombie,"forwards",false)
				end
			end
            -- CLOSE THE GAP BEFORE ATTACKING WITH THE EQUIPPED WEAPON
            setPedControlState(zombie,"fire",inReach)
            setPedControlState(zombie,"aim_weapon",false)
            if inReach then
                setPedCameraRotation(zombie,-rot(zVector.x,zVector.y,lx,ly))
                setPedControlState(zombie,"forwards",false)
                setPedControlState(zombie,"jump",false)
                setPedControlState(zombie,"sprint",false)
            elseif doesZombieSeePlayer and getDistanceBetweenPoints3D(zVector,lVector) < 4 and not data.eating then
                setPedCameraRotation(zombie,-rot(zVector.x,zVector.y,lx,ly))
                setPedControlState(zombie,"forwards",true)
                setPedControlState(zombie,"sprint",false)
            end
			-- STEP BACK AND ASIDE BEFORE TRYING A BLOCKED APPROACH AGAIN
			if data.recoveryUntil then
				if now < data.recoveryUntil and not inReach and not climbing and not data.eating then
					setPedControlState(zombie,"forwards",false)
					setPedControlState(zombie,"backwards",true)
					setPedControlState(zombie,data.recoverySide,true)
					setPedControlState(zombie,"sprint",false)
					setPedControlState(zombie,"jump",false)
				else
					data.recoveryUntil = nil
					data.nextJumpTick = nil
					data.progressPosition = zVector
					data.progressTick = now
				end
			end
			-- GIVE KNIFE ZOMBIES A CLOSE RANGE NECK STAB CHANCE
			if inReach and getPedWeapon(zombie) == 4 and zombieTarget == localPlayer and not getPedOccupiedVehicle(localPlayer) then
				data.knifeReachTick = data.knifeReachTick or now
				if now - data.knifeReachTick >= 800 and now >= (playersDoomed[localPlayer] or 0) then
					playersDoomed[localPlayer] = now + 3500
					triggerServerEvent("Zday:murderPlayer",localPlayer,zombie)
				end
			else
				data.knifeReachTick = nil
			end

		else
			if data and not data.paused then
				resetZombieChase(zombie,data)
				data.paused = true
			end
			setPedControlState(zombie,"forwards",false)
			setPedControlState(zombie,"fire",false)
			setPedControlState(zombie,"sprint",false)
			setPedControlState(zombie,"jump",false)
		end
	end
	
	timesExecuted=timesExecuted+1

end

local function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end

-- COUNT IDLE ZOMBIES TOO SO PASSIVE PLAYERS KEEP THE SAME LOCAL LIMIT
local function getLocalZombieCount()
	local count = #zombiesChasingMe
	local x,y,z = getElementPosition(localPlayer)
	for _,zombie in ipairs(getElementsByType("ped",resourceRoot,true)) do
		local data = zombieData[zombie]
		if not isPedDead(zombie) and data and data.target ~= localPlayer and (not isElement(data.target) or isPassive(localPlayer))
			and getElementDimension(zombie) == getElementDimension(localPlayer)
			and getElementInterior(zombie) == getElementInterior(localPlayer) then
			local zx,zy,zz = getElementPosition(zombie)
			if getDistanceBetweenPoints3D(x,y,z,zx,zy,zz) <= 120 then count = count + 1 end
		end
	end
	return count
end

local function spawnZombie()

	if not isZombieWeather() or isPedDead(localPlayer) or getLocalZombieCount() >= maxZombies then
		setTimer(spawnZombie,math.random(minInterval,maxInterval),1)
		return
	end

	local x,y,z = getElementPosition(localPlayer)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	local ground = getGroundPosition(x,y,z + 2)
	local airborne = vehicle and (getVehicleType(vehicle) == "Plane" or getVehicleType(vehicle) == "Helicopter")
		and (not ground or z - ground > 4)
	if airborne or isElementInWater(localPlayer) then
		groundReadyAt = getTickCount() + 5000
		setTimer(spawnZombie,1000,1)
		return
	end
	if getTickCount() < groundReadyAt then
		setTimer(spawnZombie,1000,1)
		return
	end
    local zx,zy,zz
    -- TRY SEVERAL NEARBY POINTS BEFORE WAITING AGAIN
    for attempt = 1,12 do
        local distance = math.random(minDistance,maxDistance)
        local px,py = getPointFromDistanceRotation(x,y,distance,math.random(0,359))
        local floorZ = getGroundPosition(px,py,z + 3)
        local waterZ = getWaterLevel(px,py,z + 3)
        if floorZ and math.abs(floorZ - z) <= 8 and (not waterZ or waterZ < floorZ) then
            local pz = floorZ + 1
            local clear = isLineOfSightClear(x,y,z,px,py,pz,true,false,false,true,false,true,true,localPlayer)
            local open = isLineOfSightClear(px,py,floorZ + 0.2,px,py,floorZ + 2,true,true,false,true,false)
            -- KEEP A CLEAR APPROACH; ALLOW CLOSER POINTS WHEN SPACE IS TIGHT
            if clear and open then
                zx,zy,zz = px,py,pz
                break
            end
        end
    end
    if not zz then return setTimer(spawnZombie,500,1) end

	local zr = rot(x,y,zx,zy)
	local s = zombieData.skins[math.random(1,#zombieData.skins)]
	triggerServerEvent("Zday:spawnZombie",localPlayer,s,zx,zy,zz,zr)
	setTimer(spawnZombie,math.random(minInterval,maxInterval),1)

end

local function setZombieTarget(zombie,targett)

	if not isElement(zombie) or getElementType(zombie) ~= "ped" then return end
	if not zombieData[zombie] then zombieData[zombie] = {} end
	local data = zombieData[zombie]
	if data.target ~= targett then
		resetZombieChase(zombie,data)
		data.target = targett
	end
	if not zombieData[zombie].handled then
		addEventHandler("onClientPedDamage",zombie,onDamage)
		addEventHandler("onClientPedWasted",zombie,onWasted)
		addEventHandler("onClientElementDestroy",zombie,onDestroy)
		zombieData[zombie].handled = true
	end
	
	if not isElement(data.syncCol) then
		local x,y,z = getElementPosition(zombie)
		data.syncCol = createColSphere(x,y,z,80)
		if isElement(data.syncCol) then
			setElementDimension(data.syncCol,getElementDimension(zombie))
			setElementInterior(data.syncCol,getElementInterior(zombie))
			colshapes[data.syncCol] = zombie
			attachElements(data.syncCol,zombie)
			-- TARGET SWITCHING IS HANDLED BY THE SERVER
		end
	end
	
	zombieData[zombie].target = targett

	isZombieChasingMe(zombie,true)
	if targett == localPlayer then
		table.insert(zombiesChasingMe,zombie)
	end

end

local function getZombiesInfo(zombiesReceived)

	for zombie,target in pairs(zombiesReceived) do
		setZombieTarget(zombie,target)
	end

end

local function initScript()

	for _,id in ipairs(zombieData.skins) do
		local txd = engineLoadTXD("skins/"..tostring(id)..".txd")
		engineImportTXD(txd,id)
	end
	
	addEvent("Zday:setZombieTarget",true)
	addEvent("Zday:sendZombiesInfo",true)
	
	addEventHandler("Zday:sendZombiesInfo",localPlayer,getZombiesInfo)
	addEventHandler("Zday:setZombieTarget",resourceRoot,setZombieTarget)
	addEventHandler("onClientPlayerSpawn",root,resetPlayer)
	addEventHandler("onClientPlayerDamage",localPlayer,function(attacker)
		if attacker and zombieData[attacker] and (not isZombieWeather() or isPassive(localPlayer)) then
			cancelEvent()
		end
	end)
	addEventHandler("onClientElementStreamIn",resourceRoot,function()
		if getElementType(source) == "ped" then
			local data = zombieData[source]
			setZombieTarget(source,data and data.target)
			if not data or data.target == nil then requestZombieTargets() end
		end
	end)
	for _,zombie in ipairs(getElementsByType("ped",resourceRoot)) do
		setZombieTarget(zombie,nil)
	end
	
	setTimer(trackMe,100,0)
	setTimer(spawnZombie,math.random(minInterval,maxInterval),1)
	requestZombieTargets()
	
end

addEventHandler("onClientResourceStart",resourceRoot,initScript)
