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

			#pragma multi_compile_local USE_EMISSION_ON __

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON

			//#pragma multi_compile_fog
			//#pragma multi_compile_instancing

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float2 staticLightmapUV : TEXCOORD1;
				float2 dynamicLightMapUV : TEXCOORD2;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				float3 normalWS : TEXCOORD2;
				float4 tangentWS : TEXCOORD3;
				float3 viewDirWS : TEXCOORD4;
				float4 shadowCoord : TEXCOORD5;
				DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 6);
#ifdef DYNAMICLIGHTMAP_ON
				float2  dynamicLightmapUV : TEXCOORD7;
#endif
            };

			sampler2D _BaseTex;
			sampler2D _MetallicTex;
			sampler2D _NormalTex;
			sampler2D _EmissionTex;
			sampler2D _AOTex;

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor;
				float4 _BaseTex_ST;
				float _MetallicStrength;
				float _Smoothness;
				float _NormalStrength;
				float4 _EmissionColor;
			CBUFFER_END

            v2f vert (appdata v)
            {
				v2f o;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
				VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);

				o.positionWS = vertexInput.positionWS;
				o.positionCS = vertexInput.positionCS;

				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);

				o.normalWS = normalInput.normalWS;

				float sign = v.tangentOS.w;
				o.tangentWS = float4(normalInput.tangentWS.xyz, sign);

				o.viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);

				o.shadowCoord = GetShadowCoord(vertexInput);

				OUTPUT_LIGHTMAP_UV(v.staticLightmapUV, unity_LightmapST, o.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
				v.dynamicLightmapUV = v.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
				OUTPUT_SH(o.normalWS.xyz, o.vertexSH);
				
                return o;
            }

			SurfaceData createSurfaceData(v2f i)
			{
				SurfaceData surfaceData = (SurfaceData)0;

				// Albedo output.
				float4 albedoSample = tex2D(_BaseTex, i.uv);
				surfaceData.albedo = albedoSample.rgb * _BaseColor.rgb;

				// Metallic output.
				float4 metallicSample = tex2D(_MetallicTex, i.uv);
				surfaceData.metallic = metallicSample * _MetallicStrength;

				// Smoothness output.
				surfaceData.smoothness = _Smoothness;

				// Normal output.
				float3 normalSample = UnpackNormal(tex2D(_NormalTex, i.uv));
				normalSample.rg *= _NormalStrength;
				//normalSample.b = lerp(1, normalSample.b, saturate(_NormalStrength));
				surfaceData.normalTS = normalSample;

				// Emission output.
#if USE_EMISSION_ON
				surfaceData.emission = tex2D(_EmissionTex, i.uv) * _EmissionColor;
#endif

				// Ambient Occlusion output.
				float4 aoSample = tex2D(_AOTex, i.uv);
				surfaceData.occlusion = aoSample.r;

				// Alpha output.
				surfaceData.alpha = albedoSample.a * _BaseColor.a;

				return surfaceData;
			}

			InputData createInputData(v2f i, float3 normalTS)
			{
				InputData inputData = (InputData)0;

				// Position input.
				inputData.positionWS = i.positionWS;

				// Normal input.
				float3 bitangent = i.tangentWS.w * cross(i.normalWS, i.tangentWS.xyz);
				inputData.tangentToWorld = float3x3(i.tangentWS.xyz, bitangent, i.normalWS);
				inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);
				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);

				// View direction input.
				inputData.viewDirectionWS = SafeNormalize(i.viewDirWS);

				// Shadow coords.
				inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);

				// Baked lightmaps.
#if defined(DYNAMICLIGHTMAP_ON)
				inputData.bakedGI = SAMPLE_GI(i.staticLightmapUV, i.dynamicLightmapUV, i.vertexSH, inputData.normalWS);
#else
				inputData.bakedGI = SAMPLE_GI(i.staticLightmapUV, i.vertexSH, inputData.normalWS);
#endif
				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(i.positionCS);
				inputData.shadowMask = SAMPLE_SHADOWMASK(i.staticLightmapUV);

				return inputData;
			}

            float4 frag (v2f i) : SV_Target
            {
				SurfaceData surfaceData = createSurfaceData(i);
				InputData inputData = createInputData(i, surfaceData.normalTS);

				return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }

		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#pragma multi_compile_instancing

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
			ENDHLSL
		}
    }
	Fallback Off
}
