﻿
Shader "StrangerintheQ/ScreenSpaceRaymarch" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader {
		// No culling or depth
		Cull Off 
		ZWrite Off 
		ZTest Always

		Pass {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			//#pragma target 5.0

			#include "UnityCG.cginc"	
			//#include "./parts/MathNoise.cginc"
			//#include "./parts/TextureNoise.cginc"
			#include "./parts/DistanceBooleanOperations.cginc"
			#include "./parts/DistanceFunctions.cginc"

			uniform float4x4 _CameraInvViewMatrix;
			uniform float4x4 _FrustumCornersES;

			uniform sampler2D _CameraDepthTexture;
			uniform sampler2D _MainTex;

			uniform float4 _CameraWS;
			uniform float3 _LightDir;

			uniform float4x4 _Primitives[10]; 

			struct appdata {
				// Remember, the z value here contains the index of _FrustumCornersES to use
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 ray : TEXCOORD1;
			};

			uniform float4 _MainTex_TexelSize;
			void fixUV(float2 uv) {
				#if UNITY_UV_STARTS_AT_TOP
					if (_MainTex_TexelSize.y < 0) {
						uv.y = 1 - uv.y;
					}
				#endif
			}

			v2f vert (appdata v) {
				v2f o;

				half index = v.vertex.z;
				v.vertex.z = 0.1;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv = v.uv.xy;
				fixUV(o.uv);

				o.ray = _FrustumCornersES[(int)index].xyz;
				o.ray /= abs(o.ray.z);
				o.ray = mul(_CameraInvViewMatrix, o.ray);

				return o;
			}

			////////////////////////////////////////////////////////////////////////////////////

			float map(float3 p) {
				float result = 1000000;
				for (int i = 0; i < 10; i++) {
					float3x3 m = _Primitives[i];
					int type = m[0][0];
					if (type == 0) break;
					float3 position = float3(m[1][0], m[1][1], m[1][2]);
					float3 scale = abs(float3(m[2][0], m[2][1], m[2][2]) / 2);
					float d;
					if (type == 1) d = sdBox(p - position, scale);
					if (type == 2) d = sdEllipsoid(p - position, scale);
					result = smoothMinimumPolynomial(result, d, 0.1);
				}
				return result;
			}

			float3 calcNormal(in float3 pos) {
				const float2 eps = float2(0.001, 0.0);
				float3 nor = float3(
					map(pos + eps.xyy).x - map(pos - eps.xyy).x,
					map(pos + eps.yxy).x - map(pos - eps.yxy).x,
					map(pos + eps.yyx).x - map(pos - eps.yyx).x);
				return normalize(nor);
			}

			float4 raymarch(float3 rayOrigin, float3 rayDirection, float depth) {
				float4 result = float4(0, 0, 0, 0);
				const int maxSteps = 128;
				const float maxDistance = 30;
				const float epsilon = 0.001;
				float t = 0; // current distance traveled along ray
				for (int i = 0; i < maxSteps; ++i) {
					if (t >= depth || t > maxDistance) break;
					float3 p = rayOrigin + rayDirection * t;
					float d = map(p);
					if (d < epsilon) {
						result.xyz = p.xyz;
						result.w = 1;
						break;
						//return fixed4(fixed3(1,1,1)*dot(-_LightDir.xyz, calcNormal(p)), 1);
					}
					t += d;
				}
				return result;
			}

			float4 frag (v2f i) : SV_Target { 


				float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
				depth *= length(i.ray);

				fixed3 c = tex2D(_MainTex, i.uv);

				// scene
				float3 ro = _CameraWS;
				float3 rd = normalize(i.ray.xyz);
				float4 scene = raymarch(ro, rd, depth);
				if (scene.w != 0) {
					c = fixed3(1, 1, 1) * dot(-_LightDir.xyz, calcNormal(scene));
				}

				// shadow
				ro += depth;
				//rd =_LightDir;
				float4 shadow = raymarch(ro, rd, 1000000);
				if (shadow.w != 0) {
					c = fixed3(0.5, 0.5, 0.5);
				}

				return fixed4(c, 1);
			}

			ENDCG
		}
	}
}
