Shader "Custom/XRay" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags {  "Queue"="Overlay+1" "RenderType"="Transparent"}
		LOD 200

		 Pass {
            Cull off
            ZWrite Off
            ZTest Greater
           	Blend DstColor One
            Color[_Color]
          	SetTexture [_MainTex] { combine texture * primary, texture }
        }
        
        pass {
			ZWrite On
			ZTest LEqual
			SetTexture [_MainTex] { combine texture }
		}
	} 
	FallBack "Diffuse"
}
