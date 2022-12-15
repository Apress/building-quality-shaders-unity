Shader "Examples/CubemapExample"
{
    Properties
    {
		_Cubemap("Cubemap", CUBE) = "white" {}
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
				float3 normalWS : TEXCOORD0;
            };

			samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.normalWS = UnityObjectToWorldNormal(v.normalOS);
                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				float4 cubemapSample = texCUBE(_Cubemap, i.normalWS);
				return cubemapSample;
            }
            ENDHLSL
        }
    }
	Fallback Off
}