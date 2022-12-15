Shader "Examples/Xray"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex ("Base Texture", 2D) = "white" {}

		_XrayColor("X-ray Color", Color) = (1, 0, 0, 1)
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
			ZTest LEqual
			ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
            };

			float4 _BaseColor;
			sampler2D _BaseTex;
			float4 _BaseTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);
                return textureSample * _BaseColor;
            }
            ENDHLSL
        }

		Pass
        {
			ZTest Greater
			ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
            };

			float4 _XrayColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				return _XrayColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}