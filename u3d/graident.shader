Shader "Custom/graident" {
	// 渐变色阶
	Properties {
		_ColorLow ("ColorLow", Color) = (1,1,1,1)
		_ColorHigh ("ColorHigh", Color) = (1,1,1,1)
		_Ymin("y min", float) = 0
		_Ymax("y max", float) = 10
		_GradientStrength("color lerp", Range(0, 1)) = 1
		_EmissiveStrength("emissive", Range(0, 1)) = 1
		_ColorRight("color right", Color) = (1,1,1,1)
		_ColorTop("color top", Color) = (1,1,1,1)
		//_MainTex ("Albedo (RGB)", 2D) = "white" {}
		//_LightDirect("LightDirect", Color) = (1,0,0,1)
		_LightDirectx("_LightDirectX", range(-1, 1)) = 1
		_LightDirectz("_LightDirectZ", range(-1, 1)) = 0
	}
	SubShader {
		Tags { "Queue" = "Geometry" "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert
		#define TOP float3(0,1,0)
        #define RIGHT float3(1,0,0)
        #define WHITE float3(1,1,1)
        #define BLACK float3(0,0,0)

		sampler2D _MainTex;

		fixed4 _ColorLow;
		fixed4 _ColorHigh;
		fixed4 _ColorRight;
		fixed4 _ColorTop;
		half _EmissiveStrength;

		half _GradientStrength;
		half _Ymin;
		half _Ymax;

		half _LightDirectx;
		half _LightDirectz;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float3 normal;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			//fixed3 texcol = tex2D(_MainTex, IN.uv_MainTex);

			fixed3 cgradient = lerp(_ColorLow, _ColorHigh, smoothstep(_Ymin, _Ymax, IN.worldPos.y)).rgb;
			cgradient = lerp(WHITE, cgradient, _GradientStrength);

			fixed3 lightdir = normalize(fixed3(_LightDirectx, 0, _LightDirectz));

			fixed3 cfacelight = _ColorRight.rgb * max(0,dot(o.Normal, lightdir))* _ColorRight.a;
			fixed3 cfacetop = _ColorTop.rgb * max(0,dot(o.Normal, TOP))* _ColorTop.a;
			fixed3 col = saturate(cfacelight + cfacetop + cgradient);

			o.Emission = lerp(BLACK, col, _EmissiveStrength);
			o.Albedo = col * saturate(1 - _EmissiveStrength);
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
