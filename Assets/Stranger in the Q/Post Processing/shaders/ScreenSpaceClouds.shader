
Shader "StrangerintheQ/ScreenSpaceClouds" {
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
			#pragma target 3.0

			#include "UnityCG.cginc"	
			#include "./parts/MathNoise.cginc"
			//#include "./parts/TextureNoise.cginc"
			#include "./parts/DistanceBooleanOperations.cginc"
			#include "./parts/DistanceFunctions.cginc"
			#include "./parts/PostEffect.cginc"

			uniform float4x4 _CameraInvViewMatrix;
			uniform float4x4 _FrustumCornersES;

			uniform sampler2D _CameraDepthTexture;
			uniform sampler2D _MainTex;

			uniform float4 _CameraWS;
			uniform float3 _LightDir;
			uniform float3 _TargetVolumePosition;
			uniform float3 _TargetVolumeScale;
			uniform float3 _Repeat;

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


			float CloudsFBM(float3 p) {
			    float f = 0.0;
			    float octave = 1.0;
			    while (octave > 0.1) {
			    	octave /= 2.0;
			        f += octave * Noise3(p); 
			        p = p * (3.0 + octave); 
			    }
			    return f;
			}

			float MapClouds(float3 p) {
				p.y -= _Time*10;
				return CloudsFBM(p) - .45;
			}

			float map(float3 p) {
				float effectVolume = sdBox(p - _TargetVolumePosition, abs(_TargetVolumeScale/2));
				return effectVolume;
			}

			float4 raytraceClouds(float3 cameraPosition, float3 rayDirection, float3 p, float depth, float3 color) { 
				const float3 sunColour = float3(1.0, .7, .55);
				const float3 add = rayDirection * 0.05;
				float2 shade;
				float2 shadeSum = float2(0.0, 0.0);
				int i = 0;
				for (; i < 100; i++){
					
			        if (shadeSum.y >= 1.0) break;

					float h = MapClouds(p);
					shade.y = max(-h, 0.0); 
					shade.x = p.y / 4.;  // Grade according to height
					shadeSum += shade * (1.0 - shadeSum.y);
					p += add;

					if(map(p) > 0.001) break; // exit target volume
				}
			    
				shadeSum.x /= 10.0;
				shadeSum = min(shadeSum, 1.0);
				float c = pow(shadeSum.x, .4); // clouds color

				float3 clouds = lerp(float3(c,c,c), sunColour, (1.0-shadeSum.y)*.4);

			    //float sunAmount = max(dot(rayDirection, _LightDir), 0.0); // duplicate computation
				//clouds += min((1.0-sqrt(shadeSum.y)) * pow(sunAmount, 4.0), 1.0) * 2.0;
			    color = lerp(color, min(clouds, 1.0), shadeSum.y);
			    return float4(color, length(add) * i);
			}

			float3 calcNormal(in float3 pos) {
				const float2 eps = float2(0.001, 0.0);
				float3 nor = float3(
					map(pos + eps.xyy).x - map(pos - eps.xyy).x,
					map(pos + eps.yxy).x - map(pos - eps.yxy).x,
					map(pos + eps.yyx).x - map(pos - eps.yyx).x);
				return normalize(nor);
			}

			fixed3 raymarch(float3 rayOrigin, float3 rayDirection, float depth, float3 color) {
				const int maxSteps = 128;
				const float maxDistance = 100;
				const float epsilon = 0.001;
				float t = 0; // current distance traveled along ray
				for (int i = 0; i < maxSteps; ++i) {
					if (t >= depth || t > maxDistance) break;
					float3 p = rayOrigin + rayDirection * t;
					float d = map(p);
					if (d < epsilon) {
						//return fixed4(fixed3(1,1,1)*dot(-_LightDir.xyz, calcNormal(p)), 1);
						float4 traced = raytraceClouds(rayOrigin, rayDirection, p, depth, color);
						return traced.rgb;
						//t += traced.a;
					}
					t += d;
				}
				return color;
			}

			float4 frag (v2f i) : SV_Target { 
				float3 rd = normalize(i.ray.xyz);
				float3 ro = _CameraWS;
				float2 duv = i.uv;
				fixUV(duv);
				fixed3 color = tex2D(_MainTex, i.uv);
				float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, duv).r);
				depth *= length(i.ray);
				return fixed4(raymarch(ro, rd, depth, color), 1);
			}

			ENDCG
		}
	}
}
