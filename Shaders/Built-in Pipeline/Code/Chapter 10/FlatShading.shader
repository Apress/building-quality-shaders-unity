Shader "Examples/FlatShading"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex ("Base Texture", 2D) = "white" {}
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
			Tags
			{
				"LightMode" = "ForwardBase"
			}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
				float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				nointerpolation float4 flatLighting : TEXCOORD1;
            };

			float4 _BaseColor;
			sampler2D _BaseTex;
			float4 _BaseTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);

				float3 normalWS = UnityObjectToWorldNormal(v.normalOS);

				float3 ambient = ShadeSH9(half4(normalWS, 1));

				float3 diffuse = _LightColor0 * max(0, dot(normalWS, _WorldSpaceLightPos0.xyz));

				o.flatLighting = float4(ambient + diffuse, 1.0f);

                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);
                return textureSample * _BaseColor * i.flatLighting;
            }
            ENDHLSL
        }
		Pass 
		{
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On

            HLSLPROGRAM
			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster

            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing

            #include "UnityStandardShadow.cginc"

            ENDHLSL
        }
    }
	Fallback Off
}