Shader "Custom/OutLine1" {

    Properties {
    
        _MainTex("_MainTex", 2D) = "white" {}
        _Color ("Color", Color) = (0.8, 0.8, 0.8, 1.0)
        _OutlineWidth ("Outline Length", Range(0.0, 1.0)) = 1
        _OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
        _Cutoff("cutoff", float) = 0.5
        _Alpha("Alpha", float) = 1.0
    }
    
    SubShader {
        Tags { 
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }

        //Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 200        

        Pass {
         	Stencil { 
              Ref 1 
              Comp Always 
              Pass REPLACE 
       		}
         	Cull Back
            AlphaTest Greater 0.5

            Blend SrcAlpha OneMinusSrcAlpha 

        	CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
                float3 factor : COLOR1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
         
            float _Cutoff;
            float _Alpha;
            
			uniform float _RimWidth;
			uniform float _RimPower;
			uniform float _FinalPower;

			float4 _Color;
           

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                float dotProduct = 1.0 - saturate(dot(v.normal, viewDir));
                o.factor =  smoothstep(1.0 - _RimWidth, 1.0, pow(dotProduct,_RimPower));
                
                return o;
            }
            
            fixed4 frag (v2f i) : COLOR
            {
                fixed4 texcol = tex2D(_MainTex, i.texcoord);

                if(_Alpha < 1){
					texcol.a = _Alpha;
                } else {
                	clip(texcol.a - _Cutoff);
                }

                return texcol * 1.15 * _Color;
            }
        	ENDCG
   		}
        
        

                
        Pass {
            Stencil {
                Ref 1
                //Comp Always
                Comp NotEqual
               
            }
            
            Cull Back
            ZWrite Off
            
            AlphaTest Greater 0.5
            Blend SrcAlpha OneMinusSrcAlpha 
        
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float _OutlineWidth;
            float4 _OutlineColor;
            float _Alpha;

            uniform float4 _MainTex_ST;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 color : COLOR;
                
            };
            
            v2f vert(appdata v) {
                v2f o;
                float4 vert = v.vertex;
                vert.xyz += v.normal * _OutlineWidth;
                o.pos = mul(UNITY_MATRIX_MVP, vert);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            uniform sampler2D _MainTex;
            uniform float4 _Color;
            
            half4 frag(v2f i) : COLOR {
                float4 texcol = tex2D(_MainTex, i.uv);
                if(texcol.a > 0.5 ){
                	_OutlineColor.a = _Alpha;
                    return _OutlineColor;
                }


                return float4(0,0,0,0);
            }   
            ENDCG
        }

    } 
    
    FallBack "Diffuse"
}