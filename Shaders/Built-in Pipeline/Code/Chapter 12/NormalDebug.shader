Shader "Examples/NormalDebug"
{
	Properties
	{
		_DebugColor("Debug Color", Color) = (0, 0, 0, 1)
		_WireThickness("Wire Thickness", Range(0, 0.1)) = 0.01
		_WireLength("Wire Length", Range(0, 1)) = 0.2
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
			Cull Off

			HLSLPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _DebugColor;
			float _WireThickness;
			float _WireLength;

            struct appdata
            {
                float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
            };

            struct v2g
            {
                float4 positionWS : SV_POSITION;
				float3 normalWS : NORMAL;
				float4 tangentWS : TANGENT;
            };

            struct g2f
            {
                float4 positionCS : SV_POSITION;
            };

            v2g vert (appdata v)
            {
                v2g o;

				o.positionWS = mul(unity_ObjectToWorld, v.positionOS);
				o.normalWS = UnityObjectToWorldNormal(v.normalOS);
				o.tangentWS = mul(unity_ObjectToWorld, v.tangentOS);
                return o;
            }

			g2f geomToClip(float3 positionOS, float3 offsetOS)
			{
				g2f o;
				o.positionCS = mul(UNITY_MATRIX_VP, float4(positionOS + offsetOS, 1.0f));
				return o;
			}

            [maxvertexcount(8)]
            void geom(point v2g i[1], inout TriangleStream<g2f> triStream)
            {
				float3 normal = normalize(i[0].normalWS);
				float4 tangent = normalize(i[0].tangentWS);
				float3 bitangent = normalize(cross(normal, tangent.xyz) * tangent.w);

				float3 xOffset = tangent * _WireThickness * 0.5f;
				float3 yOffset = normal * _WireLength;
				float3 zOffset = bitangent * _WireThickness * 0.5f;

				float3 offsets[8] = 
				{
					-xOffset,
					 xOffset,
					-xOffset + yOffset,
					 xOffset + yOffset,

					-zOffset,
					 zOffset,
					-zOffset + yOffset,
					 zOffset + yOffset
				};

				float4 pos = i[0].positionWS;

				triStream.Append(geomToClip(pos, offsets[0]));
				triStream.Append(geomToClip(pos, offsets[1]));
				triStream.Append(geomToClip(pos, offsets[2]));
				triStream.Append(geomToClip(pos, offsets[3]));

				triStream.RestartStrip();

				triStream.Append(geomToClip(pos, offsets[4]));
				triStream.Append(geomToClip(pos, offsets[5]));
				triStream.Append(geomToClip(pos, offsets[6]));
				triStream.Append(geomToClip(pos, offsets[7]));

				triStream.RestartStrip();
            }

            float4 frag (g2f i) : SV_Target
            {
				return _DebugColor;
            }
            ENDHLSL
        }
    }
}