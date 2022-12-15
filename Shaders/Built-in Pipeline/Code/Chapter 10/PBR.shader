Shader "Examples/PBR"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1,1,1,1)
		_BaseTex("Base Texture", 2D) = "white" {}
		_MetallicTex("Metallic Map", 2D) = "white" {}
		_MetallicStrength("Metallic Strength", Range(0, 1)) = 0
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
		_NormalTex("NormalMap", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Float) = 1
		[Toggle(USE_EMISSION_ON)] _EmissionOn("Use Emission?", Float) = 0
		_EmissionTex("Emission Map", 2D) = "white" {}
		[HDR] _EmissionColor("Emission Color", Color) = (0, 0, 0, 0)
		_AOTex("Ambient Occlusion Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
		#pragma multi_compile_local USE_EMISSION_ON __

        struct Input
        {
			float2 uv_BaseTex;
        };

		float4 _BaseColor;
		sampler2D _BaseTex;
		sampler2D _MetallicTex;
		float _MetallicStrength;
		float _Smoothness;
		sampler2D _NormalTex;
		float _NormalStrength;
		sampler2D _EmissionTex;
		float4 _EmissionColor;
		sampler2D _AOTex;

        void surf (Input v, inout SurfaceOutputStandard o)
        {
			// Albedo output.
            float4 albedoSample = tex2D(_BaseTex, v.uv_BaseTex);
			o.Albedo = albedoSample.rgb * _BaseColor.rgb;

			// Metallic output.
			float4 metallicSample = tex2D(_MetallicTex, v.uv_BaseTex);
			o.Metallic = metallicSample * _MetallicStrength;

			// Smoothness output.
			o.Smoothness = _Smoothness;

			// Normal output.
			float3 normalSample = UnpackNormal(tex2D(_NormalTex, v.uv_BaseTex));
			normalSample.rg *= _NormalStrength;
			//normalSample.b = lerp(1, normalSample.b, saturate(_NormalStrength));
			o.Normal = normalSample;

			// Emission output.
#if USE_EMISSION_ON
			o.Emission = tex2D(_EmissionTex, v.uv_BaseTex) * _EmissionColor;
#else
			o.Emission = 0;
#endif

			// Ambient Occlusion output.
			float4 aoSample = tex2D(_AOTex, v.uv_BaseTex);
			o.Occlusion = aoSample.r;

			// Alpha output.
			o.Alpha = albedoSample.a * _BaseColor.a;
        }
        ENDCG
    }
    Fallback "Diffuse"
}
