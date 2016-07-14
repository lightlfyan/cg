Shader "Custom/Perlin" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Cube ("Reflection Cubemap", Cube) = "white" { TexGen CubeReflect }
		_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
		_WaveSpeed("Wave speed (map1 x,y; map2 x,y)", Vector) = (0.2,0.2,1,0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// #pragma surface surf Standard fullforwardshadows
		#pragma surface surf BlinnPhong
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		samplerCUBE _Cube;
		float4 _ReflectColor;
		float4 _WaveSpeed;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 worldRefl;
			float3 worldNormal;
			float3 viewDir;
			INTERNAL_DATA
		};

		float2 MoveTex (float2 uv,float2 pan){
			return float2(pan.x,pan.y*0.1)*_Time + uv;
		}


		float random(float x) {
    		return frac(sin(x) * 10000);
		}

float noise(float2 p) {

    return random(p.x + p.y * 10000);
            
}

float2 sw(float2 p) { return float2(floor(p.x), floor(p.y)); }
float2 se(float2 p) { return float2(ceil(p.x), floor(p.y)); }
float2 nw(float2 p) { return float2(floor(p.x), ceil(p.y)); }
float2 ne(float2 p) { return float2(ceil(p.x), ceil(p.y)); }

float smoothNoise(float2 p) {

    float2 interp = smoothstep(0., 1., frac(p));
    float s = lerp(noise(sw(p)), noise(se(p)), interp.x);
    float n = lerp(noise(nw(p)), noise(ne(p)), interp.x);
    return lerp(s, n, interp.y);
        
}

float fractalNoise(float2 p) {

    float x = 0.;
    x += smoothNoise(p      );
    x += smoothNoise(p * 2. ) / 2.;
    x += smoothNoise(p * 4. ) / 4.;
    x += smoothNoise(p * 8. ) / 8.;
    x += smoothNoise(p * 16.) / 16.;
    x /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
    return x;
            
}

float movingNoise(float2 p) {
 
    float x = fractalNoise(p + _Time);
    float y = fractalNoise(p - _Time);
    return fractalNoise(p + float2(x, y));   
    
}

// call this for water noise function
float nestedNoise(float2 p) {
    
    float x = movingNoise(p);
    float y = movingNoise(p + 100.);
    return movingNoise(p + float2(x, y));
    
}

		void surf (Input IN, inout SurfaceOutput o) {
			half3 bump0 = UnpackNormal(tex2D(_BumpMap,MoveTex(IN.uv_BumpMap,_WaveSpeed.xy)));
			half3 bump1 = UnpackNormal(tex2D(_BumpMap,MoveTex(IN.uv_BumpMap,_WaveSpeed.zw)));
			half3 bump = (bump0 + bump1) * 0.5;
			
			o.Normal = bump;

			float n = nestedNoise(IN.uv_MainTex * 6.);
  			float4 fragColor = float4(lerp(float3(.4, .6, 1.), float3(.1, .2, 1.), n), 1.);
			// Albedo comes from a texture tinted by color
			//fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			fixed4 reflcol = texCUBE (_Cube, WorldReflectionVector(IN, o.Normal));
			o.Emission = reflcol.rgb * _ReflectColor.rgb;

			fixed4 c = fragColor;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
