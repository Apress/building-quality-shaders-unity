Shader "Examples/PhongShading"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex("Base Texture", 2D) = "white" {}
		_GlossPower("Gloss Power", Float) = 400
		_FresnelPower("Fresnel Power", Float) = 5
    }
	SubShader
    {
        Tags 
		{ 
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
			"RenderPipeline" = "UniversalPipeline"
		}

        Pass
        {
			Tags
			{
				"LightMode" = "UniversalForward"
			}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

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

			sampler2D _BaseTex;

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor;
				float4 _BaseTex_ST;
				float _GlossPower;
				float _FresnelPower;
			CBUFFER_END

            v2f vert (appdata v)
            {
				v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
				o.normalWS = TransformObjectToWorldNormal(v.normalOS);

				float3 positionWS = mul(unity_ObjectToWorld, v.positionOS);
				o.viewWS = GetWorldSpaceViewDir(positionWS);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float3 normal = normalize(i.normalWS);
				float3 view = normalize(i.viewWS);

				float3 ambient = SampleSH(i.normalWS);

				Light mainLight = GetMainLight();

				float3 diffuse = mainLight.color * max(0, dot(normal, mainLight.direction));

				float3 halfVector = normalize(mainLight.direction + view);
				float specular = max(0, dot(normal, halfVector));
				specular = pow(specular, _GlossPower);
				float3 specularColor = mainLight.color * specular;

				float fresnel = 1.0f - max(0, dot(normal, view));
				fresnel = pow(fresnel, _FresnelPower);
				float3 fresnelColor = mainLight.color * fresnel;

				float4 diffuseLighting = float4(ambient + diffuse, 1.0f);
				float4 specularLighting = float4(specularColor + fresnelColor, 1.0f);

				float4 textureSample = tex2D(_BaseTex, i.uv);
				return textureSample * _BaseColor * diffuseLighting + float4(specularColor, 1.0f);
            }
            ENDHLSL
        }
    }
	Fallback Off
}
