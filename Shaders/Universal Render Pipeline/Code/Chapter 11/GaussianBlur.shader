Shader "Examples/ImageEffects/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
	SubShader
    {
        Tags 
		{ 
			"RenderType"="Opaque"
			"RenderPipeline"="UniversalPipeline"
		}

		HLSLINCLUDE

		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		static const float E = 2.71828f;

		float gaussian(int x, float sigma)
		{
			float twoSigmaSqu = 2 * sigma * sigma;
			return (1 / sqrt(PI * twoSigmaSqu)) * pow(E, -(x * x) / (2 * twoSigmaSqu));
		}

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
			float4 _MainTex_TexelSize;
			uint _KernelSize;
		CBUFFER_END

		v2f vert (appdata v)
		{
			v2f o;
			o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
			o.uv = v.uv;
			return o;
		}

		ENDHLSL

		Pass
		{
			Name "Horizontal"

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment fragHorizontal

			float4 fragHorizontal (v2f i) : SV_Target
            {
				float3 col = float3(0.0f, 0.0f, 0.0f);
				float kernelSum = 0.0f;
				float sigma = _KernelSize / 8.0f;

				int upper = ((_KernelSize - 1) / 2);
				int lower = -upper;

				for (int x = lower; x <= upper; ++x)
				{
					float gauss = gaussian(x, sigma);
					kernelSum += gauss;
					float2 uv = i.uv + float2(_MainTex_TexelSize.x * x, 0.0f);
					col += max(0, gauss * tex2D(_MainTex, uv).xyz);
				}

				col /= kernelSum;

				return float4(col, 1.0f);
            }
            ENDHLSL
        }

		Pass
		{
			Name "Vertical"

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment fragVertical

			float4 fragVertical (v2f i) : SV_Target
            {
				float3 col = float3(0.0f, 0.0f, 0.0f);
				float kernelSum = 0.0f;
				float sigma = _KernelSize / 8.0f;

				int upper = ((_KernelSize - 1) / 2);
				int lower = -upper;

				for (int y = lower; y <= upper; ++y)
				{
					float gauss = gaussian(y, sigma);
					kernelSum += gauss;
					float2 uv = i.uv + float2(0.0f, _MainTex_TexelSize.y * y);
					col += max(0, gauss * tex2D(_MainTex, uv).xyz);
				}

				col /= kernelSum;

				return float4(col, 1.0f);
            }
            ENDHLSL
        }
    }
}
