-- KEEP INTERIOR LIGHTING CLEAR AND RESTORE THE CURRENT OUTDOOR WEATHER
local inside = false
local outdoorWeather

addEventHandler("onClientPreRender", root, function()
    local interior = getElementInterior(localPlayer) ~= 0
    if interior then
        if not inside then outdoorWeather = getWeather() end
        local current, blended = getWeather()
        if current ~= 0 or (blended and blended ~= 0) then setWeather(0) end
    elseif inside then
        setWeather(getElementData(root, "play:outdoorWeather") or outdoorWeather or 0)
    end
    inside = interior
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if inside then setWeather(getElementData(root, "play:outdoorWeather") or outdoorWeather or 0) end
end)
