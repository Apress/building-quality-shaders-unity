Shader "Examples/Waves"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex("Base Texture", 2D) = "white" {}
		_WaveStrength("Wave Strength", Range(0, 2)) = 0.1
		_WaveSpeed("Wave Speed", Range(0, 10)) = 1

		[Enum(UnityEngine.Rendering.BlendMode)]
		_SrcBlend("Source Blend Factor", Int) = 1

		[Enum(UnityEngine.Rendering.BlendMode)]
		_DstBlend("Destination Blend Factor", Int) = 1

		_TessAmount("Tessellation Amount", Range(1, 64)) = 2
    }
	SubShader
    {
        Tags 
		{ 
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

        Pass
        {
			Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM
            #pragma vertex tessVert
            #pragma fragment frag
			#pragma hull tessHull
			#pragma domain tessDomain
			#pragma target 4.6

			#include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : Position;
				float2 uv : TEXCOORD0;
            };

			struct tessControlPoint 
			{
				float4 positionOS : INTERNALTESSPOS;
				float2 uv : TEXCOORD0;
			};

            struct v2f
            {
                float4 positionCS : SV_Position;
				float2 uv : TEXCOORD0;
            };

			struct tessFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			sampler2D _BaseTex;
			float4 _BaseColor;
			float4 _BaseTex_ST;
			float _TessAmount;
			float _WaveStrength;
			float _WaveSpeed;
			
			tessControlPoint tessVert(appdata v)
			{
				tessControlPoint o;
				o.positionOS = v.positionOS;
				o.uv = v.uv;
				return o;
			}

            v2f vert(appdata v)
            {
				v2f o;

				float4 positionWS = mul(unity_ObjectToWorld, v.positionOS);
				float height = sin(_Time.y * _WaveSpeed + positionWS.x + positionWS.z);
				positionWS.y += height * _WaveStrength;

                o.positionCS = mul(UNITY_MATRIX_VP, positionWS);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

			float tessEdgeFactor(appdata vert0, appdata vert1)
			{
				float v0 = vert0.positionOS.xyz;
				float v1 = vert1.positionOS.xyz;
				float edgeLength = distance(v0, v1);

				return edgeLength / 1.0f;
			}

			tessFactors patchConstantFunc(InputPatch<tessControlPoint, 3> patch)
			{
				tessFactors f;

				f.edge[0] = f.edge[1] = f.edge[2] = _TessAmount;
				f.inside = _TessAmount;

				return f;
			}

			[domain("tri")]
			[outputcontrolpoints(3)]
			[outputtopology("triangle_cw")]
			[partitioning("integer")]
			[patchconstantfunc("patchConstantFunc")]
			tessControlPoint tessHull(InputPatch<tessControlPoint, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			v2f tessDomain(tessFactors factors, OutputPatch<tessControlPoint, 3> patch, float3 barycentricCoords : SV_DomainLocation)
			{
				appdata i;

				#define INTERPOLATE(fieldname) i.fieldname = \
					patch[0].fieldname * barycentricCoords.x + \
					patch[1].fieldname * barycentricCoords.y + \
					patch[2].fieldname * barycentricCoords.z;

				INTERPOLATE(positionOS)
				INTERPOLATE(uv)

				return vert(i);
			}

            float4 frag(v2f i) : SV_Target
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);
				return textureSample * _BaseColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}
