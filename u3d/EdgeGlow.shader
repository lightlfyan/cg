Shader "Unlit/EdgeGlow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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

			float lookup(float2 p, float dx, float dy)
			{

				p += float2(dx, dy);
				fixed4 c = tex2D(_MainTex, p);
			    return 0.2126*c.r + 0.7152*c.g + 0.0722*c.b;

			    /*
				//TODO move out
				float d = sin(_Time.y * 5.0)*0.5 + 1.5;
			    float2 uv = (p.xy + float2(dx * d, dy * d)) / _ProjectionParams.xy;
			    float4 c = tex2D(_MainTex, uv);
				// return as luma
			    return 0.2126*c.r + 0.7152*c.g + 0.0722*c.b;
			    */
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float off = 1.0/256.0;

				float2 p = i.uv.xy;
				float gx = 0.0;
			    gx += -1.0 * lookup(p, -off, -off);
			    gx += -2.0 * lookup(p, -off,  off);
			    gx += -1.0 * lookup(p, -off,  off);
			    gx +=  1.0 * lookup(p,  off, -off);
			    gx +=  2.0 * lookup(p,  off,  off);
			    gx +=  1.0 * lookup(p,  off,  off);

			    float gy = 0.0;			   
			    gy += -1.0 * lookup(p, -off, -off);
			    gy += -2.0 * lookup(p,  off, -off);
			    gy += -1.0 * lookup(p,  off, -off);
			    gy +=  1.0 * lookup(p, -off,  off);
			    gy +=  2.0 * lookup(p,  off,  off);
			    gy +=  1.0 * lookup(p,  off,  off);

			    // hack: use g^2 to conceal noise in the video
			    float g = gx*gx + gy*gy;
			    float g2 = g * (sin(_Time.z) / 2.0 + 0.5);
	    
			    float4 col = tex2D(_MainTex, p);
			    col += float4(0.0, g, g2, 1.0);

				return col;
			}

			ENDCG
		}
	}
}
