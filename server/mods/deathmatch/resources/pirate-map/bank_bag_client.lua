-- FOLLOW THE TORSO WHILE KEEPING THE ORIGINAL BAG OFFSET
local bags={}

local function trackBag(object)
    if getElementType(object)~="object" then return end
    local owner=getElementData(object,"bank:bagOwner")
    if isElement(owner) then bags[object]={owner=owner} end
end

local function calibrateBag(player,bone)
    local matrix=getElementMatrix(player)
    if not matrix then return end
    local relative={}
    for row=1,3 do
        relative[row]={}
        for axis=1,3 do
            relative[row][axis]=matrix[row][1]*bone[axis][1]
                +matrix[row][2]*bone[axis][2]+matrix[row][3]*bone[axis][3]
        end
    end
    local delta={}
    for axis=1,3 do
        delta[axis]=matrix[4][axis]-0.25*matrix[2][axis]+0.45*matrix[3][axis]-bone[4][axis]
    end
    relative[4]={}
    for axis=1,3 do
        relative[4][axis]=delta[1]*bone[axis][1]+delta[2]*bone[axis][2]+delta[3]*bone[axis][3]
    end
    return relative
end

addEventHandler("onClientResourceStart",resourceRoot,function()
    for _,object in ipairs(getElementsByType("object",resourceRoot)) do trackBag(object) end
end)
addEventHandler("onClientElementDataChange",resourceRoot,function(key)
    if key=="bank:bagOwner" then trackBag(source) end
end)
addEventHandler("onClientElementStreamIn",resourceRoot,function() trackBag(source) end)
addEventHandler("onClientElementStreamOut",resourceRoot,function()
    if bags[source] then bags[source].relative=nil end
end)
addEventHandler("onClientElementDestroy",resourceRoot,function() bags[source]=nil end)

addEventHandler("onClientPedsProcessed",root,function()
    for object,data in pairs(bags) do
        local player=data.owner
        if not isElement(object) or not isElement(player) then bags[object]=nil
        elseif isElementStreamedIn(object) then
            local bone=isElementStreamedIn(player) and getElementBoneMatrix(player,3)
            if bone then
                if data.hidden then setElementAlpha(object,255) data.hidden=false end
                data.relative=data.relative or calibrateBag(player,bone)
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
                    setElementMatrix(object,matrix)
                end
            elseif not data.hidden then
                setElementAlpha(object,0)
                data.hidden=true
            end
        end
    end
end)
