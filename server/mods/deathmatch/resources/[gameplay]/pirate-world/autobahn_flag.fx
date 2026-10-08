texture flagImage;
sampler flagSampler = sampler_state
{
    Texture = <flagImage>;
    MinFilter = Linear;
    MagFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

float4 drawFlag(float2 uv : TEXCOORD0) : COLOR0
{
    return tex2D(flagSampler, uv);
}

technique autobahnFlag
{
    pass P0
    {
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;
        PixelShader = compile ps_2_0 drawFlag();
    }
}
