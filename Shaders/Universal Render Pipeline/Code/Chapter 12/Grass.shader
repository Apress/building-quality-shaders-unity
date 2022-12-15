Shader "Examples/Grass"
{
	Properties
	{
		_BaseColor("Base Color", Color) = (0, 0, 0, 1)
		_TipColor("Tip Color", Color) = (1, 1, 1, 1)
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

			struct v2f
			{
				float4 positionCS : SV_Position;
				float2 uv : TEXCOORD0;
			};

			StructuredBuffer<float3> _Positions;
			StructuredBuffer<float2> _UVs;
			StructuredBuffer<float4x4> _TransformMatrices;

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor;
				float4 _TipColor;
			CBUFFER_END

            v2f vert (uint vertexID : SV_VertexID, uint instanceID : SV_InstanceID)
            {
				float4x4 mat = _TransformMatrices[instanceID];

				v2f o;

				float4 pos = float4(_Positions[vertexID], 1.0f);
				pos = mul(mat, pos);
				o.positionCS = mul(UNITY_MATRIX_VP, pos);

				o.uv = _UVs[vertexID];

				return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				return lerp(_BaseColor, _TipColor, i.uv.y);
            }
            ENDHLSL
        }
    }
	Fallback Off
}
