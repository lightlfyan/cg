Shader "Custom/NewShader" {

    Properties {
    
        _MainTex("_MainTex", 2D) = "white" {}
        _Outline ("Outline Length", Range(0.0, 1.0)) = 0.3
    
        _Color ("Color", Color) = (0.8, 0.8, 0.8, 1.0)
        _OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
        _ShadowColor ("_ShadowColor", Color) = (0, 0, 0, 0)

    }
    
    SubShader {
    
        Tags { 
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
    
        LOD 200        
       
        Pass {
            Stencil { 
              Ref 1 
              Comp Always 
              Pass REPLACE 
            }
            
            AlphaTest Greater 0
            Blend SrcAlpha OneMinusSrcAlpha 
            Color[_Color]
            SetTexture[_MainTex] {
                Combine texture
            }
        }
        
        // render outline
        
        Pass {
        
            Stencil {
                Ref 1
                //Comp Always
                Comp NotEqual
               
            }
            
            Cull Off
            ZWrite Off
            
            AlphaTest Greater 0.9
            Blend SrcAlpha OneMinusSrcAlpha 
        
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float _Outline;
            float4 _OutlineColor;
            
                        
            float4 offset = float4(10,2,2,0);
            
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
                vert.xyz += v.normal * _Outline;
                //vert.xyz *= (1 + _Outline);

                o.pos = mul(UNITY_MATRIX_MVP, vert);
                
                
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            uniform sampler2D _MainTex;
            uniform float4 _Color;
            
            half4 frag(v2f i) : COLOR {
                float4 texcol = tex2D(_MainTex, i.uv);
                if(texcol.a > 0 ){
                    return _OutlineColor;
                }
                return float4(0,0,0,0);
                
                //return _OutlineColor;
            }   
            
            ENDCG
        }
        
         Pass {
        
            Stencil {
                Ref 1
                Comp NotEqual
               
            }
            
            //Cull Off
            //ZWrite Off
            
            //Blend SrcAlpha OneMinusSrcAlpha 
        
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            float4 _ShadowColor;
           
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
            };
            
            v2f vert(appdata v) {
                v2f o;
       
                float4 vert = v.vertex;
                vert.z *= v.normal * 0;
                o.pos = mul(UNITY_MATRIX_MVP, vert);    
                
                o.pos.xyz += float3(0,-1.5,0);
                
                return o;
            }
            
            uniform sampler2D _MainTex;
            uniform float4 _Color;
            
            half4 frag(v2f i) : COLOR {
                return _ShadowColor;
            }   
            
            ENDCG
        }

    } 
    
    FallBack "Diffuse"
}