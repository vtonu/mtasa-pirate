-- CAPSULE MISSION MARKER
addEventHandler("onResourceStart", resourceRoot, function()
    local marker = createMarker(2000.7, 1522.5, 16.0, "cylinder", 0.8, 127, 255, 212, 150)
    setElementID(marker, "greenCapsuleMarker")
end)
