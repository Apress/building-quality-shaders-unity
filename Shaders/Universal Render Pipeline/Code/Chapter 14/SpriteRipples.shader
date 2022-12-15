Shader "Examples/SpriteRipples"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}
		_RippleDensity("Ripple Density", Float) = 1
		_Speed("Speed", Float) = 1
		_RippleStrength("Ripple Strength", Float) = 0.01
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
			Tags
			{
				"LightMode" = "UniversalForward"
			}

			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off

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

			sampler2D _MainTex;

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor;
				float4 _MainTex_ST;
				float _RippleDensity;
				float _Speed;
				float _RippleStrength;
			CBUFFER_END

            v2f vert (appdata v)
            {
				v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float2 offset = (i.uv - 0.5f) * 2.0f;
				float dist = distance(offset, float2(0.0f, 0.0f));

				float time = _Time.y * _Speed;

				float clock = time + dist * _RippleDensity;
				float sineClock = sin(clock);

				float2 direction = normalize(offset);
				float2 newUV = i.uv + sineClock * direction * _RippleStrength;

				float4 textureSample = tex2D(_MainTex, newUV);
				return textureSample * _BaseColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}
