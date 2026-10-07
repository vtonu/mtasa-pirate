-- BOUNTY BANNER; OTHER MISSION PROMPTS STAY TEXT ONLY
local panel=svgCreate(800,92,[[<svg xmlns="http://www.w3.org/2000/svg" width="800" height="92"><defs><linearGradient id="bg"><stop stop-color="#123334"/><stop offset=".55" stop-color="#111c25"/><stop offset="1" stop-color="#30271e"/></linearGradient></defs><rect x="1" y="1" width="798" height="90" rx="14" fill="url(#bg)" fill-opacity=".96" stroke="#78dac3" stroke-opacity=".55"/><path d="M24 1H776" stroke="#e8ba70" stroke-width="2"/><path d="M20 70H54M746 70H780" stroke="#78dac3" stroke-opacity=".65"/><circle cx="47" cy="42" r="22" fill="#7fffd4" fill-opacity=".12"/><path d="M36 46V34Q47 23 58 34V46L53 51V59H41V51Z" fill="#e8ba70"/><circle cx="42" cy="40" r="3" fill="#173034"/><circle cx="52" cy="40" r="3" fill="#173034"/><path d="M47 44L44 49H50Z" fill="#173034"/></svg>]])
local claimed,claimUntil

addEvent("bank:bountyClaim",true)
addEventHandler("bank:bountyClaim",resourceRoot,function(reward)
    claimed,claimUntil=tonumber(reward),getTickCount()+6000
end)

addEventHandler("onClientRender",root,function()
    local notice=getElementData(resourceRoot,"bank:bounties")
    local own=getElementData(localPlayer,"bank:bounty")
    local title,detail
    if claimed and getTickCount()<claimUntil then
        title="BOUNTY CLAIMED  +$"..claimed
        detail="RED COUNTY BANK"
    elseif type(own)=="table" then
        title="YOU ARE MARKED  |  BOUNTY $"..tostring(own.amount)
        detail="HUNTERS CAN SEE YOUR SKULL. SURVIVE THE ROBBERY."
    elseif type(notice)=="table" and notice.targets>0 then
        title=notice.targets>1 and "MULTIPLE PLAYERS HAVE BOUNTIES" or "A BANK ROBBER HAS A BOUNTY"
        detail="HUNT THE BLINKING SKULLS AT RED COUNTY BANK  |  $"..tostring(notice.total).." AVAILABLE"
    end
    if not title then return end
    local w,h=guiGetScreenSize()
    local width=math.min(800,w*0.62)
    local height=width*92/800
    local left,top=(w-width)/2,h*0.035
    if panel then dxDrawImage(left,top,width,height,panel) end
    local inset=width*0.10
    local scale=math.min(width/800,(width-inset-24)/dxGetTextWidth(title,1,"unifont"))
    dxDrawText(title,left+inset,top+height*0.18,left+width-20,top+height*0.55,
        tocolor(232,186,112,255),scale,"unifont","left","center")
    local small=math.min(width/1000,(width-inset-24)/dxGetTextWidth(detail,1,"unifont"))
    dxDrawText(detail,left+inset,top+height*0.55,left+width-20,top+height*0.84,
        tocolor(127,255,212,245),small,"unifont","left","center")
end)
