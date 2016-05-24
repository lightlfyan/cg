Shader "Unlit/sobel"
{
	//posteffect outline
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Width("width", Range(0.05, 1)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			float _Width;
			
			fixed4 frag (v2f i) : SV_Target
			{
				float off = 1.0/256.0;

				float s00 = tex2D(_MainTex, i.uv + float2(-off, -off));
				float s01 = tex2D(_MainTex, i.uv + float2(0, -off));
				float s02 = tex2D(_MainTex, i.uv + float2(off, -off));

				float s10 = tex2D(_MainTex, i.uv + float2(-off, 0));
				float s12 = tex2D(_MainTex, i.uv + float2(off, 0));


				float s20 = tex2D(_MainTex, i.uv + float2(-off, off));
				float s21 = tex2D(_MainTex, i.uv + float2(0, off));
				float s22 = tex2D(_MainTex, i.uv + float2(off, off));

				float sobelx = s00 + 2 * s10 + s20 - s02 - 2 * s12 - s22;
				float sobely = s00 + 2 * s01 + s02 - s20 - 2 * s21 - s22;

				float edgesqr = (sobelx * sobelx + sobely*sobely);
				return 1.0 - (edgesqr > (_Width * _Width));


				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
