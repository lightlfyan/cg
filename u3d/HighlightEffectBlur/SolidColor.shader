Shader "Custom/SolidColor" 
{

Properties
	{
		_Color("color", color) = (1,1,1,1)
	}
	
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        Pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert( appdata_base v ) {
                v2f o;
                float4 vec = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_VP, vec);
                return o;
            }

            fixed4 _Color;

            fixed4 frag(v2f i) : SV_Target {
            	return _Color;
            }
            ENDCG
        }
    }
}