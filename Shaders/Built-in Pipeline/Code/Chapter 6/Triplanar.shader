Shader "Examples/Triplanar"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex ("Base Texture", 2D) = "white" {}
		_Tile("Texture Tiling", Float) = 1
		_BlendPower("Triplanar Blending", Float) = 10
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
				float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
            };

			float4 _BaseColor;
			sampler2D _BaseTex;
			float4 _BaseTex_ST;
			float _Tile;
			float _BlendPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.positionWS = mul(unity_ObjectToWorld, v.positionOS);
				o.normalWS = UnityObjectToWorldDir(v.normalOS);
                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				float2 xAxisUV = i.positionWS.zy * _Tile;
				float2 yAxisUV = i.positionWS.xz * _Tile;
				float2 zAxisUV = i.positionWS.xy * _Tile;

				float4 xSample = tex2D(_BaseTex, xAxisUV);
				float4 ySample = tex2D(_BaseTex, yAxisUV);
				float4 zSample = tex2D(_BaseTex, zAxisUV);

				float3 weights = pow(abs(i.normalWS), _BlendPower);
				weights /= (weights.x + weights.y + weights.z);

				float4 outColor = xSample * weights.x + ySample * weights.y + zSample * weights.z;
				return outColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}