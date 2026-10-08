sampler flagTexture : register(s0);

float4 recolorFlag(float2 uv : TEXCOORD0, float4 tint : COLOR0) : COLOR0
{
    float4 original = tex2D(flagTexture, uv);
    float shade = dot(original.rgb, float3(0.299, 0.587, 0.114));
    float3 color = lerp(float3(0.85, 0.04, 0.08), float3(1, 0.8, 0), smoothstep(0.65, 0.85, shade));
    color *= smoothstep(0.12, 0.3, shade);
    return float4(color * tint.rgb, original.a * tint.a);
}

technique autobahnFlag
{
    pass P0
    {
        PixelShader = compile ps_2_0 recolorFlag();
    }
}
