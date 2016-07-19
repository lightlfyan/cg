Shader "Hidden/PosOutline"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		offsets("offsets", color) = (0,0,0,0)
		g_SolidSilhouette ("g_SolidSilhouette", 2D) = "white" {}
		g_BlurSilhouette ("g_BlurSilhouette", 2D) = "white" {}
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

			fixed4 frag (v2f i) : SV_Target
			{
				float4 uv = float4(i.uv.x, i.uv.y, 0, 0.25);
				fixed4 col = tex2Dlod(_MainTex, uv);
				return col;
			}
			ENDCG
		}

		// pass2

		Pass
		{

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
	
	struct v2f {
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;

		float4 uv01 : TEXCOORD1;
		float4 uv23 : TEXCOORD2;
		float4 uv45 : TEXCOORD3;

		float4 uv67 : TEXCOORD4;
	};
	
	float4 offsets;
	
	sampler2D _MainTex;
		
	v2f vert (appdata_img v) {
		float offx = 1.0 / _ScreenParams.x;
		float offy = 1.0 / _ScreenParams.y;
		offsets = float4(offx, offy, offx, offy);

		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

		o.uv.xy = v.texcoord.xy;

		o.uv01 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1);
		o.uv23 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 2.0;
		o.uv45 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 3.0;

		o.uv67 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 4.5;
		o.uv67 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 7.0;

		return o;  
	}
		
	half4 frag (v2f i) : COLOR {
		half4 color = float4 (0,0,0,0);

		color += 0.250 * tex2D (_MainTex, i.uv);
		color += 0.150 * tex2D (_MainTex, i.uv01.xy);
		color += 0.150 * tex2D (_MainTex, i.uv01.zw);
		color += 0.110 * tex2D (_MainTex, i.uv23.xy);
		color += 0.110 * tex2D (_MainTex, i.uv23.zw);
		color += 0.075 * tex2D (_MainTex, i.uv45.xy);
		color += 0.075 * tex2D (_MainTex, i.uv45.zw);	
		color += 0.040 * tex2D (_MainTex, i.uv67.xy);
		color += 0.040 * tex2D (_MainTex, i.uv67.zw);
		
		return color;
	} 

	ENDCG
		}

		// pass3

		Pass
		{

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
	
	struct v2f {
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;

		float4 uv01 : TEXCOORD1;
		float4 uv23 : TEXCOORD2;
		float4 uv45 : TEXCOORD3;

		float4 uv67 : TEXCOORD4;
	};
	
	float4 offsets;
	
	sampler2D _MainTex;
		
	v2f vert (appdata_img v) {
		float offx = 1.0 / _ScreenParams.x;
		float offy = 1.0 / _ScreenParams.y;
		offsets = float4(offx, offy, offx, offy);

		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

		o.uv.xy = v.texcoord.xy;

		o.uv01 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1);
		o.uv23 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 2.0;
		o.uv45 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 3.0;

		o.uv67 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 4.5;
		o.uv67 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 7.0;

		return o;  
	}
		
	half4 frag (v2f i) : COLOR {
		half4 color = float4 (0,0,0,0);

		color += 0.250 * tex2D (_MainTex, i.uv);
		color += 0.150 * tex2D (_MainTex, i.uv01.xy);
		color += 0.150 * tex2D (_MainTex, i.uv01.zw);
		color += 0.110 * tex2D (_MainTex, i.uv23.xy);
		color += 0.110 * tex2D (_MainTex, i.uv23.zw);
		color += 0.075 * tex2D (_MainTex, i.uv45.xy);
		color += 0.075 * tex2D (_MainTex, i.uv45.zw);	
		color += 0.040 * tex2D (_MainTex, i.uv67.xy);
		color += 0.040 * tex2D (_MainTex, i.uv67.zw);
		
		return color;
	} 

	ENDCG
		}


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
			
			sampler2D g_SolidSilhouette;
			sampler2D g_BlurSilhouette;
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				fixed4 main = tex2D(_MainTex, uv);
				fixed4 col1 = tex2D(g_SolidSilhouette, uv);
				fixed4 col2 = tex2D(g_BlurSilhouette, uv);
				if(col1.a > 0.8){
					col2.rgb *= (1-col1.a);
				}
				return main + col2 * 1.2;
			}
			ENDCG
		}
	}
}
