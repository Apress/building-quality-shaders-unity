Shader "Examples/ConditionalExample"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_ShouldInvertColor ("Should invert?", Float) = 0
    }
	SubShader
    {
        Tags 
		{ 
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
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
            };

			float4 _BaseColor;
			float _ShouldInvertColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS.xyz);
                return o;
            }

			float rand(float2 seed)
			{
				return frac(sin(dot(seed, float2(12.9898, 78.233)))*43758.5453);
			}

            float4 frag (v2f i) : SV_Target
            {
				float4 outputColor = _BaseColor;

				float randomValue = rand(i.positionCS.xy + _Time.y);

				if (randomValue > 0.5f)
				{
					outputColor = 1.0f - outputColor;
				}

				return outputColor;
            }
            ENDHLSL
        }
    }
}
