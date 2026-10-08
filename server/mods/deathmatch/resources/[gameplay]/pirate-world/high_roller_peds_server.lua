-- HIGH ROLLER PEDS WATCH NEARBY PLAYERS
local guards={}

addEventHandler("onResourceStart",resourceRoot,function()
    for _,id in ipairs({"highRollerMafiaEnforcer","highRollerMafiaBouncer"}) do
        local ped=getElementByID(id)
        if isElement(ped) then
            local _,_,rotation=getElementRotation(ped)
            guards[#guards+1]={ped=ped,rotation=rotation,enforcer=id=="highRollerMafiaEnforcer"}
            setElementFrozen(ped,true)
        end
    end
end)

setTimer(function()
    local players=getElementsByType("player")
    for _,guard in ipairs(guards) do
        local ped=guard.ped
        if isElement(ped) and not isPedDead(ped) then
            local x,y,z=getElementPosition(ped)
            local visitor,distance=nil,3.5
            for _,player in ipairs(players) do
                if not isPedDead(player) and not getPedOccupiedVehicle(player)
                    and getElementInterior(player)==getElementInterior(ped)
                    and getElementDimension(player)==getElementDimension(ped) then
                    local px,py,pz=getElementPosition(player)
                    local near=getDistanceBetweenPoints2D(x,y,px,py)
                    if near<distance and math.abs(pz-z)<=2 then visitor,distance=player,near end
                end
            end
            local state=visitor and "watch" or "idle"
            if guard.state~=state then
                guard.state=state
                if visitor then
                    setPedAnimation(ped,"GANGS","prtial_gngtlkB",-1,true,false,false,false)
                elseif guard.enforcer then
                    setPedAnimation(ped,"SMOKING","M_smkstnd_loop",-1,true,false,false,false)
                else
                    setPedAnimation(ped,"DEALER","DEALER_IDLE",-1,true,false,false,false)
                end
            end
            if visitor then
                local px,py=getElementPosition(visitor)
                setElementRotation(ped,0,0,(-math.deg(math.atan2(px-x,py-y)))%360)
            else setElementRotation(ped,0,0,guard.rotation) end
        end
    end
end,250,0)

addEventHandler("onResourceStop",resourceRoot,function()
    for _,guard in ipairs(guards) do
        if isElement(guard.ped) then
            setPedAnimation(guard.ped,false)
            setElementRotation(guard.ped,0,0,guard.rotation)
        end
    end
end)
