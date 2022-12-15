Shader "Examples/PhongShading"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex ("Base Texture", 2D) = "white" {}
		_GlossPower("Gloss Power", Float) = 400
		_FresnelPower("Fresnel Power", Float) = 5
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
				float3 normalWS : TEXCOORD1;
				float3 viewWS : TEXCOORD2;
            };

			float4 _BaseColor;
			sampler2D _BaseTex;
			float4 _BaseTex_ST;
			float _GlossPower;
			float _FresnelPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);

				o.normalWS = UnityObjectToWorldNormal(v.normalOS);
				o.viewWS = WorldSpaceViewDir(v.positionOS);

                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				float3 normal = normalize(i.normalWS);
				float3 view = normalize(i.viewWS);

				float3 ambient = ShadeSH9(half4(i.normalWS, 1));

				float3 diffuse = _LightColor0 * max(0, dot(normal, _WorldSpaceLightPos0.xyz));

				float3 halfVector = normalize(_WorldSpaceLightPos0 + view);
				float specular = max(0, dot(normal, halfVector));
				specular = pow(specular, _GlossPower);
				float3 specularColor = _LightColor0 * specular;

				float fresnel = 1.0f - max(0, dot(normal, view));
				fresnel = pow(fresnel, _FresnelPower);
				float3 fresnelColor = _LightColor0 * fresnel;

				float4 diffuseLighting = float4(ambient + diffuse, 1.0f);
				float4 specularLighting = float4(specularColor + fresnelColor, 1.0f);

				float4 textureSample = tex2D(_BaseTex, i.uv);
                return textureSample * _BaseColor * diffuseLighting + specularLighting;
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