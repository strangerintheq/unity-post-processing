// Math Noise 

#define MOD3 float3(.16532,.17369,.15787)


float Hash3(float3 p) {
	p  = frac(p * MOD3);
	p += dot(p.xyz, p.yzx + 19.19);
	return frac(p.x * p.y * p.z);
}

float Hash2( float p ) {
	p = frac(float2(p) * MOD2);
    p += dot(p.yx, p.xy + 19.19);
	return frac(p.x * p.y);
}

float Noise3(float3 p) {

	float3 i = floor(p);
	float3 f = frac(p); 
	f *= f * (3.0-2.0*f);

	return lerp(
		lerp(lerp(Hash3(i + float3(0.,0.,0.)), Hash3(i + float3(1.,0.,0.)),f.x),
			lerp(Hash3(i + float3(0.,1.,0.)), Hash3(i + float3(1.,1.,0.)),f.x),
			f.y),
		lerp(lerp(Hash3(i + float3(0.,0.,1.)), Hash3(i + float3(1.,0.,1.)),f.x),
			lerp(Hash3(i + float3(0.,1.,1.)), Hash3(i + float3(1.,1.,1.)),f.x),
			f.y),
		f.z);
}

float Noise2(float2 x) {
    float2 p = floor(x);
    float2 f = frac(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0;
    float res = lerp(lerp( Hash2(n+  0.0), Hash2(n+  1.0),f.x),
                    lerp( Hash2(n+ 57.0), Hash2(n+ 58.0),f.x),f.y);
    return res;
}