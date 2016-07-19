Shader "Custom/combine"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BloomTex ("Texture", 2D) = "white" {}
		_BloomFactor("Bloom Factor",Range(0,10)) = 2.0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _BloomTex;
			float _BloomFactor;

			float4 ColorBurn (float4 a, float4 b) { return (1-(1-a)/b); }


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 mainColor = tex2D(_MainTex, i.uv);
				#if SHADER_API_D3D9 || SHADER_API_D3D11
				i.uv.y = 1f - i.uv.y;
				#endif
				fixed4 bloomColor = tex2D(_BloomTex, i.uv);
				fixed4 finalColor = bloomColor *_BloomFactor + mainColor;
				return finalColor;
			}
			ENDCG
		}
	}
}
