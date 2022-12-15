Shader "Examples/PackingExample"
{
    Properties
    {
		_BaseTex ("Base Texture", 2D) = "white" {}
		_EmissionMask("Emission Mask", 2D) = "black" {}
		_EmissionPower("Emission Power", Float) = 0
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
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
				float2 uv : TEXCOORD0;
            };

			sampler2D _BaseTex;
			sampler2D _EmissionMask;

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor;
				float4 _BaseTex_ST;
				float _EmissionPower;
			CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);

				float3 baseColor = textureSample.rgb;
				float3 emissiveColor = baseColor * pow(2, _EmissionPower);

				//float emission = tex2D(_EmissionMask, i.uv).r;
				float emission = textureSample.a;

				float3 outputColor = lerp(baseColor, emissiveColor, emission);

				return float4(outputColor, 1.0f);
            }
            ENDHLSL
        }
    }
}
