-- CORE OWNS PLAYER STATE; UI OWNS ITS DISPLAY
function getCoreRoot()
    local core = getResourceFromName("pirate-core")
    return core and getResourceState(core) == "running" and getResourceRootElement(core)
end

function addCoreUIEvent(name, handler)
    addEventHandler(name, root, function(...)
        if source == getCoreRoot() then handler(...) end
    end)
end

function sendCoreUIEvent(name)
    local coreRoot = getCoreRoot()
    if coreRoot then triggerServerEvent(name, coreRoot) end
end
