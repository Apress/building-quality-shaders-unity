Shader "Examples/SpritePixelate"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}
		_LOD("LOD", Int) = 0
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
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off

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
            };

			Texture2D _MainTex;
			SamplerState sampler_point_repeat;

			float4 _BaseColor;
			float4 _MainTex_ST;
			int _LOD;

            v2f vert (appdata v)
            {
				v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float4 textureSample = _MainTex.SampleLevel(sampler_point_repeat, i.uv, _LOD);
				return textureSample * _BaseColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}
