Shader "Examples/ImageEffects/Greyscale"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Strength("Strength", Float) = 0
    }
	SubShader
    {
        Tags 
		{ 
			"RenderType"="Opaque"
			"RenderPipeline"="UniversalPipeline"
		}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			struct appdata
            {
                float4 positionOS : Position;
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
				float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;

			CBUFFER_START(UnityPerMaterial)
				float _Strength;
			CBUFFER_END

			v2f vert (appdata v)
			{
				v2f o;
				o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				o.uv = v.uv;
				return o;
			}

            float4 frag (v2f i) : SV_Target
            {
				float4 textureSample = tex2D(_MainTex, i.uv);

				float3 outputColor = Luminance(textureSample);

				return lerp(textureSample, float4(outputColor, 1.0f), _Strength);
            }
            ENDHLSL
        }
    }
}
