float3 zombieColor = float3(0.05, 1, 0.1);
float4 zombieVision() : COLOR0 { return float4(zombieColor, 1); }
technique greenMode {
    pass P0 {
        PixelShader = compile ps_2_0 zombieVision();
        FogEnable = false;
        Lighting = false;
        AlphaTestEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = true;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
    }
}
