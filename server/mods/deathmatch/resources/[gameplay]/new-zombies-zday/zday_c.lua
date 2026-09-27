local maxZombies = 10 --Max zombies to chase local player
local minDistance = 10 --Minium distance from player to keep zombies spawning
local maxDistance = 30 --Maximum distance to spawn zombies
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
	data.lastPosition = nil
	data.eating = nil
	setPedAnimation(zombie)
	for _,control in ipairs({"forwards","fire","sprint","jump"}) do
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

local function murderPlayerByZombie(player,zombie)

	if not isZombieWeather() or isPassive(player) or isPedDead(player) then return end
	playSound3D("sounds/mgroan"..tostring(math.random(1,10))..".ogg",zombie.position)
	if player == localPlayer then triggerServerEvent("Zday:murderPlayer",localPlayer,zombie) end

end

local function arePedLegsBlocked(zombie)

	local upperTorsoVec = Vector3(getPedBonePosition(zombie,4))
	local legVec = Vector3(getPedBonePosition(zombie,54))
	local forwardVec = zombie.matrix.position + (zombie.matrix.forward/2)
	
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

local function comp(w1,w2)

	if w1[2] < w2[2] then
		return true
	end
	
	return false

end

local function getNewTarget(zombie,excludedTarget)

	local data = zombieData[zombie]
	if not data or not isElement(data.syncCol) then return false end
	local col = data.syncCol
	local players = getElementsWithinColShape(col,"player")
	local possibleTargets = {}
	local alternativeReturn = false
	local isClear = false
	for index,player in ipairs(players) do
		if checkPlayer(player,col) and player ~= excludedTarget and player ~= zombieData[zombie].target then
			local distance = getDistanceBetweenPoints2D(zombie.position,player.position)
			if distance < 80 then
				table.insert(possibleTargets,{player,distance})
				isClear = isLineOfSightClear(zombie.position,player.position,true,false,false,true,false,true,true,zombie)
				alternativeReturn=true
			end
		end
	end
	
	if not alternativeReturn then return false end
	
	table.sort(possibleTargets,comp)
	local target,distance2 = unpack(possibleTargets[1])
	isClear = isLineOfSightClear(zombie.position,target.position,true,false,false,true,false,true,true,zombie)
	return target,isClear,distance2

end

local function resetZombieAnimation(zombie)

	if zombie and isElement(zombie) and zombieData[zombie] then
		setPedAnimation(zombie)
		zombieData[zombie].eating = nil
	end

end

local function findNewTarget(player)

	if not isZombieWeather() then return end
	local valid,zombie = checkPlayer(player,source)
	if not valid then return end
	if player ~= zombieData[zombie].target then return end
	if player ~= localPlayer then return end
	local newTarget = getNewTarget(zombie)
	
	if newTarget and newTarget ~= localPlayer and newTarget ~= zombieData[zombie].target then
		triggerServerEvent("Zday:setZombieNewTarget",zombie,newTarget)
	elseif not zombieData[zombie].doomed then
		zombieData[zombie].doomed = true
		triggerLatentServerEvent("Zday:destroyZombie",5000,true,zombie)
	end

end

