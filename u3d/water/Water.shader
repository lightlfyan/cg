Shader "Custom/Water"
{
	Properties 
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Range(0.01,5) ) = 0.01
		_MainTex("Base (RGB) Gloss (A)", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_RefractionColor("Refraction Color", Color ) = (1,1,1,1)
		_RefractionDis("Refraction Distortion", Range(0,1) ) = 1
		_ReflectColor("Reflection Color", Color) = (1,1,1,1)
		_ReflectionDis("Reflection Distortion", Range(0,1) ) = 1
		_ReflectionTex("Reflection Texture", 2D) = "black" {}
		_Fresnel("Fresnel", Range(0,1) ) = 0
		_WaveSpeed("Wave speed (map1 x,y; map2 x,y)", Vector) = (0.2,0.2,1,0)
	}
	
	SubShader 
	{
		GrabPass {							
			Name "BASE"
			Tags { "LightMode" = "Always" }
 		}
		Tags { "Queue"="Transparent" "IgnoreProjector"="False" "RenderType"="Opaque" }
		Cull Back
		Lighting Off
		CGPROGRAM
		#pragma surface surf BlinnPhongGlass dualforward
		#pragma target 3.0
		
		inline fixed4 LightingBlinnPhongGlass ( inout SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			half3 h = normalize (lightDir + viewDir);
			fixed diff = max (0, dot (s.Normal*2, lightDir));
			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, s.Specular*128.0) * s.Gloss;
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);
			c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
			s.Alpha = s.Alpha + c.a + c.rgb;
			return c;
		}
		
		sampler2D _GrabTexture;
		fixed4 _Color;
		half _Shininess;
		sampler2D _MainTex;
		sampler2D _BumpMap;
		fixed4 _ReflectColor;
		sampler2D _ReflectionTex;
		half _ReflectionDis;
		fixed4 _RefractionColor;
		half _RefractionDis;
		half _Fresnel;
		float4 _WaveSpeed;
		
		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir;
			float4 screenPos;
		};
		
		float2 MoveTex (float2 uv,float2 pan){
			return float2(pan.x,pan.y*0.1)*_Time + uv;
		}
		
		half4 ClampColor (half4 cc) {
			return half4(clamp(cc.r,0,1),clamp(cc.g,0,1),clamp(cc.b,0,1),clamp(cc.a,0,1));
		}
		
		void surf (Input IN, inout SurfaceOutput o) {
			half3 bump0 = UnpackNormal(tex2D(_BumpMap,MoveTex(IN.uv_BumpMap,_WaveSpeed.xy)));
			half3 bump1 = UnpackNormal(tex2D(_BumpMap,MoveTex(IN.uv_BumpMap,_WaveSpeed.zw)));
			half3 bump = (bump0 + bump1) * 0.5;
			
			o.Normal = bump;
			
			float2 screenPos = IN.screenPos.xy/IN.screenPos.w;
			float2 refractionUV = screenPos + o.Normal.xy * _RefractionDis;
			refractionUV = float2(refractionUV.x,1-refractionUV.y);
			half4 refraction = tex2D(_GrabTexture,refractionUV) * _RefractionColor;
			
			half4 tex0 = tex2D(_MainTex,MoveTex(IN.uv_MainTex,_WaveSpeed.xy));
			half4 tex1 = tex2D(_MainTex,MoveTex(IN.uv_MainTex,_WaveSpeed.zw));
			half4 tex = (tex0 + tex1) * 0.5;
			half4 difColor = _Color - _ReflectColor;
			difColor = ClampColor(difColor);
			half4 diffuseCol = difColor * tex;
			
			float fresnel = pow(abs(1.0 - dot(normalize(IN.viewDir.xyz), normalize(o.Normal))),_Fresnel);
			o.Alpha =  fresnel * _Color.a ;
			
			o.Albedo = diffuseCol.rgb * o.Alpha;
			
			o.Specular = _Shininess;
			o.Gloss = 1;
			
			float2 reflectionUV = screenPos + o.Normal.xy * _ReflectionDis;
			half4 reflcol = _ReflectColor * tex2D (_ReflectionTex,reflectionUV);
			o.Emission = reflcol.rgb * o.Alpha + refraction.rgb * (1-o.Alpha);
			
		}
		ENDCG
	}
	Fallback "Diffuse"
}


