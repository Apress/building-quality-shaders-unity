Shader "Examples/TessLOD"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex("Base Texture", 2D) = "white" {}

		[Enum(UnityEngine.Rendering.BlendMode)]
		_SrcBlend("Source Blend Factor", Int) = 1

		[Enum(UnityEngine.Rendering.BlendMode)]
		_DstBlend("Destination Blend Factor", Int) = 1

		_TessAmount("Tessellation Amount", Range(1, 64)) = 2
		_TessMinDistance("Min Tessellation Distance", Float) = 20
		_TessMaxDistance("Max Tessellation Distance", Float) = 50
    }
	SubShader
    {
        Tags 
		{ 
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
			"RenderPipeline" = "UniversalPipeline"
		}

        Pass
        {
			Blend [_SrcBlend] [_DstBlend]

			Tags
			{
				"LightMode" = "UniversalForward"
			}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma hull tessHull
			#pragma domain tessDomain
			#pragma target 4.6

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 positionOS : Position;
				float2 uv : TEXCOORD0;
            };

			struct tessControlPoint 
			{
				float4 positionWS : INTERNALTESSPOS;
				float2 uv : TEXCOORD0;
			};

			struct tessFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

            struct v2f
            {
                float4 positionCS : SV_Position;
				float2 uv : TEXCOORD0;
            };

			sampler2D _BaseTex;

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor;
				float4 _BaseTex_ST;
				float _TessAmount;
				float _TessMinDistance;
				float _TessMaxDistance;
			CBUFFER_END

			tessControlPoint vert(appdata v)
            {
				tessControlPoint o;
                o.positionWS = mul(unity_ObjectToWorld, v.positionOS); 
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

			tessFactors patchConstantFunc(InputPatch<tessControlPoint, 3> patch)
			{
				tessFactors f;

				float3 triPos0 = patch[0].positionWS.xyz;
				float3 triPos1 = patch[1].positionWS.xyz;
				float3 triPos2 = patch[2].positionWS.xyz;

				float3 edgePos0 = 0.5f * (triPos1 + triPos2);
				float3 edgePos1 = 0.5f * (triPos0 + triPos2);
				float3 edgePos2 = 0.5f * (triPos0 + triPos1);

				float3 camPos = _WorldSpaceCameraPos;

				float dist0 = distance(edgePos0, camPos);
				float dist1 = distance(edgePos1, camPos);
				float dist2 = distance(edgePos2, camPos);

				float fadeDist = _TessMaxDistance - _TessMinDistance;

				float edgeFactor0 = saturate(1.0f - (dist0 - _TessMinDistance) / fadeDist);
				float edgeFactor1 = saturate(1.0f - (dist1 - _TessMinDistance) / fadeDist);
				float edgeFactor2 = saturate(1.0f - (dist2 - _TessMinDistance) / fadeDist);

				f.edge[0] = max(pow(edgeFactor0, 2) * _TessAmount, 1);
				f.edge[1] = max(pow(edgeFactor1, 2) * _TessAmount, 1);
				f.edge[2] = max(pow(edgeFactor2, 2) * _TessAmount, 1);

				f.inside = (f.edge[0] + f.edge[1] + f.edge[2]) / 3.0f;

				return f;
			}

			[domain("tri")]
			[outputcontrolpoints(3)]
			[outputtopology("triangle_cw")]
			[partitioning("integer")]
			[patchconstantfunc("patchConstantFunc")]
			tessControlPoint tessHull(InputPatch<tessControlPoint, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			v2f tessDomain(tessFactors factors, OutputPatch<tessControlPoint, 3> patch, float3 bcCoords : SV_DomainLocation)
			{
				v2f o;

				float4 positionWS =	patch[0].positionWS * bcCoords.x +
					patch[1].positionWS * bcCoords.y +
					patch[2].positionWS * bcCoords.z;

				o.positionCS = mul(UNITY_MATRIX_VP, positionWS);

				o.uv = patch[0].uv * bcCoords.x +
					patch[1].uv * bcCoords.y +
					patch[2].uv * bcCoords.z;

				return o;
			}

            float4 frag(v2f i) : SV_Target
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);
				return textureSample * _BaseColor;
            }
            ENDHLSL
        }

		/*
		Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
		*/
    }
	Fallback Off
}
