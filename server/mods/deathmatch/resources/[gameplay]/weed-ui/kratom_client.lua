-- LOCAL OPTICS; SERVER OWNS PURCHASES, GRAVITY AND EXPIRY
local revealed={}
local previousVision
local whiteShader,screenSource,greenShader
local nextWhiteAttempt=0
local pendingDamage=0

local function removeReveal(ped)
    if isElement(ped) and isElement(greenShader) then engineRemoveShaderFromWorldTexture(greenShader,"*",ped) end
    revealed[ped]=nil
end

local function clearReveal()
    for ped in pairs(revealed) do removeReveal(ped) end
end

local function clearVision()
    clearReveal()
    if previousVision then setCameraGoggleEffect(previousVision) previousVision=nil end
    if isElement(whiteShader) then destroyElement(whiteShader) end
    if isElement(screenSource) then destroyElement(screenSource) end
    whiteShader,screenSource=nil,nil
end

local function updateVision()
    local perk=getElementData(localPlayer,"kratom:perk")
    if isPedDead(localPlayer) or (perk~="white" and perk~="green") then
        if previousVision then clearVision() end
        return
    end
    if not previousVision then previousVision=getCameraGoggleEffect() end
    -- KEEP COLOR SIGNALS IN THE SCREEN SOURCE; OUR SHADER PROVIDES NIGHT OPTICS
    local mode=isElement(whiteShader) and "normal" or "nightvision"
    if getCameraGoggleEffect()~=mode then setCameraGoggleEffect(mode,false) end
    if not isElement(whiteShader) and getTickCount()>=nextWhiteAttempt then
        nextWhiteAttempt=getTickCount()+10000
        local w,h=guiGetScreenSize()
        whiteShader=dxCreateShader("kratom_white.fx")
        screenSource=dxCreateScreenSource(w,h)
        if isElement(whiteShader) and isElement(screenSource) then dxSetShaderValue(whiteShader,"screenTexture",screenSource)
        else
            if isElement(whiteShader) then destroyElement(whiteShader) end
            if isElement(screenSource) then destroyElement(screenSource) end
            whiteShader,screenSource=nil,nil
            outputDebugString("KRATOM OPTICS COULD NOT START",1)
        end
    end
    if isElement(whiteShader) then
        dxSetShaderValue(whiteShader,"visionGamma",0.6)
        dxSetShaderValue(whiteShader,"visionStrength",1)
        if perk=="green" then
            dxSetShaderValue(whiteShader,"visionTint",0.68,0.9,0.8)
            dxSetShaderValue(whiteShader,"visionBrightness",1.05)
        else
            dxSetShaderValue(whiteShader,"visionTint",1,1,1)
            dxSetShaderValue(whiteShader,"visionBrightness",1.45)
        end
    end
end

local nextRevealAttempt=0
local function refreshReveal()
    local perk=getElementData(localPlayer,"kratom:perk")
    if isPedDead(localPlayer) or (perk~="green" and perk~="white") then clearReveal() return end
    local zombies=getResourceFromName("new-zombies-zday")
    if not zombies or getResourceState(zombies)~="running" then clearReveal() return end
    if not isElement(greenShader) and getTickCount()>=nextRevealAttempt then
        nextRevealAttempt=getTickCount()+10000
        greenShader=dxCreateShader("kratom_zombie.fx",0,0,true,"ped")
    end
    if isElement(greenShader) then
        if perk=="white" then dxSetShaderValue(greenShader,"zombieColor",1,0.05,0.1)
        else dxSetShaderValue(greenShader,"zombieColor",0.05,1,0.1) end
    end
    local seen={}
    for _,ped in ipairs(getElementsByType("ped",getResourceDynamicElementRoot(zombies),true)) do
        if not isPedDead(ped) and getElementInterior(ped)==getElementInterior(localPlayer)
            and getElementDimension(ped)==getElementDimension(localPlayer) then
            seen[ped]=true
            if not revealed[ped] or (not revealed[ped].shaded and isElement(greenShader)) then
                local shaded=isElement(greenShader) and engineApplyShaderToWorldTexture(greenShader,"*",ped)
                revealed[ped]={shaded=shaded}
            end
        end
    end
    for ped in pairs(revealed) do if not seen[ped] then removeReveal(ped) end end
