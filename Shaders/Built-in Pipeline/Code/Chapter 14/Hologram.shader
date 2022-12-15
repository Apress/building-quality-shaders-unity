Shader "Examples/Hologram"
{
    Properties
    {
		_BaseTex("Base Texture", 2D) = "white" {}
		_HologramTex("Hologram Texture", 2D) = "white" {}
		[HDR] _HologramColor("Hologram Color", Color) = (0, 0, 0, 0)
		_HologramSize("Hologram Size", Float) = 1
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
			sampler2D _HologramTex;

			float4 _BaseTex_ST;
			float4 _HologramTex_TexelSize;
			float4 _HologramColor;
			float _HologramSize;

            v2f vert (appdata v)
            {
				v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS.xyz);
				o.positionSS = ComputeScreenPos(o.positionCS);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float2 screenUV = i.positionSS.xy / i.positionSS.w * _ScreenParams.xy / (_HologramTex_TexelSize.zw * _HologramSize);

				float hologramSample = tex2D(_HologramTex, screenUV).r;
				float4 textureSample = tex2D(_BaseTex, i.uv);

				float alpha = textureSample.a * hologramSample;

				if (alpha < 0.5f) discard;

				float4 hologramColor = hologramSample * _HologramColor;
				float4 outputColor = textureSample + hologramColor;
				
				return outputColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}
