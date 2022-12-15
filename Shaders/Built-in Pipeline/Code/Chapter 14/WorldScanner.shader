Shader "Examples/ImageEffect/WorldScan"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_ScanOrigin("Origin Point", Vector) = (0, 0, 0, 0)
		_ScanDist("Scan Distance", Float) = 0
		_ScanWidth("Scan Width", Float) = 1
		_OverlayRampTex("Overlay Ramp", 2D) = "white" {}
		[HDR] _OverlayColor("Overlay Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
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
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

			sampler2D _MainTex;
			sampler2D _OverlayRampTex;
			sampler2D _CameraDepthTexture;

			float3 _ScanOrigin;
			float _ScanDist;
			float _ScanWidth;
			float4 _OverlayColor;

			float4x4 _ClipToWorld;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS.xyz);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float depthSample = tex2D(_CameraDepthTexture, i.uv).r;

#if UNITY_REVERSED_Z
				float depth = depthSample;
#else
				float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, depthSample);
#endif

				float4 pixelPositionCS = float4(i.uv * 2.0f - 1.0f, depth, 1.0f);

#if UNITY_UV_STARTS_AT_TOP
				pixelPositionCS.y = -pixelPositionCS.y;
#endif

				float4 pixelPositionWS = mul(_ClipToWorld, pixelPositionCS);

				float3 worldPos = pixelPositionWS.xyz / pixelPositionWS.w;

				float fragDist = distance(worldPos, _ScanOrigin);

				float4 scanColor = 0.0f;

				if (fragDist < _ScanDist && fragDist > _ScanDist - _ScanWidth)
				{
					float scanUV = (fragDist - _ScanDist) / (_ScanWidth * 1.01f);

					scanColor = tex2D(_OverlayRampTex, float2(scanUV, 0.5f));
					scanColor *= _OverlayColor;
				}

				float4 textureSample = tex2D(_MainTex, i.uv);

				return lerp(textureSample, scanColor, scanColor.a);
            }
            ENDHLSL
        }
    }
}
