Shader "Custom/wave" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_LiveTime("time", float) = 0.0
		_Speed("speed", float) = 0.5
		_Scale("scale", float) = 0.5
	}

	SubShader {
		Tags { "RenderType"="Opaque" }


		Pass {

		 CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            half4 _Color;
            float _LiveTime;
     		float _Speed;
     		float _Scale;
   
            struct appdata {
                half4 vertex : POSITION;
                half2 texcoord : TEXCOORD0;
                half4 color : COLOR0;
            };
   
            struct v2f {
                half4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                half4 vc : COLOR0;
            };
 
            v2f vert (appdata v)
            {
                v2f o;

                half4 vertex = v.vertex;
                //vertex.y += sin(_LiveTime*_Speed + vertex.x + vertex.y + vertex.z) *  _Scale;
                vertex.y += sin(_LiveTime*_Speed + vertex.x + vertex.y) * (_Scale * 0.5) + sin(_Time*_Speed + vertex.z + vertex.y) * (_Scale*0.5);

                o.pos = mul( UNITY_MATRIX_MVP, vertex);
                o.uv = v.texcoord;    
                o.vc = v.color * _Color;
                return o;
            }
 
            half4 frag( v2f i ) : COLOR
            {
                i.uv.x = i.uv .x + sin(i.uv.y * _LiveTime * _Speed) * 0.05;
                float4 texcol = tex2D(_MainTex, i.uv);
                return texcol;
            }
            ENDCG
    }
}
}
