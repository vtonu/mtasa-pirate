-- PRIVATE VISUAL COPIES; EVERY CLIENT SEES THE SAME PERK GOGGLES
local goggles={}
local function clear(player)
    if isElement(goggles[player]) then destroyElement(goggles[player]) end
    goggles[player]=nil
end

local function update(player)
    if getElementType(player)~="player" then return end
    local perk=getElementData(player,"kratom:perk")
    if isPedDead(player) or (perk~="white" and perk~="green") or not isElementStreamedIn(player) then
        clear(player)
    elseif not isElement(goggles[player]) then
        local object=createObject(368,0,0,-1000)
        if not object then return end
        setElementCollisionsEnabled(object,false)
        setElementFrozen(object,true)
        setElementDoubleSided(object,true)
        setElementAlpha(object,0)
        goggles[player]=object
    end
end

addEventHandler("onClientResourceStart",resourceRoot,function()
    for _,player in ipairs(getElementsByType("player")) do update(player) end
end)
addEventHandler("onClientElementDataChange",root,function(key)
    if key=="kratom:perk" then update(source) end
end)
addEventHandler("onClientElementStreamIn",root,function() update(source) end)
addEventHandler("onClientElementStreamOut",root,function() clear(source) end)
addEventHandler("onClientElementDestroy",root,function() clear(source) end)
addEventHandler("onClientPlayerWasted",root,function() clear(source) end)
addEventHandler("onClientResourceStop",resourceRoot,function()
    for player in pairs(goggles) do clear(player) end
end)

-- HEAD BONE; KEEP WEAPON AND PARACHUTE SLOTS INTACT
local offset={{1,0,0},{0,1,0},{0,0,1},{0,0.08,0.02}}
addEventHandler("onClientPedsProcessed",root,function()
    for player,object in pairs(goggles) do
        if not isElement(player) or isPedDead(player) then
            clear(player)
        else
            local bone=getElementBoneMatrix(player,8)
            local visible=bone and getElementInterior(player)==getElementInterior(localPlayer)
                and getElementDimension(player)==getElementDimension(localPlayer)
            setElementAlpha(object,visible and getElementAlpha(player) or 0)
            if visible then
                setElementInterior(object,getElementInterior(player))
                setElementDimension(object,getElementDimension(player))
                local matrix={}
                for row=1,4 do
                    matrix[row]={}
                    for axis=1,3 do
                        matrix[row][axis]=offset[row][1]*bone[1][axis]
                            +offset[row][2]*bone[2][axis]+offset[row][3]*bone[3][axis]
                            +(row==4 and bone[4][axis] or 0)
                    end
                    matrix[row][4]=row==4 and 1 or 0
                end
                setElementMatrix(object,matrix)
            end
        end
    end
end)
