Shader "stalendp/dotaShaderSuf" {
	Properties {
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_Mask1("Mask1", 2D) = "white" {}
		_Mask2("Mask2", 2D) = "white" {}
		_Diffuse("Diffuse", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf DotaSpecular noforwardadd noshadow  
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Normal;
		sampler2D _Mask1;
		sampler2D _Mask2;
		sampler2D _Diffuse;

		struct Input {
			float2 uv_MainTex;
			float2 uv_Normal;
			float2 uv_Mask1;
			float2 uv_Mask2;
			float2 uv_Diffuse;
		};

		struct MySurfaceOutput {
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			half Specular;
			fixed Gloss;
			fixed Alpha;
			float2 myuv;
		};

		half4 LightingDotaSpecular(MySurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
			fixed4 tex = tex2D(_MainTex, s.myuv);
			s.Albedo = tex.rgb;

			float4 mask1 = tex2D(_Mask1, s.myuv);
			float4 mask2 = tex2D(_Mask2, s.myuv);
			float specIntensity = mask2.r;
			float rimIntensity = mask2.g;
			float tint = mask2.b;
			float shininess = mask2.a * 10;
			float metalness = mask1.b;
			float selfIllu = mask1.a;
			metalness = 1 - metalness*0.7;

			float3 viewDirection = viewDir; // normalize(UnityWorldSpaceViewDir(worldPos.xyz));
			float3 lightDirection = lightDir; // normalize(_WorldSpaceLightPos0.xyz); // directional light

			float dr = max(0.05, dot(s.Normal, lightDirection));
			float3 diffuseReflection = s.Albedo * metalness * lerp(tex2D(_Diffuse, float2(dr, 0.2)), float3(1, 1, 1) * 2, selfIllu);
			float3 rim = rimIntensity * saturate(1 - saturate(dot(s.Normal, viewDirection))*1.8);
			float3 specularReflection = specIntensity * metalness * 4 * lerp(_LightColor0.rgb, _LightColor0.w * s.Albedo, tint)
				* pow(max(0.0, dot(reflect(-lightDirection, s.Normal), viewDirection)), shininess*metalness);

			return half4((diffuseReflection + rim + specularReflection) * atten, 1);
		}

		void surf (Input IN, inout MySurfaceOutput o) {
			o.myuv = IN.uv_MainTex;
			o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_MainTex));
		}
		ENDCG
	}
	FallBack "Diffuse"
}
