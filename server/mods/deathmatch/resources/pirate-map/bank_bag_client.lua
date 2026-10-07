-- FIXED TORSO ATTACHMENT
local bags={}

local function trackBag(object)
    if getElementType(object)~="object" then return end
    local owner=getElementData(object,"bank:bagOwner")
    if isElement(owner) and not bags[object] then
        local visual=createObject(1550,0,0,-1000)
        if not isElement(visual) then return end
        setObjectScale(visual,0.45)
        setElementCollisionsEnabled(visual,false)
        setElementFrozen(visual,true)
        setElementDoubleSided(visual,true)
        setElementAlpha(visual,0)
        bags[object]={owner=owner,visual=visual,hidden=true}
    end
end

local bagOffset={{0,0,-1},{0,1,0},{1,0,0},{-0.2,-0.22,0}}

addEventHandler("onClientResourceStart",resourceRoot,function()
    for _,object in ipairs(getElementsByType("object",resourceRoot)) do trackBag(object) end
end)
addEventHandler("onClientElementDataChange",resourceRoot,function(key)
    if key=="bank:bagOwner" then trackBag(source) end
end)
addEventHandler("onClientElementStreamIn",resourceRoot,function() trackBag(source) end)
addEventHandler("onClientElementStreamOut",resourceRoot,function()
    if bags[source] then
        setElementAlpha(bags[source].visual,0)
        bags[source].hidden=true
    end
end)
addEventHandler("onClientElementDestroy",resourceRoot,function()
    local data=bags[source]
    bags[source]=nil
    if data and isElement(data.visual) then destroyElement(data.visual) end
end)

addEventHandler("onClientPedsProcessed",root,function()
    for object,data in pairs(bags) do
        local player=data.owner
        if not isElement(object) or not isElement(player) then
            bags[object]=nil
            if isElement(data.visual) then destroyElement(data.visual) end
        elseif isElementStreamedIn(object) then
            local bone=isElementStreamedIn(player) and getElementBoneMatrix(player,3)
            if bone then
                local visual=data.visual
                setElementInterior(visual,getElementInterior(player))
                setElementDimension(visual,getElementDimension(player))
                if data.hidden then setElementAlpha(visual,255) data.hidden=false end
                data.relative=bagOffset
                if data.relative then
                    local matrix={}
                    for row=1,4 do
                        matrix[row]={}
                        for axis=1,3 do
                            matrix[row][axis]=data.relative[row][1]*bone[1][axis]
                                +data.relative[row][2]*bone[2][axis]+data.relative[row][3]*bone[3][axis]
                                +(row==4 and bone[4][axis] or 0)
                        end
                        matrix[row][4]=row==4 and 1 or 0
                    end
                    setElementMatrix(visual,matrix)
                end
            elseif not data.hidden then
                setElementAlpha(data.visual,0)
                data.hidden=true
            end
        end
    end
end)
