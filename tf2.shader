//basic phong CG shader with spec map


Shader "CG Shaders/Toon/TF2"
{
	Properties
	{
		_lightingRamp("Lighting Ramp", Color) = (1,1,1,1)
		_lightingRamp("Diffuse", 2D) = "white" {}
		_diffuseColor("Diffuse Color", Color) = (1,1,1,1)
		_diffuseMap("Diffuse", 2D) = "white" {}
		_specBasePower ("Base Spec Falloff", Range(0.0, 2.0)) = .5
		_specBasePower (" ", Float) = .5
		_exponentMap("Specular Exponent", 2D) = "bump" {}
		_specFrenselPower ("Base Spec Frensel Power", Range(0.0, 5.0)) = 4
		_specFrenselPower (" ", Float) = 4
		_specPowerRim ("Rim Light Spec Power", Range(0.0, 1)) = .1
		_specPowerRim (" ", Float) = .1
		_normalMap("Normal / Specular (A)", 2D) = "bump" {}
		//cube map
		_CubeMap ("Ambient Cube", Cube) = "" {}
		_cubeMapAmbient("Ambient Cube Intensity", Range(0.0, 1.0)) = 0.5
		_cubeMapAmbient (" ", Float) = 0.5
		
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" } 
            
			CGPROGRAM
			
			#pragma vertex vShader
			#pragma fragment pShader
			#include "UnityCG.cginc"
			#pragma multi_compile_fwdbase
			#pragma exclude_renderers flash
			#pragma target 3.0 //66 instructions...look for trims
			
			uniform fixed3 _diffuseColor;
			uniform sampler2D _diffuseMap;
			uniform half4 _diffuseMap_ST;	
			uniform sampler2D _exponentMap;
			uniform half4 _exponentMap_ST;			
			uniform fixed4 _LightColor0; 
			uniform half _specBasePower;
			uniform half _specFrenselPower;
			uniform half _specPowerRim;
			uniform sampler2D _normalMap;
			uniform half4 _normalMap_ST;	
			//cubemap
			uniform samplerCUBE _CubeMap;
			uniform fixed _cubeMapAmbient; 
			//ramp lighting
			uniform sampler2D _lightingRamp;
			
			struct app2vert {
				float4 vertex 	: 	POSITION;
				fixed2 texCoord : 	TEXCOORD0;
				fixed4 normal 	:	NORMAL;
				fixed4 tangent : TANGENT;
				
			};
			struct vert2Pixel
			{
				float4 pos 						: 	SV_POSITION;
				fixed2 uvs						:	TEXCOORD0;
				fixed3 normalDir						:	TEXCOORD1;	
				fixed3 binormalDir					:	TEXCOORD2;	
				fixed3 tangentDir					:	TEXCOORD3;	
				half3 posWorld						:	TEXCOORD4;	
				fixed3 viewDir						:	TEXCOORD5;
				fixed3 lighting						:	TEXCOORD6;
			};
			
			fixed lambert(fixed3 N, fixed3 L)
			{
				//modified to return half lambert
				//tf2 half lambert has an exponent of 1 so i ommitted it
				return 0.5*dot(N, L) + 0.5;
			}
			fixed frensel(fixed3 V, fixed3 N, half P)
			{	
				return pow(1 - saturate(dot(V,N)), P);
			}
			fixed phong(fixed3 R, fixed3 L, half P )
			{
				
				return pow(saturate(dot(R, L)), P);
			}
			vert2Pixel vShader(app2vert IN)
			{
				vert2Pixel OUT;
				float4x4 WorldViewProjection = UNITY_MATRIX_MVP;
				float4x4 WorldInverseTranspose = _World2Object; 
				float4x4 World = _Object2World;
							
				OUT.pos = mul(WorldViewProjection, IN.vertex);
				OUT.uvs = IN.texCoord;					
				OUT.normalDir = normalize(mul(IN.normal, WorldInverseTranspose).xyz);
				OUT.tangentDir = normalize(mul(IN.tangent, WorldInverseTranspose).xyz);
				OUT.binormalDir = normalize(cross(OUT.normalDir, OUT.tangentDir)); 
				OUT.posWorld = mul(World, IN.vertex).xyz;
				OUT.viewDir = normalize(_WorldSpaceCameraPos - OUT.posWorld);

				//vertex lights
				fixed3 vertexLighting = fixed3(0.0, 0.0, 0.0);
				#ifdef VERTEXLIGHT_ON
				 for (int index = 0; index < 4; index++)
					{    						
						half3 vertexToLightSource = half3(unity_4LightPosX0[index], unity_4LightPosY0[index], unity_4LightPosZ0[index]) - OUT.posWorld;
						fixed attenuation  = (1.0/ length(vertexToLightSource)) *.5;	
						fixed3 diffuse = unity_LightColor[index].xyz * lambert(OUT.normalDir, normalize(vertexToLightSource)) * attenuation;
						vertexLighting = vertexLighting + diffuse;
					}
				vertexLighting = saturate( vertexLighting );
				#endif
				OUT.lighting = vertexLighting ;
				
				return OUT;
			}
			
			fixed4 pShader(vert2Pixel IN): COLOR
			{
				half2 normalUVs = TRANSFORM_TEX(IN.uvs, _normalMap);
				fixed4 normalD = tex2D(_normalMap, normalUVs);
				normalD.xyz = (normalD.xyz * 2) - 1;
							
				//half3 normalDir = half3(2.0 * normalSample.xy - float2(1.0), 0.0);
				//deriving the z component
				//normalDir.z = sqrt(1.0 - dot(normalDir, normalDir));
               // alternatively you can approximate deriving the z component without sqrt like so:  
				//normalDir.z = 1.0 - 0.5 * dot(normalDir, normalDir);
				
				fixed3 normalDir = normalD.xyz;	
				fixed specMap = normalD.w;
				normalDir = normalize((normalDir.x * IN.tangentDir) + (normalDir.y * IN.binormalDir) + (normalDir.z * IN.normalDir));
	
				fixed3 ambientL = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//fake ambient cube
				fixed3 linearColor = texCUBEbias(_CubeMap, float4(normalDir,999)).xyz; 
				linearColor *= saturate(linearColor+.5);
				
				//either technique has a tendency to blow out the ambient a bit so to compensate, I lerp back to the default
				ambientL = lerp(ambientL , linearColor, _cubeMapAmbient);
				
				
				//Main Light calculation - includes directional lights
				half3 pixelToLightSource =_WorldSpaceLightPos0.xyz - (IN.posWorld*_WorldSpaceLightPos0.w);
				fixed attenuation  = lerp(1.0, 1.0/ length(pixelToLightSource), _WorldSpaceLightPos0.w);				
				fixed3 lightDirection = normalize(pixelToLightSource);
				fixed diffuseL = lambert(normalDir, lightDirection);	
				
				//sample the lighting ramp based on the lighting amount
				//lighting must be clamped slightly inside 0-1 to avoid wrapping
				
				fixed lightUV = clamp( diffuseL, 0.01 , .99);
				//Valve allows overbright my multiplying by 2.
				fixed3 diffuse = tex2D(_lightingRamp, fixed2(lightUV,0)).xyz * 2;
				diffuse = _LightColor0.xyz * (diffuse )* attenuation;
				diffuse += ambientL ;
				
				//specular
				//2 phong highlights - 1 modulated by rim light
				fixed3 reflectionVector = reflect(-IN.viewDir , normalDir);
				fixed specRim = frensel(normalDir, IN.viewDir, _specBasePower);
				//the base uses a texture sampled exponent
				half2 specUVs = TRANSFORM_TEX(IN.uvs, _exponentMap);
				//I pack the rim mask in the alpha of the exponent map
				fixed2 exponent = tex2D(_exponentMap, specUVs).xw;
				fixed baseSpec = phong(reflectionVector ,lightDirection, exponent.x)*attenuation;
				baseSpec *= specRim;
			
				//rim based spec
				specRim = frensel(normalDir, IN.viewDir, _specFrenselPower);
				fixed rimSpec = phong(reflect(-IN.viewDir , normalDir) ,lightDirection, _specPowerRim)*attenuation;
				//Valve attenuates this with a rim mask. I left it out because i couldn't determine where it was packed.
				rimSpec*= exponent.y * specRim;
				
				//mix the 2 spec terms - return the greater of the 2
				fixed3 specularHighlight = _LightColor0.xyz *  specMap* max(baseSpec, rimSpec);
				
								
				//resample the fake ambient cube via view vector
				fixed3 rimColor = texCUBEbias(_CubeMap, float4(-IN.viewDir,999)).xyz; 
				rimColor *= saturate(linearColor+.5);
				//reuse the rim for rim lighting
				rimColor*= exponent.y *  specRim;
				//multiply against upvector / normal dot product to mask
				rimColor *= saturate(dot(fixed3(0,1,0),normalDir));
				
				//add to the spec
				specularHighlight += rimColor;
		
				
				
				fixed4 outColor;							
				half2 diffuseUVs = TRANSFORM_TEX(IN.uvs, _diffuseMap);
				fixed4 texSample = tex2D(_diffuseMap, diffuseUVs);
				fixed3 diffuseS = (diffuse * texSample.xyz) * _diffuseColor.xyz;
				outColor = fixed4( diffuseS + specularHighlight,1.0);
				return outColor;
			}
			
			ENDCG
		}	
		//the second pass for additional lights
		Pass
		{
			Tags { "LightMode" = "ForwardAdd" } 
			Blend One One 
			
			CGPROGRAM
			#pragma vertex vShader
			#pragma fragment pShader
			#include "UnityCG.cginc"
			#pragma exclude_renderers flash
			
			uniform fixed3 _diffuseColor;
			uniform sampler2D _diffuseMap;
			uniform half4 _diffuseMap_ST;
			uniform sampler2D _exponentMap;
			uniform half4 _exponentMap_ST;	
			uniform fixed4 _LightColor0; 	 
			uniform half _specBasePower;
			uniform half _specFrenselPower;
			uniform half _specPowerRim;
			uniform sampler2D _normalMap;
			uniform half4 _normalMap_ST;	
			//ramp lighting
			uniform sampler2D _lightingRamp;
			
			
			
			struct app2vert {
				float4 vertex 	: 	POSITION;
				fixed2 texCoord : 	TEXCOORD0;
				fixed4 normal 	:	NORMAL;
				fixed4 tangent : TANGENT;
			};
			struct vert2Pixel
			{
				float4 pos 						: 	SV_POSITION;
				fixed2 uvs						:	TEXCOORD0;	
				fixed3 normalDir						:	TEXCOORD1;	
				fixed3 binormalDir					:	TEXCOORD2;	
				fixed3 tangentDir					:	TEXCOORD3;	
				half3 posWorld						:	TEXCOORD4;	
				fixed3 viewDir						:	TEXCOORD5;
				fixed4 lighting					:	TEXCOORD6;	
			};
			
			fixed lambert(fixed3 N, fixed3 L)
			{
				//modified to return half lambert
				//tf2 half lambert has an exponent of 1 so i ommitted it
				return 0.5*dot(N, L) + 0.5;
			}
			fixed frensel(fixed3 V, fixed3 N, half P)
			{	
				return pow(1 - saturate(dot(V,N)), P);
			}
			fixed phong(fixed3 R, fixed3 L, half P )
			{
				
				return pow(saturate(dot(R, L)), P);
			}
			vert2Pixel vShader(app2vert IN)
			{
				vert2Pixel OUT;
				float4x4 WorldViewProjection = UNITY_MATRIX_MVP;
				float4x4 WorldInverseTranspose = _World2Object; 
				float4x4 World = _Object2World;
				
				OUT.pos = mul(WorldViewProjection, IN.vertex);
				OUT.uvs = IN.texCoord;	
				
				OUT.normalDir = normalize(mul(IN.normal, WorldInverseTranspose).xyz);
				OUT.tangentDir = normalize(mul(IN.tangent, WorldInverseTranspose).xyz);
				OUT.binormalDir = normalize(cross(OUT.normalDir, OUT.tangentDir)); 
				OUT.posWorld = mul(World, IN.vertex).xyz;
				OUT.viewDir = normalize(_WorldSpaceCameraPos - OUT.posWorld);
				return OUT;
			}
			fixed4 pShader(vert2Pixel IN): COLOR
			{
				half2 normalUVs = TRANSFORM_TEX(IN.uvs, _normalMap);
				fixed4 normalD = tex2D(_normalMap, normalUVs);
				normalD.xyz = (normalD.xyz * 2) - 1;
				
				//half3 normalDir = half3(2.0 * normalSample.xy - float2(1.0), 0.0);
				//deriving the z component
				//normalDir.z = sqrt(1.0 - dot(normalDir, normalDir));
               // alternatively you can approximate deriving the z component without sqrt like so: 
				//normalDir.z = 1.0 - 0.5 * dot(normalDir, normalDir);
				
				fixed3 normalDir = normalD.xyz;	
				fixed specMap = normalD.w;
				normalDir = normalize((normalDir.x * IN.tangentDir) + (normalDir.y * IN.binormalDir) + (normalDir.z * IN.normalDir));
							
				half3 pixelToLightSource =_WorldSpaceLightPos0.xyz - (IN.posWorld*_WorldSpaceLightPos0.w);
				fixed attenuation  = lerp(1.0, 1.0/ length(pixelToLightSource), _WorldSpaceLightPos0.w);				
				fixed3 lightDirection = normalize(pixelToLightSource);
				
				fixed diffuseL = lambert(normalDir, lightDirection);	
				//sample the lighting ramp based on the lighting amount
				//lighting must be clamped slightly inside 0-1 to avoid wrapping
				fixed lightUV = clamp( diffuseL, 0.01 , .99);
				//Valve allows overbright my multiplying by 2.
				fixed3 diffuse = tex2D(_lightingRamp, fixed2(lightUV,0)).xyz * 2;
				diffuse = _LightColor0.xyz * (diffuse )* attenuation;
				
				//specular
				//2 phong highlights - 1 modulated by rim light
				fixed3 reflectionVector = reflect(-IN.viewDir , normalDir);
				fixed specRim = frensel(normalDir, IN.viewDir, _specBasePower);
				//the base uses a texture sampled exponent
				half2 specUVs = TRANSFORM_TEX(IN.uvs, _exponentMap);
				//I pack the rim mask in the alpha of the exponent map
				fixed2 exponent = tex2D(_exponentMap, specUVs).xw;
				fixed baseSpec = phong(reflectionVector ,lightDirection, exponent.x)*attenuation;
				baseSpec *= specRim;
			
				//rim based spec
				specRim = frensel(normalDir, IN.viewDir, _specFrenselPower);
				fixed rimSpec = phong(reflect(-IN.viewDir , normalDir) ,lightDirection, _specPowerRim)*attenuation;
				//Valve attenuates this with a rim mask. I left it out because i couldn't determine where it was packed.
				rimSpec*= exponent.y * specRim;
				
				//mix the 2 spec terms - return the greater of the 2
				fixed3 specularHighlight = _LightColor0.xyz *  specMap* max(baseSpec, rimSpec);
				
				fixed4 outColor;							
				half2 diffuseUVs = TRANSFORM_TEX(IN.uvs, _diffuseMap);
				fixed4 texSample = tex2D(_diffuseMap, diffuseUVs);
				fixed3 diffuseS = (diffuse * texSample.xyz) * _diffuseColor.xyz;
				outColor = fixed4( diffuseS + specularHighlight,1.0);
				return outColor;
			}
			
			ENDCG
		}	
		
		
	}
}
