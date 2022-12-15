Shader "Examples/KeywordExample"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [Toggle(OVERRIDE_RED_ON)] _OverrideRed("Force Red", Float) = 0
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

            #pragma multi_compile_local OVERRIDE_RED_ON __

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

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS.xyz);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
#if OVERRIDE_RED_ON
                return float4(1.0f, 0.0f, 0.0f, 1.0f);
#else
				return _BaseColor;
#endif
            }
            ENDHLSL
        }
    }
}
