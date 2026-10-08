texture screenTexture;
float3 visionTint = float3(1, 1, 1);
float visionBrightness = 1.45;
float visionGamma = 0.6;
float visionStrength = 1;
sampler screenSampler = sampler_state { Texture = <screenTexture>; };
float4 whiteVision(float2 uv : TEXCOORD0) : COLOR0 {
    float3 color = tex2D(screenSampler, uv).rgb;
    // PRESERVE ONLY THE SOLID ZOMBIE REVEAL SIGNALS
    if (color.g > 0.6 && color.g > color.r * 3 && color.g > color.b * 3) return float4(0.2, 1, 0.35, 1);
    if (color.r > 0.6 && color.r > color.g * 3 && color.r > color.b * 3) return float4(1, 0.1, 0.15, 1);
    float gray = saturate(pow(dot(color, float3(0.299, 0.587, 0.114)), visionGamma) * visionBrightness);
    return float4(lerp(color, gray * visionTint, visionStrength), 1);
}
technique whiteMode { pass P0 { PixelShader = compile ps_2_0 whiteVision(); } }
