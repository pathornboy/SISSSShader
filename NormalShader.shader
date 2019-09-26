Shader "Custom/NormalShader" {
	Properties {
		_MainTint("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "bump" {}
		_NormalTex("Normal Map", 2D) = "bump" {}
		_NormalMapIntensity("Normal intensity", Range(0,2)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NormalTex;
		float4 _MainTint;
		float _NormalMapIntensity;

		struct Input {
			float2 uv_MainTex;
			float2 uv_NormalTex;
		};


		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
			float3 n = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			n.x *= _NormalMapIntensity;
			n.y *= _NormalMapIntensity;
			o.Normal = normalize(n);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
