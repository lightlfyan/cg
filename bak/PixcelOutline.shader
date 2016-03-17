Shader "Custom/PixcelOutline" {
	Properties {
    	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    	_Tex1 ("Texture1", 2D) = "white" {}
    	_Width("Texture1 width", int) = 0
    	_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    	_Step("Step", float) = 0
    	_Color("Color", Color) = (0,0,0,0)
    	
    	_OutlineWidth ("Outline Length", Range(0.0, 1.0)) = 0.3
        _OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
	}
	
	SubShader {
	
	/*
    Tags {
    "Queue"="AlphaTest" 
    "IgnoreProjector"="True" 
    "RenderType"="TransparentCutout"}
    */
    
     Tags { 
      		"Queue"="Transparent"
            "RenderType"="Opaque"
        }
    
    LOD 100

    //Cull Off


    Lighting Off

    Pass {  
        Stencil { 
              Ref 1 
              Comp Always 
              Pass REPLACE 
        }
        
         	Cull off
            AlphaTest Greater 0.5
            Blend SrcAlpha OneMinusSrcAlpha 

        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _Tex1;

            fixed _Cutoff;
            float _Step;
            fixed4 _Color;
            float _Width;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            fixed4 frag (v2f i) : COLOR
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);

                float pos = _Step / 4;

                if(i.texcoord.x == 0){
                	if(i.texcoord.y > pos){
                		col = fixed4(0,0,0,0);
                	} else {
                		return _Color;
                	}
                }
                
           
                float w = (512 - _Width) / 512;
                if(w < 1){
                	if(i.texcoord.x > w){
                		i.texcoord.x -= w;
                		i.texcoord.x /= (1-w);
                		col = tex2D(_Tex1, i.texcoord);
                	}
                } 
                /*
                else if(i.texcoord.x >= 0.5 && i.texcoord.y < 0.5){
                	i.texcoord.x -= 0.5;
                	i.texcoord.x *= 2;
                	i.texcoord.y *= 2;
                	col = tex2D(_Tex1, i.texcoord);
                }
                */

                clip(col.a - _Cutoff);
                return col;
            }
        ENDCG
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

            sampler2D _MainTex;
            sampler2D _Tex1;

            uniform float4 _MainTex_ST;

            fixed _Cutoff;
            float _Step;
            fixed4 _Color;
            float _Width;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float3 color : COLOR;
            };
            
            v2f vert(appdata v) {
                v2f o;
                float4 vert = v.vertex;
                vert.xyz += v.normal * _OutlineWidth;
                //vert.xyz *= (1 + _OutlineWidth);
                o.pos = mul(UNITY_MATRIX_MVP, vert);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            
            half4 frag(v2f i) : COLOR {
                float4 texcol = tex2D(_MainTex, i.texcoord);
                if(texcol.a > 0.5 ){
                    return _OutlineColor;
                }
                return float4(0,0,0,0);
            }   
            
            half4 frag1 (v2f i) : COLOR
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);

                float pos = _Step / 4;

                if(i.texcoord.x == 0){
                	if(i.texcoord.y > pos){
                		col = fixed4(0,0,0,0);
                	} else {
                		return _Color;
                	}
                }
                
           
                float w = (512 - _Width) / 512;
                if(w < 1){
                	if(i.texcoord.x > w){
                		i.texcoord.x -= w;
                		i.texcoord.x /= (1-w);
                		col = tex2D(_Tex1, i.texcoord);
                	}
                } 
                /*
                else if(i.texcoord.x >= 0.5 && i.texcoord.y < 0.5){
                	i.texcoord.x -= 0.5;
                	i.texcoord.x *= 2;
                	i.texcoord.y *= 2;
                	col = tex2D(_Tex1, i.texcoord);
                }
                */
                
                if(col.a > 0.5){
                	return _OutlineColor;
                }
                
                return float4(0,0,0,0);
            }
            
            
            
            ENDCG
        }
    } 
}