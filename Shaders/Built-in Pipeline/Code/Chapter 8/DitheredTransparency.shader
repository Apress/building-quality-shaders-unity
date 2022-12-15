Shader "Examples/DitheredTransparency"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex("Base Texture", 2D) = "white" {}
    }
	SubShader
    {
        Tags 
		{ 
			"RenderType" = "Opaque"
			"Queue" = "AlphaTest"
		}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : Position;
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
				float2 uv : TEXCOORD0;
				float4 positionSS : TEXCOORD1;
            };

			sampler2D _BaseTex;

			float4 _BaseColor;
			float4 _BaseTex_ST;

            v2f vert (appdata v)
            {
				v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
				o.positionSS = ComputeScreenPos(o.positionCS);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);
				float4 outputColor = textureSample * _BaseColor;

				float2 screenUVs = i.positionSS.xy / i.positionSS.w * _ScreenParams.xy;

				float ditherThresholds[16] =
				{
					16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0,
					 4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
					13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
					 1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0
				};
				uint index = (uint(screenUVs.x) % 4) * 4 + uint(screenUVs.y) % 4;
				float threshold = ditherThresholds[index];

				if (outputColor.a < threshold) discard;

				return outputColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}
