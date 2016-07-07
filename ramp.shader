Shader "Custom/ramp"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RampTex ("_RampTex", 2D) = "white" {}
		_RimColor("RimColor", Color) = (0,0,0,0)
		_RimWidth("_RimWidth", range(0, 1)) = 0.5
		_RimPower("_RimPower", float) = 1

	}
	SubShader
	{
		pass{
		Tags{"LightMode"="ForwardBase"}
		Cull Back
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		#include "Lighting.cginc"

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		
		unifom sampler2D _RampTex;

		float4 _Color;
		uniform float4 _RimColor;
		uniform float _RimWidth;
		uniform float _RimPower;

		struct v2f {
			float4 pos:SV_POSITION;
			float2 uv: TEXCOORD0;
			float3 lightDir:TEXCOORD1;
			float3 viewDir:TEXCOORD2;
			float3 normal:TEXCOORD3;
			fixed3 factor : COLOR;
		};

		v2f vert (appdata_full v) {
			v2f o;
			o.pos=v.vertex;
			o.pos=mul(UNITY_MATRIX_MVP, o.pos);//切换到世界坐标

			o.normal=v.normal;

			o.lightDir = WorldSpaceLightDir(v.vertex);
			o.viewDir = ObjSpaceViewDir(v.vertex);
			
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			
            float dotProduct = 1.0 - saturate(dot(v.normal, o.viewDir));
			o.factor  = _RimColor * smoothstep(1.0 - _RimWidth, 1.0, pow(dotProduct, _RimPower));


			return o;
		}
		float4 frag(v2f i):COLOR
		{
			float4 c=1;
			float3 N=normalize(i.normal);
			float3 viewDir=normalize(i.viewDir);
			float3 lightDir=normalize(i.lightDir);

			float dotProduct = 1 - dot(N, viewDir);
			float4 rimcolor = _RimColor * smoothstep(1 - _RimWidth, 1.0, dotProduct);r

	
			float diff= max(0,dot(N,i.lightDir));
			float hLambert  = diff * 0.5 + 0.5f;

			
			//diff=(diff+1)/2;//做亮化处理
			//diff=smoothstep(0,1,diff);//使颜色平滑的在[0,1]范围之内
			
			float diflight = max(0, dot(i.normal, lightDir);
			float rimLight = max(0, dot(i.normal, viewDir);
			float dif_hLambert = diflight * 0.5 + 0.5;
			float ramp = tex2D(_RampTex, float2(dif_hLambert, rimLight).rgb;
		

			float4 texcol = tex2D(_MainTex, i.uv);
			texcol.rgb = texcol.rgb * _LightColor0.rgb *  hLambert * 2 * ramp;
			texcol.rgb += i.factor;

			clip(texcol.a - 0.5);
			return texcol;
		}
		ENDCG
		}//
	}
}
