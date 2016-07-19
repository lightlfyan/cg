Shader "Unlit/LaPlace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        thresholdMethod("thresholdMethod", Range(1, 4)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            int thresholdMethod = 1;
            uniform float threshold0 = 0.5;
            uniform float threshold1 = 0.0;
            uniform float threshold2 = 0.2;
            uniform float threshold3 = 0.0;
            uniform float threshold4 = 1.0;

            /*
            float gray(float4 c){
                return dot(c.xyz, float3(0.3, 0.59 0.11));
            }
            */
            float gray(float4 c){
                return dot(c.xyz, float3(0.3, 0.59, 0.11));
            }


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float off = 1.0 / _ScreenParams.x;
                sampler2D tex = _MainTex;

                float4 A = tex2D(tex, uv.xy + float2(- off, - off));
                float4 B = tex2D(tex, uv.xy + float2(0.0      , - off));
                float4 C = tex2D(tex, uv.xy + float2(+ off, - off));
                float4 D = tex2D(tex, uv.xy + float2(- off, 0.0      ));
                float4 E = tex2D(tex, uv.xy                               );
                float4 F = tex2D(tex, uv.xy + float2(+ off, 0.0      ));
                float4 G = tex2D(tex, uv.xy + float2(- off, + off));
                float4 H = tex2D(tex, uv.xy + float2(0.0      , + off));
                float4 I = tex2D(tex, uv.xy + float2(+ off, + off));

                float4 L = (- 2.0 * A + 1.0 * B - 2.0 * C 
                      + 1.0 * D + 4.0 * E + 1.0 * F 
                      - 2.0 * G + 1.0 * H - 2.0 * I);

                float4 col = E + 2 * L;
                return col;
            }
            ENDCG
        }
    }
}
