Shader "Custom/toon" {
	Properties {
		 _MainTex ("Base (RGB)", 2D) = "white" {}
		 _AlphaTex ("Base (RGB)", 2D) = "white" {}
		_Color("Main Color",color)=(1,1,1,1)//物体的颜色
		
		_LineColor("Line Color",color)=(0,0,0,1)//物体的颜色
		_Outline("Outline length",range(0,0.1))=0.01//挤出描边的粗细
		_Factor("Factor",range(0,1))=0.5//挤出多远
		_ToonEffect("Toon Effect",range(0,1))=0.5//卡通化程度（二次元与三次元的交界线）
		_Steps("Steps of toon",range(0,9))=3//色阶层数
		
		_RimColor("rim color", color) = (1,1,1,1)
		_RimWidth ("rim Width", Range(0, 1)) = 0.1
		_RimPower("rim Power",float) = 3
		_FinalPower("FinalPower",float) = 1.3
		
		_RampTex ("Ramp Texture", 2D) = "white"{}  
	}
	SubShader {
		/*
		pass{//处理光照前的pass渲染
		Tags{"LightMode"="Always"}
		Cull Front
		ZWrite On
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		float _Outline;
		float _Factor;
		float4 _LineColor;
		
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		
		struct v2f {
			float4 pos:SV_POSITION;
			float2 uv: TEXCOORD0;
		};

		v2f vert (appdata_full v) {
			v2f o;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			
			float3 dir=normalize(v.vertex.xyz);
			float3 dir2=v.normal;
			float D=dot(dir,dir2);
			dir=dir*sign(D);
			dir=dir*_Factor+dir2*(1-_Factor);


			//v.vertex.xyz + = dir * _Outline;

			v.vertex.xyz += v.normal * _Outline;

			o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
			return o;
		}
		float4 frag(v2f i):COLOR
		{
			float4 texcol = tex2D(_MainTex, i.uv);
			/*
			_LineColor.a = texcol.a;
			clip(_LineColor.a - 0.5);
			*/
			return _LineColor;
		}
		ENDCG
		}
		*/

		pass{//平行光的的pass渲染
		Tags{"LightMode"="ForwardBase"}
		Cull Back
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		uniform sampler2D _MainTex;
		uniform sampler2D _AlphaTex;
		uniform float4 _AlphaTex_ST;

		uniform float4 _MainTex_ST;
		uniform sampler2D _RampTex;
		uniform float4 _RampTex_ST;
		
		
		float4 _LightColor0;
		float4 _Color;
		float _Steps;
		float _ToonEffect;
		uniform float4 _RimColor;
		uniform float _RimWidth;
		uniform float _RimPower;
		uniform float _FinalPower;

		struct v2f {
			float4 pos:SV_POSITION;
			float2 uv: TEXCOORD0;
			float3 lightDir:TEXCOORD1;
			float3 viewDir:TEXCOORD2;
			float3 normal:TEXCOORD3;
			float3 uv2:TEXCOORD4;
			float3 factor : COLOR;
		};

		v2f vert (appdata_full v) {
			v2f o;
			o.pos=v.vertex;
			o.pos=mul(UNITY_MATRIX_MVP, o.pos);//切换到世界坐标

			o.normal=v.normal;

			o.lightDir =  ObjSpaceViewDir(v.vertex);
			//o.lightDir = WorldSpaceLightDir(v.vertex);
			o.viewDir = ObjSpaceViewDir(v.vertex);
			
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			
            float dotProduct = 1.0 - saturate(dot(v.normal, o.viewDir ));
			o.factor  = smoothstep(1.0 - _RimWidth, 1.0, pow(dotProduct,_RimPower));

			return o;
		}
		float4 frag(v2f i):COLOR
		{
			float4 c=1;
			float3 N=normalize(i.normal);
			float3 viewDir=normalize(i.viewDir);
			float3 lightDir=normalize(i.lightDir);

			//float3 lightDir = _WorldSpaceLightPos0;
			float diff= max(0,dot(N,i.lightDir));//求出正常的漫反射颜色

			/*
			float hLambert  = diff * 0.5 + 0.5f;
			float3 ramp = tex2D(_RampTex, float2(hLambert)).rgb;
			diff=(diff+1)/2;//做亮化处理
			diff=smoothstep(0,1,diff);//使颜色平滑的在[0,1]范围之内
			float toon=floor(diff*_Steps)/_Steps;//把颜色做离散化处理，把diffuse颜色限制在_Steps种（_Steps阶颜色），简化颜色，这样的处理使色阶间能平滑的显示
			diff=lerp(diff, toon, _ToonEffect);//根据外部我们可控的卡通化程度值_ToonEffect，调节卡通与现实的比重
			*/

			float4 texcol = tex2D(_MainTex, i.uv);
			//texcol.rgb *= ramp;


			float intensity = max(0, dot(lightDir, N));
			intensity = floor(intensity*2)/2;



			/*
			if(intensity <0){
				intensity = 0;
			} else {
				intensity = 1;
			}

			intensity = 1 + clamp(floor(intensity), -1, 0);
			intensity = smoothstep(0, 0.025, intensity);

			intensity = smoothstep(0, 1, intensity);
			//float toon1 = floor(intensity*10)/10;
			//float toon1 = intensity;
			intensity = floor(intensity*16)/16;
			*/

			/*
			if(intensity > 0.95){
				texcol = float4(1, 0.5, 0.5, 1) * texcol;
			} else if(intensity > 0.5) {
				texcol = float4(0.6, 0.3, 0.3, 1) * texcol;
			} else if(intensity > 0.25) {
				texcol = float4(0.4, 0.2, 0.2, 1) * texcol;
			} else {
				texcol = float4(0.2, 0.1, 0.1, 1.0) * texcol;
			}
			*/

			clip(texcol.a - 0.5);

			/*
			float4 alpha = tex2D(_AlphaTex, i.uv2);
			clip(alpha.a - 0.5);
			texcol.a = alpha.a;
			*/


			return texcol;

			//return texcol * _FinalPower ;

		}
		ENDCG
		}//
		
	} 
}