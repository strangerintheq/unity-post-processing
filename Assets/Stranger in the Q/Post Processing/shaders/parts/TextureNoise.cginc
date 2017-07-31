uniform sampler2D _NoiseTex;

float Noise2(float2 f) {
    float2 p = floor(f);
    f = frac(f);
    f = f*f*(3.0-2.0*f);
    return tex2D(_NoiseTex, (p+f+.5)/256.0).x;
}

float Noise3(in float3 x) {
    float3 p = floor(x);
    float3 f = frac(x);
	f = f*f*(3.0-2.0*f);
	float2 uv = (p.xy+float2(37.0,17.0)*p.z) + f.xy;
	float2 rg = tex2D(_NoiseTex, (uv+ 0.5)/256.0 ).yx;
	return lerp(rg.x, rg.y, f.z);
}
