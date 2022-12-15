Shader "Examples/GouraudShading"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex("Base Texture", 2D) = "white" {}
		_GlossPower("Gloss Power", Float) = 400
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
				float4 diffuseLighting : TEXCOORD1;
				float4 specularLighting : TEXCOORD2;
            };

			sampler2D _BaseTex;

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor;
				float4 _BaseTex_ST;
				float _GlossPower;
			CBUFFER_END

            v2f vert (appdata v)
            {
				v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);

				float3 normalWS = TransformObjectToWorldNormal(v.normalOS);
				float3 positionWS = mul(unity_ObjectToWorld, v.positionOS);
				float3 viewWS = GetWorldSpaceNormalizeViewDir(positionWS);

				float3 ambient = SampleSHVertex(normalWS);

				Light mainLight = GetMainLight();

				float3 diffuse = mainLight.color * max(0, dot(normalWS, mainLight.direction));

				float3 halfVector = normalize(mainLight.direction + viewWS);
				float specular = max(0, dot(normalWS, halfVector));
				specular = pow(specular, _GlossPower);
				float3 specularColor = mainLight.color * specular;

				o.diffuseLighting = float4(ambient + diffuse, 1.0f);
				o.specularLighting = float4(specularColor, 1.0f);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);
				return textureSample * _BaseColor * i.diffuseLighting + i.specularLighting;
            }
            ENDHLSL
        }
    }
	Fallback Off
}
