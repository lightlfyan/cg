Shader "Custom/OutLine" {

    Properties {
    
        _MainTex("_MainTex", 2D) = "white" {}
        _Color ("Color", Color) = (0.8, 0.8, 0.8, 1.0)
        _OutlineWidth ("Outline Length", Range(0.0, 1.0)) = 0.3
        _OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
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
            
            Cull off
                        
            AlphaTest Greater 0.5
            Blend SrcAlpha OneMinusSrcAlpha 
            
            Color[_Color]
            SetTexture[_MainTex] {
                Combine texture
            }
        }
        
                
        Pass {
        
            Stencil {
                Ref 1
                //Comp Always
                Comp NotEqual
               
            }
            
            Cull Off
            ZWrite Off
            
            AlphaTest Greater 0.5
            Blend SrcAlpha OneMinusSrcAlpha 
        
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float _OutlineWidth;
            float4 _OutlineColor;

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
                //vert.xyz *= (1 + _OutlineWidth);
                o.pos = mul(UNITY_MATRIX_MVP, vert);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            uniform sampler2D _MainTex;
            uniform float4 _Color;
            
            half4 frag(v2f i) : COLOR {
                float4 texcol = tex2D(_MainTex, i.uv);
                if(texcol.a > 0.5 ){
                    return _OutlineColor;
                }
                return float4(0,0,0,0);
            }   
            ENDCG
        }
    } 
    
    FallBack "Diffuse"
}