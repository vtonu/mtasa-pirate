texture screenTexture;
float3 visionTint = float3(1, 1, 1);
float visionBrightness = 1.45;
sampler screenSampler = sampler_state { Texture = <screenTexture>; };
float4 whiteVision(float2 uv : TEXCOORD0) : COLOR0 {
    float3 color = tex2D(screenSampler, uv).rgb;
    float gray = saturate(dot(color, float3(0.299, 0.587, 0.114)) * visionBrightness);
    return float4(gray * visionTint, 1);
}
technique whiteMode { pass P0 { PixelShader = compile ps_2_0 whiteVision(); } }
