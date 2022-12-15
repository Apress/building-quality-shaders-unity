Shader "Examples/SceneIntersection"
{
    Properties
    {
		_BaseColor("Base Color", Color) = (0, 0, 0, 1)
		_IntersectColor("Intersect Color", Color) = (1, 1, 1, 1)
		_IntersectPower("IntersectPower", Range(0.01, 100)) = 1
    }
	SubShader
    {
		Tags 
		{ 
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
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
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
				float4 positionSS : TEXCOORD0;
            };

            sampler2D _CameraDepthTexture;

			float4 _BaseColor;
			float4 _IntersectColor;
			float _IntersectPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.positionSS = ComputeScreenPos(o.positionCS);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float2 screenUVs = i.positionSS.xy / i.positionSS.w;
				float rawDepth = tex2D(_CameraDepthTexture, screenUVs).r;
				float sceneEyeDepth = LinearEyeDepth(rawDepth);

				float screenPosW = i.positionSS.w;

				float intersectAmount = sceneEyeDepth - screenPosW;
				intersectAmount = saturate(1.0f - intersectAmount);
				intersectAmount = pow(intersectAmount, _IntersectPower);

				return lerp(_BaseColor, _IntersectColor, intersectAmount);
            }
            ENDHLSL
        }
    }
}
