Shader "Examples/Flipbook"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_BaseTex ("Base Texture", 2D) = "white" {}
		_FlipbookSize("Flipbook Size", Vector) = (1,1,0,0)
		_Speed("Animation Speed", Float) = 1
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
			float2 _FlipbookSize;
			float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);

				float2 tileSize = float2(1.0f, 1.0f) / _FlipbookSize;
				float width = _FlipbookSize.x;
				float height = _FlipbookSize.y;
				float tileCount = width * height;

				float tileID = floor((_Time.y * _Speed) % tileCount);

				float tileX = (tileID % width) * tileSize.x;
				float tileY = (floor(tileID / width)) * tileSize.y;

				o.uv = float2(v.uv.x / width + tileX, v.uv.y / height + tileY);

                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
				float4 textureSample = tex2D(_BaseTex, i.uv);
                return textureSample * _BaseColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}