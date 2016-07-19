Shader "Custom/BloomCombine" {
    Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BloomTex ("BloomTex (RGB)", 2D) = "white" {}
        _BloomFactor("Bloom Factor",Range(0,10)) =2.0
    }
    SubShader {
　　　　ZWrite Off
    　   ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
            uniform sampler2D _BloomTex;
            float _BloomFactor;
            
            v2f_img vert(appdata_img v) : POSITION {
                v2f_img o;
                o.pos=mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv=v.texcoord.xy;
                return o;
            }
            fixed4 frag(v2f_img i):COLOR
            {
                fixed4 mainColor = tex2D(_MainTex, i.uv);
                fixed4 bloomColor= tex2D(_BloomTex, i.uv);
                fixed4 finalColor =bloomColor*_BloomFactor+mainColor;
                return finalColor;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
