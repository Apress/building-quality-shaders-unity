Shader "Examples/GouraudShading"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex ("Base Texture", 2D) = "white" {}
		_GlossPower("Gloss Power", Float) = 400
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
				float4 diffuseLighting : TEXCOORD1;
				float4 specularLighting : TEXCOORD2;
            };

			float4 _BaseColor;
			sampler2D _BaseTex;
			float4 _BaseTex_ST;
			float _GlossPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);

				float3 normalWS = UnityObjectToWorldNormal(v.normalOS);
				float3 viewWS = normalize(WorldSpaceViewDir(v.positionOS));

				float3 ambient = ShadeSH9(half4(normalWS, 1));

				float3 diffuse = _LightColor0 * max(0, dot(normalWS, _WorldSpaceLightPos0.xyz));

				float3 halfVector = normalize(_WorldSpaceLightPos0 + viewWS);
				float specular = max(0, dot(normalWS, halfVector)) * diffuse;
				specular = pow(specular, _GlossPower);
				float3 specularColor = _LightColor0 * specular;

				o.diffuseLighting = float4(ambient + diffuse, 1.0f);
				o.specularLighting = float4(specularColor, 1.0f);

                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);
                return textureSample * _BaseColor * i.diffuseLighting + i.specularLighting;
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