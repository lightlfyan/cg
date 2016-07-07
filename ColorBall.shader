
Shader "Custom/ColorBall" {
   Properties {
   	  _MainTex ("Albedo (RGB)", 2D) = "white" {}
   	  _Color("Color", Color) = (1,1,1,1)
	  _EmotionTex ("EmotionTex", 2D) = "white" {}
	  _BumpMap("BumpMap",2D)="white"{}
	  _BumpDepth ("Bump Depth", Range( -2.0, 2.0 )) = 1

	  _lerp("_lerp", Range(0, 1)) = 0
	  ka("ka", Range(0, 1)) = 0
	  kd("kd", Range(0, 2)) = 0
	  ks("ks", Range(0, 1)) = 0

	  _Alpha("_Alpha", Range(0, 1)) = 1

      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 10

      _RimColor("RimColor", Color) = (1,1,1,1)
	  _RimWidth("_RimWidth", range(0, 1)) = 0.5
	  _RimPower("_RimPower", float) = 1
   }
   SubShader {
      Pass {    
         Tags { "LightMode" = "ForwardBase" } // pass for ambient light 
            // and first directional light source without cookie
		 Blend SrcAlpha OneMinusSrcAlpha

         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _Shininess;

         sampler2D _MainTex;
		 float4 _MainTex_ST;
		 sampler2D _EmotionTex;
		 float _lerp;
		 float ka;
		 float kd;
		 float ks;
		 float _BumpDepth;
		 float _Alpha;

		 sampler2D _BumpMap;

		 uniform float4 _RimColor;
			uniform float _RimWidth;
			uniform float _RimPower;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
            float4 tangent: TANGENT;
         };

         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
            float3 normalDir : TEXCOORD1;
            float2 uv : TEXCOORD2;
            float3 normalWorld: TEXCOORD3;
			float3 tangentWorld: TEXCOORD4;
			float3 binormalWorld: TEXCOORD5;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object; 
 
            output.posWorld = mul(modelMatrix, input.vertex);
            output.normalDir = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            output.uv =  TRANSFORM_TEX(input.uv, _MainTex);

            vertexInput v = input;

            output.normalWorld = normalize( mul( float4( v.normal, 0.0 ), _World2Object ).xyz );		
			output.tangentWorld = normalize( mul( _Object2World, v.tangent ).xyz );
			output.binormalWorld = normalize( cross( output.normalWorld, output.tangentWorld ) );

            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float4 col = tex2D(_MainTex, input.uv);
            float4 col2 = tex2D(_EmotionTex, input.uv);
			col = lerp(col, col2, _lerp);

			float4 texN = tex2D(_BumpMap, input.uv);
			// unpackNormal Function
			float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
			localCoords.z = _BumpDepth;
				
			// Normal Transpose Matrix
			float3x3 local2WorldTranspose = float3x3(
				input.tangentWorld,
				input.binormalWorld,
				input.normalWorld
			);
			// Calculate Normal Direction
			float3 normalDirection = normalize( mul( localCoords, local2WorldTranspose ) );
         	//float3 normalDirection = expand(tex2D(_BumpMap, input.uv));
            //float3 normalDirection = normalize(input.normalDir);
 
            float3 viewDirection = normalize(
               _WorldSpaceCameraPos - input.posWorld.xyz);
            float3 lightDirection = 
               normalize(_WorldSpaceLightPos0.xyz);
 
            float3 ambientLighting = 
               UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
 
            float3 diffuseReflection = 
               _LightColor0.rgb * _Color.rgb
               * max(0.0, dot(normalDirection, lightDirection));
 
            float3 specularReflection;
            if (dot(normalDirection, lightDirection) < 0.0) 
               // light source on the wrong side?
            {
               specularReflection = float3(0.0, 0.0, 0.0); 
                  // no specular reflection
            }
            else // light source on the right side
            {
               specularReflection = _LightColor0.rgb 
                  * _SpecColor.rgb * pow(max(0.0, dot(
                  reflect(-lightDirection, normalDirection), 
                  viewDirection)), _Shininess);

               float3 H = normalize(lightDirection + viewDirection);
               specularReflection = pow(max(dot(normalDirection, H), 0), _Shininess);
            }


            float dotProduct = 1 - saturate(dot(normalDirection, viewDirection));
			float4 rimcolor = _RimColor * smoothstep(1 - _RimWidth, 1.0, dotProduct);

           col.rgb *=  (_Color +  ka * ambientLighting + kd * diffuseReflection +  ks * specularReflection);

           col += rimcolor;
           // col.rgb *= (col.rgb * ke + diffuseReflection + specularReflection);
           col.a = _Alpha;
           //clip(col.a - 0.5);
           return col;
         }
 
         ENDCG
      }


      Pass {    
         Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources
         Blend One One // additive blending 
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
         uniform float4x4 _LightMatrix0; // transformation 
            // from world to light space (from Autolight.cginc)
         uniform sampler2D _LightTexture0; 
            // cookie alpha texture map (from Autolight.cginc)
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _Shininess;

         sampler2D _MainTex;
         sampler2D _EmotionTex;
		 float4 _MainTex_ST;
		 float _lerp;
		 float ke;
		 float kd;
		 float ks;
		 float _BumpDepth;
		 sampler2D _BumpMap;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
            float4 tangent: TANGENT;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
               // position of the vertex (and fragment) in world space 
            float4 posLight : TEXCOORD1;
               // position of the vertex (and fragment) in light space
            float3 normalDir : TEXCOORD2;
               // surface normal vector in world space
            float2 uv : TEXCOORD3;
            float3 normalWorld: TEXCOORD4;
			float3 tangentWorld: TEXCOORD5;
			float3 binormalWorld: TEXCOORD6;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object;

            output.posWorld = mul(modelMatrix, input.vertex);
            output.posLight = mul(_LightMatrix0, output.posWorld);
            output.normalDir = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            output.uv =  TRANSFORM_TEX(input.uv, _MainTex);

            vertexInput v = input;

            output.normalWorld = normalize( mul( float4( v.normal, 0.0 ), _World2Object ).xyz );		
			output.tangentWorld = normalize( mul( _Object2World, v.tangent ).xyz );
			output.binormalWorld = normalize( cross( output.normalWorld, output.tangentWorld ) );

            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float4 col = tex2D(_MainTex, input.uv);
            float4 col2 = tex2D(_EmotionTex, input.uv);
			col = lerp(col, col2, _lerp);

			float4 texN = tex2D(_BumpMap, input.uv);
			// unpackNormal Function
			float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
			localCoords.z = _BumpDepth;
				
			// Normal Transpose Matrix
			float3x3 local2WorldTranspose = float3x3(
				input.tangentWorld,
				input.binormalWorld,
				input.normalWorld
			);
			// Calculate Normal Direction
			float3 normalDirection = normalize( mul( localCoords, local2WorldTranspose ) );


         	//float3 normalDirection = expand(tex2D(_BumpMap, input.uv));
            //float3 normalDirection = normalize(input.normalDir);
            float3 viewDirection = normalize(
               _WorldSpaceCameraPos - input.posWorld.xyz);
            float3 lightDirection;
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = 
                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 diffuseReflection = 
               attenuation * _LightColor0.rgb * _Color.rgb
               * max(0.0, dot(normalDirection, lightDirection));
 
            float3 specularReflection;
            if (dot(normalDirection, lightDirection) < 0.0) 
               // light source on the wrong side?
            {
               specularReflection = float3(0.0, 0.0, 0.0); 
                  // no specular reflection
            }
            else // light source on the right side
            {
               specularReflection = attenuation * _LightColor0.rgb 
                  * _SpecColor.rgb * pow(max(0.0, dot(
                  reflect(-lightDirection, normalDirection), 
                  viewDirection)), _Shininess);
            }
 
            float cookieAttenuation = 1.0;
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               cookieAttenuation = tex2D(_LightTexture0, 
                  input.posLight.xy).a;
            }
            else if (1.0 != _LightMatrix0[3][3]) 
               // spotlight (i.e. not a point light)?
            {
               cookieAttenuation = tex2D(_LightTexture0, 
                  input.posLight.xy / input.posLight.w 
                  + float2(0.5, 0.5)).a;
            }


            col.rgb *=  cookieAttenuation * (kd * diffuseReflection + ks * specularReflection);

            return col;
         }
 
         ENDCG
      }

   }
   Fallback "Specular"
}