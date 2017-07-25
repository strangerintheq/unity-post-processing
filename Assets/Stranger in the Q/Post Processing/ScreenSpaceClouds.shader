
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
			#pragma target 5.0
			#include "UnityCG.cginc"

			#include "TextureNoise.cginc"


			uniform sampler2D _CameraDepthTexture;
			uniform sampler2D _MainTex;

			uniform float4 _MainTex_TexelSize;

			uniform float4x4 _CameraInvViewMatrix;
			uniform float4x4 _FrustumCornersES;
			uniform float4 _CameraWS;

			uniform float3 _LightDir;

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
				
				// Index passed via custom blit function in PostProcessing.cs
				half index = v.vertex.z;
				v.vertex.z = 0.1;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv.xy;
				
				#if UNITY_UV_STARTS_AT_TOP
					if (_MainTex_TexelSize.y < 0) {
						o.uv.y = 1 - o.uv.y;
					}
				#endif

				// Get the eyespace view ray (normalized)
				o.ray = _FrustumCornersES[(int)index].xyz;

				// Dividing by z "normalizes" it in the z axis
				// Therefore multiplying the ray by some number i gives the viewspace position
				// of the point on the ray with [viewspace z]=i
				o.ray /= abs(o.ray.z);

				// Transform the ray from eyespace to worldspace
				o.ray = mul(_CameraInvViewMatrix, o.ray);

				return o;
			}


			float3 SunLightDirection = normalize(float3(0.1, 0.1, 0.1));
			float3 sunColour = float3(1.0, .7, .55);
			float cloudy = -0.260;

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

			float MapClouds(float3 p, float size, float speed){
				p /= size;
			    p += _Time.y / 100. * speed;
			    if (p.x*p.x + p.z*p.z < 100.)
					return CloudsFBM(p) - cloudy - .4;
				else
					return 0.0;
			}

			float3 CreateClouds(
				float3 rayDirection, 
				float3 cameraPosition, 
				float3 sky, 
				float lower, 
				float upper,
				float speed,
				float size, 
				int stepCount) {

				// Find the start and end of the cloud layer...
				float beg = ((lower - cameraPosition.y) / rayDirection.y);
				float end = ((upper - cameraPosition.y) / rayDirection.y);
			    
				// Start position...
				float3 p = float3(cameraPosition.x + rayDirection.x * beg, 0.0, cameraPosition.z + rayDirection.z * beg);
			    
				// Trace clouds through that layer...
				float d = 0.0;
				float3 add = rayDirection * ((end - beg) / 100.0);
				float2 shade;
				float2 shadeSum = float2(0.0, 0.0);
				float difference = upper - lower;
			    
				// I think this is as small as the loop can be
				// for a reasonable cloud density illusion.
				for (int i = 0; i < stepCount; i++){
			        if (shadeSum.y >= 1.0) {
			            break;
			        }
					float h = MapClouds(p, size, speed);
					shade.y = max(-h, 0.0); 
					shade.x = p.y / difference*2.;  // Grade according to height
					shadeSum += shade * (1.0 - shadeSum.y);
					p += add;
				}
			    
				shadeSum.x /= 10.0;
				shadeSum = min(shadeSum, 1.0);
				float cloudscol = pow(shadeSum.x, .4);
				float3 clouds = lerp(float3(cloudscol,cloudscol,cloudscol), sunColour, (1.0-shadeSum.y)*.4);

			    //float sunAmount = max(dot(rayDirection, SunLightDirection), 0.0); // duplicate computation
				//clouds += min((1.0-sqrt(shadeSum.y)) * pow(sunAmount, 4.0), 1.0) * 2.0;
			    sky = lerp(sky, min(clouds, 1.0), shadeSum.y);
			    return sky;
			}

			float4 frag (v2f i) : SV_Target { 

				float3 rayDirection = normalize(i.ray.xyz);

				float3 cameraPosition = _CameraWS;

				float2 duv = i.uv;
				#if UNITY_UV_STARTS_AT_TOP
					if (_MainTex_TexelSize.y < 0){
						duv.y = 1 - duv.y;
					}
				#endif

				float depthValue = Linear01Depth (tex2D(_CameraDepthTexture, duv).r);

				float3 color = tex2D(_MainTex, i.uv);
			    if ( rayDirection.y>0. && depthValue == 1.0) {
			    	color = CreateClouds(rayDirection, cameraPosition, color, 5000, 6000, 2, 1000, 44);
			    	//color = CreateClouds(rayDirection, cameraPosition, color, 1000, 2000, 1, 1000, 44);
			    } 
				return float4(color, 1.0);
			}

			ENDCG
		}
	}
}
