-- BOUNTY BANNER; OTHER MISSION PROMPTS STAY TEXT ONLY
local panel=svgCreate(500,52,[[<svg xmlns="http://www.w3.org/2000/svg" width="500" height="52"><rect x="1" y="1" width="498" height="50" rx="5" fill="#131313" fill-opacity=".35" stroke="#7fffd4" stroke-opacity=".22"/></svg>]])
local alertPanel=svgCreate(500,52,[[<svg xmlns="http://www.w3.org/2000/svg" width="500" height="52"><rect x="1" y="1" width="498" height="50" rx="5" fill="#dc4848" fill-opacity=".22" stroke="#ff7777" stroke-opacity=".3"/></svg>]])
local claimed,claimUntil
local completed,completeUntil
local fullRobbery

addEvent("bank:cashout",true)
addEventHandler("bank:cashout",resourceRoot,function(reward,full)
    completed,completeUntil=tonumber(reward),getTickCount()+6000
    fullRobbery=full==true
    playSoundFrontEnd(46)
end)

addEvent("bank:bountyClaim",true)
addEventHandler("bank:bountyClaim",resourceRoot,function(reward)
    claimed,claimUntil=tonumber(reward),getTickCount()+6000
end)

addEventHandler("onClientRender",root,function()
    local notice=getElementData(resourceRoot,"bank:bounties")
    local own=getElementData(localPlayer,"bank:bounty")
    local title,detail
    if completed and getTickCount()<completeUntil then
        title=(fullRobbery and "MISSION COMPLETE | +$" or "CASH SECURED | +$")..completed
        detail="RED COUNTY BANK"
    elseif claimed and getTickCount()<claimUntil then
        title="BOUNTY CLAIMED  +$"..claimed
        detail="RED COUNTY BANK"
    elseif type(own)=="table" then
        title="BOUNTY $"..tostring(own.amount)
        detail="SURVIVE THE ROBBERY"
        if type(getElementData(localPlayer,"bank:pending"))=="table" then
            detail="LOSE THE STARS"
        end
    elseif type(notice)=="table" and notice.targets>0 then
        title="BANK BOUNTIES $"..tostring(notice.total)
        detail="HUNT THE BLINKING SKULLS"
    end
    if not title then return end
    local w,h=guiGetScreenSize()
    local width=w*0.17
    local height=math.max(24,h*0.027)
    local starSize=math.max(18,math.min(36,h*0.042))
    local left,top=w*0.78,h*0.23+starSize+math.max(8,h*0.008)
    if getPlayerWantedLevel(localPlayer)==0 then top=h*0.23+math.max(8,h*0.008) end
    if panel then dxDrawImage(left,top,width,height,panel) end
    if alertPanel and type(own)=="table" and not (completed and getTickCount()<completeUntil) then
        local pulse=18+math.floor((math.sin(getTickCount()/900)+1)*18)
        dxDrawImage(left,top,width,height,alertPanel,0,0,0,tocolor(255,255,255,pulse))
    end
    local inset=width*0.04
    local text="★ "..title.." ★ "..detail.." ★"
    local scale=math.min(1,(width-inset*2)/dxGetTextWidth(text,1,"default-bold"))
    dxDrawText(text,left+inset,top,left+width-inset,top+height,
        tocolor(127,255,212,235),scale,"default-bold","center","center")
end)
