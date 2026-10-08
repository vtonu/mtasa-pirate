function getPirateMapRoot()
    local map = getResourceFromName("pirate-map")
    return map and getResourceRootElement(map)
end

function getPirateElements(elementType)
    local elements = {}
    for _, name in ipairs({"pirate-map", "pirate-world", "pirate-missions"}) do
        local owner = getResourceFromName(name)
        local parent = owner and getResourceRootElement(owner)
        if isElement(parent) then
            for _, element in ipairs(getElementsByType(elementType, parent)) do
                elements[#elements + 1] = element
            end
        end
    end
    return elements
end
