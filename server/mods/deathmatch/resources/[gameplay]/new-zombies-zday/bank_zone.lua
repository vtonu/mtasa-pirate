-- BANK EXCLUSION WITHOUT PLAYER PASSIVE MODE
function isBankZombieSafePoint(x, y, z, interior, dimension)
    if interior ~= 0 or dimension ~= 0 then return false end
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then return false end
    return (x - 2312.68408)^2 + (y + 8.94955)^2 <= 22^2
        and z >= 20 and z <= 35
end

function isBankZombieSafeElement(element)
    if not isElement(element) then return false end
    local x, y, z = getElementPosition(element)
    return isBankZombieSafePoint(x, y, z, getElementInterior(element), getElementDimension(element))
end
