Shader "Custom/GaussianBulr" 
{
    Properties 
    {
        _MainTex ("", any) = "" {} 
        _OneWidth("Width of one pixel", Float) = 0.00052083333
        _OneHeight("Height of one pixel", Float) = 0.00092592592
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    
    struct v2f {
        float4 pos : SV_POSITION;
        half2 uv : TEXCOORD0;
    };
    
    sampler2D _MainTex;
    float _OneWidth;
    float _OneHeight;
    
    
    v2f vert( appdata_img v ) 
    {
        v2f o; 
        o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
        o.uv = v.texcoord;      
        return o;
    }
    
    half4 frag(v2f i) : SV_Target 
    {
        half4 color = tex2D(_MainTex, i.uv) / 4;
        color += tex2D(_MainTex, half2(i.uv.x, i.uv.y + _OneHeight)) / 8;
        color += tex2D(_MainTex, half2(i.uv.x, i.uv.y - _OneHeight)) / 8;
        color += tex2D(_MainTex, half2(i.uv.x + _OneWidth, i.uv.y)) / 8;
        color += tex2D(_MainTex, half2(i.uv.x - _OneWidth, i.uv.y)) / 8;
        color += tex2D(_MainTex, half2(i.uv.x + _OneWidth, i.uv.y + _OneHeight)) / 16;
        color += tex2D(_MainTex, half2(i.uv.x + _OneWidth, i.uv.y - _OneHeight)) / 16;
        color += tex2D(_MainTex, half2(i.uv.x - _OneWidth, i.uv.y + _OneHeight)) / 16;
        color += tex2D(_MainTex, half2(i.uv.x - _OneWidth, i.uv.y - _OneHeight)) / 16;

        return color;
    }

    
    
    ENDCG
    SubShader 
    {
         Pass {
              ZTest Always Cull Off ZWrite Off

              CGPROGRAM
              #pragma vertex vert
              #pragma fragment frag
              ENDCG
          }
    }
    Fallback off
}