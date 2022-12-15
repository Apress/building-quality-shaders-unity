Shader "Examples/PolarCoordinates"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex ("Base Texture", 2D) = "white" {}
		_Center("Center", Vector) = (0.5,0.5,0,0)
		_RadialScale("Radial Scale", Float) = 1
		_LengthScale("Length Scale", Float) = 1
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
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
            };

			float4 _BaseColor;
			sampler2D _BaseTex;
			float4 _BaseTex_ST;
			float2 _Center;
			float _RadialScale;
			float _LengthScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

			float2 cartesianToPolar(float2 cartUV)
			{
				const float PI = 3.14159235f;
				float2 offset = cartUV - _Center;
				float radius = length(offset) * 2;
				float angle = atan2(offset.x, offset.y) / (2.0f * PI);

				return float2(radius, angle);
			}

			float4 frag(v2f i) : SV_Target
			{
				float2 radialUV = cartesianToPolar(i.uv);
				radialUV.x *= _RadialScale;
				radialUV.y *= _LengthScale;

				float4 textureSample = tex2D(_BaseTex, radialUV);
				return textureSample * _BaseColor;
			}
            ENDHLSL
        }
    }
	Fallback Off
}