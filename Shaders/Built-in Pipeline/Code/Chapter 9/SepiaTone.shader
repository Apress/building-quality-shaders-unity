Shader "Examples/SepiaTone"
{
    Properties
    {

    }
    SubShader
    {
        Tags 
		{ 
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		GrabPass {}

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

            sampler2D _SceneColorTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
				o.positionSS = ComputeScreenPos(o.positionCS);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				const float3x3 sepia = float3x3
				(
					0.393f, 0.349f, 0.272f,		// Red.
					0.769f, 0.686f, 0.534f,		// Green.
					0.189f, 0.168f, 0.131f		// Blue.
				);

				float2 screenUVs = i.positionSS.xy / i.positionSS.w;
				float3 sceneColor = tex2D(_SceneColorTexture, screenUVs);

				float3 outputColor = mul(sceneColor, sepia);

				return float4(outputColor, 1.0f);
            }
            ENDHLSL
        }
    }
}
