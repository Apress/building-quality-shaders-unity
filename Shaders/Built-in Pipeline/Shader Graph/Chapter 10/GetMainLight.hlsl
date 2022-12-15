void MainLight_float(float3 WorldPos, out float3 Direction, out float3 Color, 
	out float DistanceAtten, out float ShadowAtten)
{
#ifdef SHADERGRAPH_PREVIEW
    Direction = normalize(float3(0.5f, 0.5f, 0.25f));
    Color = float3(1.0f, 1.0f, 1.0f);
    DistanceAtten = 1.0f;
    ShadowAtten = 1.0f;
#else
    Direction = _WorldSpaceLightPos0.xyz;
    Color = _LightColor0;
    DistanceAtten = 1.0f;
    ShadowAtten = 1.0f;
#endif
}
