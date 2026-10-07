-- BANK PRESSURE FOLLOWS WANTED STARS
function isBankZombieSlowElement(element)
    if not isElement(element) or getElementInterior(element)~=0
        or getElementDimension(element)~=0 then return false end
    local x,y,z=getElementPosition(element)
    return x>=2300 and x<=2325 and y>=-23 and y<=5 and z>=24 and z<=30
end

function getBankZombiePressure(player)
    if not isElement(player) or isPedDead(player) or getElementInterior(player)~=0
        or getElementDimension(player)~=0 then return false end
    local robbery=getElementData(player,"bank:robbery")
    if type(robbery)~="table" or robbery.state=="hold" then return false end
    local x,y,z=getElementPosition(player)
    if (x-2312.68408)^2+(y+8.94955)^2>45^2 or z<20 or z>35 then return false end
    local wanted=localPlayer and getPlayerWantedLevel() or getPlayerWantedLevel(player)
    local stars=math.max(0,math.min(6,wanted))
    if stars==0 then return false end
    return {cap=8+stars*2,minDelay=math.max(500,2000-stars*250),
        maxDelay=math.max(1000,7000-stars*900)}
end
