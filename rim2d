Shader "Custom/Rim2d"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Step("float", range(0, 0.1)) = 0
		_Color("color", Color) = (0,0,0,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		pass {


				Blend SrcAlpha OneMinusSrcAlpha
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 pos : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float4 _Color;

				float _Step;

				v2f vert(appdata v)
				{
					v2f o;
					float4 vert = v.vertex;
					o.pos = mul(UNITY_MATRIX_MVP, vert);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float2 olduv = i.uv;

					if (_Step > 0) {
						i.uv.x = _Step + i.uv.x / 0.5 * (0.5 - _Step);
						i.uv.y = _Step + i.uv.y / 0.5 * (0.5 - _Step);
					}

					fixed4 col = tex2D(_MainTex, i.uv);
					fixed4 oldcol = tex2D(_MainTex, olduv);

					col.a /= 2;

					if (oldcol.a > 0.1) {
						return oldcol;
					}
					//d0ff00

					col.rgb = _Color.rgb;

					return col;
				}
				ENDCG

		}
	}
}
