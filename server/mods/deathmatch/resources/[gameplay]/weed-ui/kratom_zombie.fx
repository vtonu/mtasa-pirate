float4 zombieVision() : COLOR0 { return float4(0.722, 0.549, 1, 0.85); }
technique greenMode {
    pass P0 {
        PixelShader = compile ps_2_0 zombieVision();
        ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = true;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
    }
}
