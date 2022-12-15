Shader "Examples/UVRotation"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex ("Base Texture", 2D) = "white" {}
		_Rotation("Rotation Amount", Float) = 0.0
		_Center("Rotation Center", Vector) = (0,0,0,0)
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
			float _Rotation;
			float2 _Center;

            v2f vert (appdata v)
            {
                float c = cos(_Rotation);
				float s = sin(_Rotation);
				float2x2 rotMatrix = float2x2(c, -s, s, c);

                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);

                o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
				o.uv -= _Center;
				o.uv = mul(rotMatrix, o.uv);
				o.uv += _Center;

                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);
                return textureSample * _BaseColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}