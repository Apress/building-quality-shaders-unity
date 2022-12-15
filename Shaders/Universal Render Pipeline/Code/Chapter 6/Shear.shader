Shader "Examples/Shear"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex("Base Texture", 2D) = "white" {}
		_Shear("Shear Amount", Vector) = (0, 0, 0, 0)
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

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor;
				float4 _BaseTex_ST;
				float2 _Shear;
			CBUFFER_END

            v2f vert (appdata v)
            {
				float2x2 shearMatrix = float2x2
				(
					1, -_Shear.x,
					-_Shear.y, 1
				);

                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
				o.uv = mul(shearMatrix, o.uv);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float4 color = tex2D(_BaseTex, i.uv);
				return color * _BaseColor;
            }
            ENDHLSL
        }
    }
}
