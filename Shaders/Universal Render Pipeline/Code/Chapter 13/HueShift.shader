Shader "Examples/HueShift"
{
    Properties
    {

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
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
				float4 hueShiftColor : COLOR;
            };

			/*
			float3 rgb2hsv(float3 inRGB)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 P = lerp(float4(inRGB.bg, K.wz), float4(inRGB.gb, K.xy), step(inRGB.b, inRGB.g));
				float4 Q = lerp(float4(P.xyw, inRGB.r), float4(inRGB.r, P.yzx), step(P.x, inRGB.r));
				float D = Q.x - min(Q.w, Q.y);
				float  E = 1e-10;
				return float3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);
			}
			*/

			float3 hsv2rgb(float3 inHSV)
			{
				float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				float3 P = abs(frac(inHSV.xxx + K.xyz) * 6.0 - K.www);
				return inHSV.z * lerp(K.xxx, saturate(P - K.xxx), inHSV.y);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

				float3 hsvColor = float3(0.0f, 1.0f, 1.0f);
				hsvColor.r = (sin(_Time.y) + 1.0f) * 0.5f;
				float3 rgbColor = hsv2rgb(hsvColor);

				o.hueShiftColor = float4(rgbColor, 1.0f);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				// Before optimization.
				/*
				float3 hsvColor = float3(0.0f, 1.0f, 1.0f);
				hsvColor.r = (sin(_Time.y) + 1.0f) * 0.5f;
				float3 rgbColor = hsv2rgb(hsvColor);

				return float4(rgbColor, 1.0f);
				*/

				return i.hueShiftColor;
            }
            ENDHLSL
        }
    }
}
