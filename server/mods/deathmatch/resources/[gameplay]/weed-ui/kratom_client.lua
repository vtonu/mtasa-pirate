-- LOCAL OPTICS; SERVER OWNS PURCHASES, GRAVITY AND EXPIRY
local revealed={}
local previousVision
local whiteShader,screenSource,greenShader
local nextFatalReport=0
local nextWhiteAttempt=0

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
    if getCameraGoggleEffect()~="nightvision" then setCameraGoggleEffect("nightvision") end
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
        if perk=="green" then
            dxSetShaderValue(whiteShader,"visionTint",0.68,0.9,0.8)
            dxSetShaderValue(whiteShader,"visionBrightness",1.05)
        else
            dxSetShaderValue(whiteShader,"visionTint",1,1,1)
            dxSetShaderValue(whiteShader,"visionBrightness",1.45)
        end
    end
end

addEvent("kratom:reveal",true)
addEventHandler("kratom:reveal",resourceRoot,function(targets)
    clearReveal()
    if getElementData(localPlayer,"kratom:perk")~="green" or type(targets)~="table" then return end
    if not isElement(greenShader) then greenShader=dxCreateShader("kratom_zombie.fx",0,0,true,"ped") end
    local untilTick=getTickCount()+3000
    for _,ped in ipairs(targets) do
        if isElement(ped) then
            local shaded=isElement(greenShader) and engineApplyShaderToWorldTexture(greenShader,"*",ped)
            revealed[ped]={expires=untilTick,shaded=shaded}
        end
    end
end)

addEventHandler("onClientRender",root,function()
    updateVision()
    if isElement(whiteShader) and isElement(screenSource) then
        dxUpdateScreenSource(screenSource,true)
        local w,h=guiGetScreenSize()
        dxDrawImage(0,0,w,h,whiteShader)
    end
    local now=getTickCount()
    for ped,data in pairs(revealed) do
        if now>=data.expires or not isElement(ped) or isPedDead(ped) or getElementData(localPlayer,"kratom:perk")~="green"
            or getElementInterior(ped)~=getElementInterior(localPlayer) or getElementDimension(ped)~=getElementDimension(localPlayer) then removeReveal(ped)
        elseif not data.shaded and isElementStreamedIn(ped) then
            local x,y,z=getElementPosition(ped)
            local sx,sy=getScreenFromWorldPosition(x,y,z+1.1)
            if sx then dxDrawText("Z",sx-5,sy-16,sx+5,sy-5,tocolor(184,140,255,235),1,"default-bold","center","center") end
        end
    end
end,false,"high")

addEventHandler("onClientPlayerDamage",localPlayer,function(_,_,bodypart,loss)
    if wasEventCancelled() or getElementData(localPlayer,"kratom:perk")~="purple" then return end
    if bodypart~=9 and (not loss or loss<getElementHealth(localPlayer)) then return end
    cancelEvent()
    if getTickCount()>=nextFatalReport then
        nextFatalReport=getTickCount()+250
        triggerServerEvent("kratom:fatalHit",resourceRoot)
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
    if key=="kratom:perk" then clearReveal() updateVision() end
end)

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
