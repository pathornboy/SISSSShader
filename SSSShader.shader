Shader "Custom/SSSShader" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_BumpMap("Normal (Normal)", 2D) = "bump" {}
	_Color("Main Color", Color) = (1,1,1,1)
		_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess("Shininess", Range(0.03, 1)) = 0.078125

		//_Thickness = Thickness texture (invert normals, bake AO).
		//_Power = "Sharpness" of translucent glow.
		//_Distortion = Subsurface distortion, shifts surface normal, effectively a refractive index.
		//_Scale = Multiplier for translucent glow - should be per-light, really.
		//_SubColor = Subsurface colour.
		_Thickness("Thickness (R)", 2D) = "bump" {}
		_Power("Subsurface Power", Float) = 1.0
		_Distortion("Subsurface Distortion", Float) = 0.0
		_Attenuation("Subsurface Attenuation", Float) = 1.0

			_Glossiness("Glossiness", Range(0.0,1.0)) = 0.0
			_Metallic("Metallic", Range(0.0,1.0)) = 1.0

		_Scale("Subsurface Scale", Float) = 0.5
		_SubColor("Subsurface Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200


	CGPROGRAM
#pragma surface surf SSS fullforwardshadows
#pragma target 3.0
struct Input {
	float2 uv_MainTex;
};

sampler2D _MainTex, _BumpMap, _Thickness;
float _Scale, _Power, _Distortion, _Attenuation, _Metallic, _Glossiness;
fixed4 _Color, _SubColor;
half _Shininess;
float thickness;

#include "UnityPBSLighting.cginc"
inline fixed4 LightingSSS(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
{
	// Original colour
	fixed4 pbr = LightingStandard(s, viewDir, gi);

	// --- Translucency ---
	float3 L = gi.light.dir;
	float3 V = viewDir;
	float3 N = s.Normal;

	float3 H = normalize(L + N * _Distortion);
	float VdotH = pow(saturate(dot(V, -H)), _Power) * _Scale;
	float3 I = (VdotH) * thickness;

	// Final add
	pbr.rgb = pbr.rgb + gi.light.color * I;
	return pbr;
}

void LightingSSS_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
{
	LightingStandard_GI(s, data, gi);
}

void surf(Input IN, inout SurfaceOutputStandard o) {
	// Albedo comes from a texture tinted by color
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb;
	// Metallic and smoothness come from slider variables
	o.Metallic = _Metallic;
	o.Smoothness = _Glossiness;
	o.Alpha = c.a;
	thickness = tex2D(_Thickness, IN.uv_MainTex).r;
}

ENDCG
		}
			FallBack "Bumped Diffuse"
}