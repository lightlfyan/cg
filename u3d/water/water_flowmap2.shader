// Animated Water Shader
// Copyright (c) 2012, Stanislaw Adaszewski (http://algoholic.eu)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met: 
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer. 
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution. 
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Shader "Custom/Foamy Water" {
	Properties {
		_Color ("Water Color (RGB) Transparency (A)", COLOR) = (1, 1, 1, 0.5)
		_BumpMap ("Normal Map 1", 2D) = "white" {}
		//_BumpMap2 ("Normal Map 2", 2D) = "white" {}
		_FoamTex ("Foam Texture", 2D) = "white" {}
		_FlowMap ("Flow Map", 2D) = "white" {}
		_NoiseMap ("Noise Map", 2D) = "black" {}
		_Cube ("Reflection Cubemap", Cube) = "white" { TexGen CubeReflect }
		_Cycle ("Cycle", float) = 1.0
		_Speed ("Speed", float) = 0.05
		_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
		_Shininess ("Shininess", Range (0.01, 2)) = 0.078125
		_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 200
		
		CGPROGRAM
		#pragma surface surf BlinnPhong
		#pragma target 3.0

		float4 _Color;
		sampler2D _BumpMap;
		sampler2D _FoamTex;
		samplerCUBE _Cube;
		sampler2D _FlowMap;
		sampler2D _NoiseMap;
		float _Cycle;
		float _Speed;
		float _Shininess;
		float4 _ReflectColor;

		struct Input {
			float2 uv_BumpMap;
			float2 uv_FlowMap;
			float3 worldRefl;
			float3 worldNormal;
			float3 viewDir;
			INTERNAL_DATA
		};

		void surf (Input IN, inout SurfaceOutput o) {
			float3 flowDir = tex2D(_FlowMap, IN.uv_FlowMap) * 2 - 1;
			
			float c = length(flowDir.rg);
			flowDir *= _Speed;
			flowDir.y *= -1; // A dirty fix because I didn't want to rearrange my scene, you should be able to remove it
			float3 noise = tex2D(_NoiseMap, IN.uv_FlowMap);
			
			float phase = _Time[1] / _Cycle + noise.r * 3;
			float f = frac(phase);
			
			half3 n1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + flowDir.xy * frac(phase + 0.5f)));
			half3 n2 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap + flowDir.xy * f));
			
			float3 foam1 = tex2D(_FoamTex, 10*(IN.uv_BumpMap + flowDir.xy * frac(phase + 0.5f)));
			float3 foam2 = tex2D(_FoamTex, 10*(IN.uv_BumpMap + flowDir.xy * f));
			
			if (f > 0.5f)
				f = 2.0f * (1.0f - f);
			else
				f = 2.0f * f;
				
			float foamCoeff = 1-c*c*c;
			
			o.Normal = lerp(lerp(n1, n2, f), float3(0, 0, 1), foamCoeff);
			o.Alpha = _Color.a;
			o.Gloss = lerp(1, 0, foamCoeff);
			o.Specular = _Shininess;
			
			fixed4 reflcol = texCUBE (_Cube, WorldReflectionVector(IN, o.Normal));
    		
    		
			float3 foam = lerp(foam1, foam2, f);
			o.Albedo = lerp(_Color.rgb, foam, 1-c*c*c);
    		// o.Emission = reflcol.rgb * _ReflectColor.rgb;
		}
		ENDCG
	} 
	FallBack "Reflective/Bumped Specular"
}
