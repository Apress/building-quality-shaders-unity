Shader "Examples/ImageEffects/WorldScan"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ScanOrigin("Origin Point", Vector) = (0, 0, 0, 0)
		_ScanDist("Scan Distance", Float) = 0
		_ScanWidth("Scan Width", Float) = 1
		_OverlayRampTex("Overlay Ramp", 2D) = "white" {}
		[HDR] _OverlayColor("Overlay Color", Color) = (1, 1, 1, 1)
    }
	SubShader
    {
        Tags 
		{ 
			"RenderType"="Opaque"
			"RenderPipeline"="UniversalPipeline"
		}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

			struct appdata
            {
                float4 positionOS : Position;
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
				float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
			sampler2D _OverlayRampTex;

			CBUFFER_START(UnityPerMaterial)
				float3 _ScanOrigin;
				float _ScanDist;
				float _ScanWidth;
				float4 _OverlayColor;
			CBUFFER_END

			v2f vert (appdata v)
			{
				v2f o;
				o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				o.uv = v.uv;
				return o;
			}

            float4 frag (v2f i) : SV_Target
            {
#if UNITY_REVERSED_Z
				float depth = SampleSceneDepth(i.uv);
#else
				float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(i.uv));
#endif

				float3 worldPos = ComputeWorldSpacePosition(i.uv, depth, UNITY_MATRIX_I_VP);

				float fragDist = distance(worldPos, _ScanOrigin);

				float4 scanColor = 0.0f;

				if (fragDist < _ScanDist && fragDist > _ScanDist - _ScanWidth)
				{
					float scanUV = (fragDist - _ScanDist) / (_ScanWidth * 1.01f);

					scanColor = tex2D(_OverlayRampTex, float2(scanUV, 0.5f));
					scanColor *= _OverlayColor;
				}

				float4 textureSample = tex2D(_MainTex, i.uv);

				return lerp(textureSample, scanColor, scanColor.a);
            }
            ENDHLSL
        }
    }
}
