Shader "Examples/CubemapReflections"
{
    Properties
    {
		_Cubemap("Cubemap", CUBE) = "white" {}

		[MainTexture] _BaseMap("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" {}
		[MainColor]   _BaseColor("Base Color", Color) = (1, 1, 1, 1)

		[Toggle(_ALPHATEST_ON)] _AlphaTestToggle("Alpha Clipping", Float) = 0
		_Cutoff("Alpha Cutoff", Float) = 0.5
    }
	SubShader
    {
        Tags 
		{ 
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
			"RenderPipeline" = "UniversalPipeline"
		}

        Pass
        {
			Tags
			{
				"LightMode" = "UniversalForward"
			}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 positionOS : Position;
				float3 normalOS : Normal;
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
				float3 reflectWS : Texcoord0;
            };

			samplerCUBE _Cubemap;

			CBUFFER_START(UnityPerMaterial)
				float4 _Cubemap_ST;
			CBUFFER_END

            v2f vert (appdata v)
            {
				v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				//float3 normalWS = UnityObjectToWorldNormal(v.normalOS);
				float3 normalWS = TransformObjectToWorldNormal(v.normalOS);

				float3 positionWS = mul(unity_ObjectToWorld, v.positionOS).xyz;
				//float3 viewDirWS = normalize(UnityWorldSpaceViewDir(positionWS));
				float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);

				o.reflectWS = reflect(-viewDirWS, normalWS);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float4 cubemapSample = texCUBE(_Cubemap, i.reflectWS);
				return cubemapSample;
            }
            ENDHLSL
        }

		Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            //#pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
	Fallback Off
}
