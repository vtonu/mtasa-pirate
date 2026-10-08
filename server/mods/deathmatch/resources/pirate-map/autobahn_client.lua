-- RECOLOR THE NATIVE FLAG TEXTURE; KEEP THE ORIGINAL SHAPE
local flagShader
addEventHandler("onClientResourceStart",resourceRoot,function()
    flagShader=dxCreateShader("autobahn_flag.fx",0,0,false,"other")
    if isElement(flagShader) then
        engineApplyShaderToWorldTexture(flagShader,"radar_?lag")
    end
end)
addEventHandler("onClientResourceStop",resourceRoot,function()
    if isElement(flagShader) then
        engineRemoveShaderFromWorldTexture(flagShader,"radar_?lag")
        destroyElement(flagShader)
    end
end)
