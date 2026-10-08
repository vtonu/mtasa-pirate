-- USE ONE SMALL SVG FOR THE NATIVE FLAG ICON
local flagShader, flagSvg, flagTexture

local function drawFlag(svgElement)
    if isElement(svgElement) then flagSvg = svgElement end
    if not isElement(flagSvg) or not isElement(flagTexture) then return end
    if not dxSetRenderTarget(flagTexture, true) then return end
    dxSetBlendMode("modulate_add")
    dxDrawImage(0, 0, 64, 64, flagSvg)
    dxSetBlendMode("blend")
    dxSetRenderTarget()
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    flagShader = dxCreateShader("autobahn_flag.fx", 1, 0, false, "all")
    flagTexture = dxCreateRenderTarget(64, 64, true)
    flagSvg = svgCreate(64, 64, "autobahn_flag.svg", drawFlag)
    if isElement(flagShader) and isElement(flagTexture) and isElement(flagSvg) then
        dxSetShaderValue(flagShader, "flagImage", flagTexture)
        engineApplyShaderToWorldTexture(flagShader, "radar_?lag")
    end
end)

addEventHandler("onClientRestore", root, function(cleared)
    if cleared then drawFlag() end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isElement(flagShader) then
        engineRemoveShaderFromWorldTexture(flagShader, "radar_?lag")
        destroyElement(flagShader)
    end
    if isElement(flagTexture) then destroyElement(flagTexture) end
    if isElement(flagSvg) then destroyElement(flagSvg) end
end)