end
setTimer(refreshReveal,500,0)
addEventHandler("onClientElementStreamIn",root,function()
    if getElementType(source)=="ped" then refreshReveal() end
end)
addEventHandler("onClientElementStreamOut",root,function() if revealed[source] then removeReveal(source) end end)
addEventHandler("onClientElementDestroy",root,function() revealed[source]=nil end)

addEventHandler("onClientRender",root,function()
    updateVision()
    if isElement(whiteShader) and isElement(screenSource) then
        dxUpdateScreenSource(screenSource,true)
        local w,h=guiGetScreenSize()
        dxDrawImage(0,0,w,h,whiteShader)
    end
    for ped,data in pairs(revealed) do
        if not isElement(ped) or isPedDead(ped) or (getElementData(localPlayer,"kratom:perk")~="green" and getElementData(localPlayer,"kratom:perk")~="white")
            or getElementInterior(ped)~=getElementInterior(localPlayer) or getElementDimension(ped)~=getElementDimension(localPlayer) then removeReveal(ped)
        elseif not data.shaded and isElementStreamedIn(ped) then
            local x,y,z=getElementPosition(ped)
            local sx,sy=getScreenFromWorldPosition(x,y,z+1.1)
            if sx then dxDrawText("Z",sx-5,sy-16,sx+5,sy-5,getElementData(localPlayer,"kratom:perk")=="white" and tocolor(255,40,50,235) or tocolor(80,255,110,235),1,"default-bold","center","center") end
        end
    end
end,false,"high")

addEventHandler("onClientPlayerDamage",localPlayer,function(_,_,bodypart,loss)
    if wasEventCancelled() or getElementData(localPlayer,"kratom:perk")~="purple" then return end
    cancelEvent()
    if type(loss)=="number" and loss==loss and loss>0 and loss<math.huge then
        local armor=getPedArmor(localPlayer)
        if bodypart~=9 and armor>0 then
            local drain=({soft=1,reinforced=0.5,hard=0.25})[getElementData(localPlayer,"booty:armorTier")] or 1
            local absorbed=math.min(loss,armor/drain)
            setPedArmor(localPlayer,math.max(0,armor-absorbed*drain))
            loss=loss-absorbed
        end
        pendingDamage=math.min(1000,pendingDamage+loss)
    end
end,false,"low")

-- THE ATTACKER'S CLIENT MUST ABORT NATIVE STEALTH KILLS
addEventHandler("onClientPlayerStealthKill",localPlayer,function(target)
    if isElement(target) and getElementData(target,"kratom:perk")=="purple" then cancelEvent() end
end)

addEventHandler("onClientPlayerHeliKilled",localPlayer,function()
    if getElementData(localPlayer,"kratom:perk")=="purple" then
        cancelEvent()
        triggerServerEvent("kratom:fatalHit",resourceRoot)
    end
end)

addEventHandler("onClientElementDataChange",localPlayer,function(key)
    if key=="kratom:perk" then pendingDamage=0 clearReveal() updateVision() refreshReveal() end
end)

setTimer(function()
    if pendingDamage>0 and getElementData(localPlayer,"kratom:perk")=="purple" then
        triggerServerEvent("kratom:damageHit",resourceRoot,pendingDamage)
    end
    pendingDamage=0
end,250,0)

addEventHandler("onClientPreRender",root,function()
    if getElementData(localPlayer,"kratom:perk")~="white" or isPedDead(localPlayer) or isPedInVehicle(localPlayer)
        or not isPedOnGround(localPlayer) or isElementFrozen(localPlayer) then return end
    local x,y,z=getElementVelocity(localPlayer)
    local speed=math.sqrt(x*x+y*y)
    if speed>0.025 then setElementVelocity(localPlayer,x*0.025/speed,y*0.025/speed,z) end
end)

addEventHandler("onClientResourceStop",resourceRoot,function()
    clearVision()
    if isElement(greenShader) then destroyElement(greenShader) end
end)
