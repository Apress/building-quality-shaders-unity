Shader "Examples/Silhouette"
{
    Properties
    {
        _ForegroundColor ("Foreground Color", Color) = (1, 1, 1, 1)
		_BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
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
			ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : Position;
            };

            struct v2f
            {
                float4 positionCS : SV_Position;
				float4 positionSS : TEXCOORD0;
            };

			float4 _ForegroundColor;
			float4 _BackgroundColor;

			sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.positionSS = ComputeScreenPos(o.positionCS);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float2 screenUVs = i.positionSS.xy / i.positionSS.w;
				float rawDepth = tex2D(_CameraDepthTexture, screenUVs).r;
				float scene01Depth = Linear01Depth(rawDepth);

				float4 outputColor = lerp(_ForegroundColor, _BackgroundColor, scene01Depth);

				return outputColor;
            }
            ENDHLSL
        }
    }
}
