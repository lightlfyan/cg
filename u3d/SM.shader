//作者：用生命舞蹈

Shader "SNDM"
{
	Properties 
	{
_maincolor("Main Color", Color) = (1,1,1,1)
_RGBA("Base(RGB)Trans(A)", 2D) = "white" {}
_specColor("Specular Color", Color) = (0,0,0,1)
_specTex_Gloss("Specular(RGB)Gloss(A)", 2D) = "black" {}
_specMultiple("Specular Multiple", Float) = 1
_shininess("Shininess", Range(0,1) ) = 0.984127
_normalmap("Normalmap", 2D) = "bump" {}

	}
	
	SubShader 
	{
		Tags
		{
"Queue"="Geometry"
"IgnoreProjector"="False"
"RenderType"="Opaque"

		}

		
Cull Back
ZWrite On
ZTest LEqual
ColorMask RGBA
Fog{
}


		CGPROGRAM
#pragma surface surf BlinnPhongEditor  vertex:vert
#pragma target 2.0


float4 _maincolor;
sampler2D _RGBA;
float4 _specColor;
sampler2D _specTex_Gloss;
float _specMultiple;
float _shininess;
sampler2D _normalmap;

			struct EditorSurfaceOutput {
				half3 Albedo;
				half3 Normal;
				half3 Emission;
				half3 Gloss;
				half Specular;
				half Alpha;
				half4 Custom;
			};
			
			inline half4 LightingBlinnPhongEditor_PrePass (EditorSurfaceOutput s, half4 light)
			{
half3 spec = light.a * s.Gloss;
half4 c;
c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
c.a = s.Alpha;
return c;

			}

			inline half4 LightingBlinnPhongEditor (EditorSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
			{
				half3 h = normalize (lightDir + viewDir);
				
				half diff = max (0, dot ( lightDir, s.Normal ));
				
				float nh = max (0, dot (s.Normal, h));
				float spec = pow (nh, s.Specular*128.0);
				
				half4 res;
				res.rgb = _LightColor0.rgb * diff;
				res.w = spec * Luminance (_LightColor0.rgb);
				res *= atten * 2.0;

				return LightingBlinnPhongEditor_PrePass( s, res );
			}
			
			struct Input {
				float2 uv_RGBA;
float2 uv_normalmap;
float2 uv_specTex_Gloss;

			};

			void vert (inout appdata_full v, out Input o) {
float4 VertexOutputMaster0_0_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_1_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_2_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_3_NoInput = float4(0,0,0,0);


			}
			

			void surf (Input IN, inout EditorSurfaceOutput o) {
				o.Normal = float3(0.0,0.0,1.0);
				o.Alpha = 1.0;
				o.Albedo = 0.0;
				o.Emission = 0.0;
				o.Gloss = 0.0;
				o.Specular = 0.0;
				o.Custom = 0.0;
				
float4 Tex2D1=tex2D(_RGBA,(IN.uv_RGBA.xyxy).xy);
float4 Multiply0=_maincolor * Tex2D1;
float4 Tex2DNormal0=float4(UnpackNormal( tex2D(_normalmap,(IN.uv_normalmap.xyxy).xy)).xyz, 1.0 );
float4 Tex2D0=tex2D(_specTex_Gloss,(IN.uv_specTex_Gloss.xyxy).xy);
float4 Add0=_shininess.xxxx + Tex2D0.aaaa;
float4 Add1=Tex2D0 + _specColor;
float4 Multiply1=Add1 * _specMultiple.xxxx;
float4 Master0_2_NoInput = float4(0,0,0,0);
float4 Master0_7_NoInput = float4(0,0,0,0);
float4 Master0_6_NoInput = float4(1,1,1,1);
o.Albedo = Multiply0;
o.Normal = Tex2DNormal0;
o.Specular = Add0;
o.Gloss = Multiply1;
o.Alpha = Tex2D1.aaaa;

				o.Normal = normalize(o.Normal);
			}
		ENDCG
	}
	Fallback "Diffuse"
}