Shader "Examples/ImageEffects/GaussianBlur"
{
	HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

	static const float E = 2.71828f;

	float gaussian(int x, float sigma)
	{
		float twoSigmaSqu = 2 * sigma * sigma;
		return (1 / sqrt(PI * twoSigmaSqu)) * pow(E, -(x * x) / (2 * twoSigmaSqu));
	}

    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 texcoord   : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings Vert(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        return output;
    }

    // List of properties to control your post process effect
	int _KernelSize;
    TEXTURE2D_X(_SourceTex);
	TEXTURE2D(_TempTex);

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "Horizontal"

            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
            #pragma fragment HorizontalBlur
            #pragma vertex Vert

			float4 HorizontalBlur (Varyings input) : SV_Target
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				uint2 positionSS = input.texcoord * _ScreenSize.xy;

				float3 col = float3(0.0f, 0.0f, 0.0f);
				float kernelSum = 0.0f;
				float sigma = _KernelSize / 8.0f;

				int upper = ((_KernelSize - 1) / 2);
				int lower = -upper;

				for (int x = lower; x <= upper; ++x)
				{
					float gauss = gaussian(x, sigma);
					kernelSum += gauss;
					float2 uv = positionSS + float2(x, 0.0f);
					col += max(0, gauss * LOAD_TEXTURE2D_X(_SourceTex, uv).xyz);
				}

				col /= kernelSum;

				return float4(col, 1.0f);
			}
            ENDHLSL
        }

		Pass
        {
            Name "Vertical"

            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
            #pragma fragment VerticalBlur
            #pragma vertex Vert

			float4 VerticalBlur(Varyings input) : SV_Target
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				uint2 positionSS = input.texcoord * _ScreenSize.xy;

				float3 col = float3(0.0f, 0.0f, 0.0f);
				float kernelSum = 0.0f;
				float sigma = _KernelSize / 8.0f;

				int upper = ((_KernelSize - 1) / 2);
				int lower = -upper;

				for (int y = lower; y <= upper; ++y)
				{
					float gauss = gaussian(y, sigma);
					kernelSum += gauss;
					float2 uv = positionSS + float2(0.0f, y);
					col += max(0, gauss * LOAD_TEXTURE2D(_TempTex, uv).xyz);
				}

				col /= kernelSum;

				return float4(col, 1.0f);
			}
            ENDHLSL
        }
    }
    Fallback Off
}
