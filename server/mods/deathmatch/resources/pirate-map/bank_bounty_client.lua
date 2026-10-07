-- BOUNTY BANNER; OTHER MISSION PROMPTS STAY TEXT ONLY
local panel=svgCreate(500,52,[[<svg xmlns="http://www.w3.org/2000/svg" width="500" height="52"><rect x="1" y="1" width="498" height="50" rx="5" fill="#131313" fill-opacity=".66" stroke="#7fffd4" stroke-opacity=".22"/><path d="M12 14V38" stroke="#7fffd4" stroke-opacity=".55"/></svg>]])
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
        if type(getElementData(localPlayer,"bank:pending"))=="table" then
            detail="LOSE YOUR STARS TO KEEP THE CASH."
        end
    elseif type(notice)=="table" and notice.targets>0 then
        title=notice.targets>1 and "MULTIPLE PLAYERS HAVE BOUNTIES" or "A BANK ROBBER HAS A BOUNTY"
        detail="HUNT THE BLINKING SKULLS AT RED COUNTY BANK  |  $"..tostring(notice.total).." AVAILABLE"
    end
    if not title then return end
    local w,h=guiGetScreenSize()
    local width=math.min(500,w*0.42)
    local height=width*52/500
    local left,top=(w-width)/2,h*0.035
    if panel then dxDrawImage(left,top,width,height,panel) end
    local inset=width*0.04
    local scale=math.min(width/500,(width-inset-24)/dxGetTextWidth(title,1,"unifont"))
    dxDrawText(title,left+inset,top+height*0.18,left+width-20,top+height*0.55,
        tocolor(127,255,212,235),scale,"unifont","left","center")
    local small=math.min(width/650,(width-inset-24)/dxGetTextWidth(detail,1,"unifont"))
    dxDrawText(detail,left+inset,top+height*0.55,left+width-20,top+height*0.84,
        tocolor(127,255,212,180),small,"unifont","left","center")
end)
