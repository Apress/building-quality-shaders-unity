Shader "Examples/InteractiveSnow"
{
    Properties
    {
		[HDR] _LowColor("Low Snow Color", Color) = (0, 0, 0, 1)
		[HDR] _HighColor("High Snow Color", Color) = (1, 1, 1, 1)
		_BaseTex("Base Texture", 2D) = "white" {}

		_SnowOffset("Snow Offset", 2D) = "white" {}
		_MaxSnowHeight("Max Snow Height", Float) = 0.5

		_TessAmount("Tessellation Amount", Range(1, 64)) = 2
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

			struct tessFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			struct v2f
			{
				float4 positionCS : SV_Position;
				float2 uv : TEXCOORD0;
			};

			sampler2D _BaseTex;
			sampler2D _SnowOffset;
			float4 _LowColor;
			float4 _HighColor;
			float4 _BaseTex_ST;
			float _MaxSnowHeight;
			float _TessAmount;

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

				float heightOffset = tex2Dlod(_SnowOffset, float4(v.uv, 0, 0));

				float4 positionWS = mul(unity_ObjectToWorld, v.positionOS);
				positionWS.y += lerp(0, _MaxSnowHeight, heightOffset);

				o.positionCS = mul(UNITY_MATRIX_VP, positionWS);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
				return o;
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
			v2f tessDomain(tessFactors factors, OutputPatch<tessControlPoint, 3> patch, float3 bcCoords : SV_DomainLocation)
			{
				appdata i;

				i.positionOS = patch[0].positionOS * bcCoords.x +
					patch[1].positionOS * bcCoords.y +
					patch[2].positionOS * bcCoords.z;

				i.uv = patch[0].uv * bcCoords.x +
					patch[1].uv * bcCoords.y +
					patch[2].uv * bcCoords.z;

				return vert(i);
			}

			float4 frag(v2f i) : SV_Target
			{
				float snowHeight = tex2D(_SnowOffset, i.uv).r;
				float4 textureSample = tex2D(_BaseTex, i.uv);
				return textureSample * lerp(_LowColor, _HighColor, snowHeight);
			}

            ENDHLSL
        }
    }
}
