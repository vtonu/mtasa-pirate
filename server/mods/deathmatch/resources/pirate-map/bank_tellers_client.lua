-- ROBBERY STATUS
addEventHandler("onClientRender", root, function()
    local session = getElementData(localPlayer, "bank:robbery")
    if type(session) ~= "table" then return end
    local text = session.state == "hold" and "KEEP AIMING TO START ROBBERY"
        or ("KEEP AIMING FOR CASH: $" .. tostring(session.total) .. " / $3000")
    local w, h = guiGetScreenSize()
    dxDrawText(text, 16, h * 0.76, w - 16, h * 0.76 + 36,
        tocolor(127, 255, 212, 255), 1, "unifont", "center", "center")
end)