local function trackMe()
	
	local zombies = getElementsByType("ped",resourceRoot,true)
	
	for index,zombie in ipairs(zombies) do
		if math.random(1,40) == 5 and isPedDead(zombie) == false then playSound3D("sounds/mgroan"..tostring(math.random(1,10))..".ogg",zombie.position) end
		local data = zombieData[zombie]
		local zombieTarget = data and data.target
		if not isElement(zombieTarget) then requestZombieTargets() end
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
			if timesExecuted%5 == 0 and zombieData[zombie].target == localPlayer then
				local newTarget,doesSee,distance = getNewTarget(zombie)
				if newTarget and doesSee and distance < distanceToPlayer and newTarget ~= zombieData[zombie].target then
					triggerServerEvent("Zday:setZombieNewTarget",zombie,newTarget)
				end
			end
			if zombieData[zombie].target == localPlayer and doesZombieSeePlayer == false and isPedDead(zombieTarget)==false then
				local newTarget,doesSee = getNewTarget(zombie,localPlayer)
				if newTarget and doesSee and newTarget ~= zombieData[zombie].target then
					triggerServerEvent("Zday:setZombieNewTarget",zombie,newTarget)
				end
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
					local notMoving = false
					if zombieData[zombie].lastPosition then
						local dist = getDistanceBetweenPoints3D(zombieData[zombie].lastPosition,zVector)
						if dist < 0.01 then
							local action = math.random(1,2)
							if action == 1 then
								setPedControlState(zombie,"fire",true)
							elseif action == 2 then
								notMoving = true
							end
						else
							setPedControlState(zombie,"fire",false)
						end
					end
					local needToJump = (jump or getPedSimplestTask(zombie) == "TASK_SIMPLE_CLIMB" or arePedLegsBlocked(zombie) or notMoving)
					if needToJump then
						if (getPedMoveState(zombie) ~= "jump" or getPedMoveState(zombie) ~= "climb") then setPedControlState(zombie,"forwards",false) end
						if sprint then setPedControlState(zombie,"sprint",true) end
						setPedControlState(zombie,"jump",true)
					else
						setPedControlState(zombie,"sprint",false)
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
					if zombie.inWater then
						setElementRotation(zombie,0,0,angle)
						setPedControlState(zombie,"sprint",true)
					elseif not sprint then
						setPedControlState(zombie,"sprint",false)
					end
					zombieData[zombie].lastPosition = Vector3(getElementPosition(zombie))
					if isClear and dist < 1 then
						zombieData[zombie].positions = zombieData[zombie].positions + 1
					end
				else
					if zombieTarget == localPlayer and getDistanceBetweenPoints3D(zVector,lVector) < 1 and getTickCount() >= (playersDoomed[zombieTarget] or 0) then
						murderPlayerByZombie(zombieTarget,zombie)
						playersDoomed[zombieTarget] = getTickCount() + 1500
					elseif getDistanceBetweenPoints3D(zVector,lVector) < 1 and ((isPedDead(zombieTarget) or zombieTarget.health<1) and playersEatable[zombieTarget] and not playerEated[zombieTarget]) then
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
				elseif not zombieData[zombie].hunting then
					local newTarget,doesSee = getNewTarget(zombie,localPlayer)
					if newTarget and doesSee and not zombieData[zombie].changingTarget then
						triggerServerEvent("Zday:setZombieNewTarget",zombie,newTarget)
						zombieData[zombie].changingTarget = true
					end
				end
				if not zombieData[zombie].changingPath then
					setPedControlState(zombie,"forwards",false)
				end
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

local function spawnZombie()

	if not isZombieWeather() or isPassive(localPlayer) or isPedDead(localPlayer) or #zombiesChasingMe >= maxZombies then
		setTimer(spawnZombie,math.random(minInterval,maxInterval),1)
		return
	end

	local x,y,z = getElementPosition(localPlayer)
	local dist = math.random(minDistance,maxDistance)
	local _,_,_,_,_,_,_,fov = getCameraMatrix()
	local cr = getPedCameraRotation(localPlayer)+(getPedControlState(localPlayer,"look_behind") and 0 or 180)
	if cr > 360 then cr = cr-360 end
	local r = math.random(cr-fov,cr+fov)
	local zx,zy = getPointFromDistanceRotation(x,y,dist,r)
	local zz = false
	for tz = z,550 do
		local newZ = getGroundPosition(zx,zy,tz)
		if newZ and newZ ~= 0 then
			zz = newZ+1
			break
		end
	end
	if not zz then zz = z+3 end
	if not isLineOfSightClear(x,y,z,zx,zy,zz,true,false,false,true,false,true,true,localPlayer) then return setTimer(spawnZombie,500,1) end
	local zr = rot(x,y,zx,zy)
	local s = zombieData.skins[math.random(1,#zombieData.skins)]
	triggerServerEvent("Zday:spawnZombie",localPlayer,s,zx,zy,zz,zr)
	setTimer(spawnZombie,math.random(minInterval,maxInterval),1)

end

local function lookForNewTarget(excludedTarget)

	local newTarget = getNewTarget(source,excludedTarget,true)
	
	if isElement(newTarget) and zombieData[source].target ~= newTarget then
		triggerServerEvent("Zday:setZombieNewTarget",source,newTarget)
	elseif not zombieData[source].doomed then
		zombieData[source].doomed = true
		triggerLatentServerEvent("Zday:destroyZombie",5000,true,source)
	end

end

local function setZombieTarget(zombie,targett)

	if not isElement(zombie) or getElementType(zombie) ~= "ped" then return end
	if not zombieData[zombie] then zombieData[zombie] = {} end
	local data = zombieData[zombie]
	if data.target ~= targett then
		data.target = targett
		data.hunting = nil
		data.paths = {}
		data.positions = 0
		data.changingTarget = nil
		data.changingPath = nil
		data.lastPosition = nil
	end
	if not zombieData[zombie].handled then
		addEventHandler("onClientPedDamage",zombie,onDamage)
		addEventHandler("onClientPedWasted",zombie,onWasted)
		addEventHandler("onClientElementDestroy",zombie,onDestroy)
		addEventHandler("Zday:askForNewTarget",zombie,lookForNewTarget)
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
			addEventHandler("onClientColShapeLeave",data.syncCol,findNewTarget)
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
	
	addEvent("Zday:askForNewTarget",true)
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
			if not data or not isElement(data.target) then requestZombieTargets() end
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
