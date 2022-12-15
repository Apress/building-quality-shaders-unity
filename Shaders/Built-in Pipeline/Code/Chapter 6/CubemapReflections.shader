Shader "Examples/CubemapReflections"
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
				float3 reflectWS : TEXCOORD0;
            };

			samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				float3 normalWS = UnityObjectToWorldNormal(v.normalOS);

				float3 positionWS = mul(unity_ObjectToWorld, v.positionOS).xyz;
				float3 viewDirWS = normalize(UnityWorldSpaceViewDir(positionWS));

				o.reflectWS = reflect(-viewDirWS, normalWS);
                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				float4 cubemapSample = texCUBE(_Cubemap, i.reflectWS);
				return cubemapSample;
            }
            ENDHLSL
        }
    }
	Fallback Off
}