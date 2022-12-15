Shader "Examples/Xray"
{
    Properties
    {
		_XrayColor("X-ray Color", Color) = (1, 0, 0, 1)
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
			ZTest Greater
			ZWrite Off

			Tags
			{
				"LightMode" = "UniversalForward"
			}

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			struct appdata
			{
				float4 positionOS : POSITION;
			};

			struct v2f
			{
				float4 positionCS : SV_POSITION;
			};

			CBUFFER_START(UnityPerMaterial)
				float4 _XrayColor;
			CBUFFER_END

			v2f vert(appdata v)
			{
				v2f o;
				o.positionCS = TransformObjectToHClip(v.positionOS);
				return o;
			}

			float4 frag(v2f i) : SV_TARGET
			{
				return _XrayColor;
			}
			ENDHLSL
        }
    }
}
