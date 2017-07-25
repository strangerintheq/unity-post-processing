// Inigo Quilez Noise 

float Hash(float3 p) {
	p  = frac(p * MOD3);
	p += dot(p.xyz, p.yzx + 19.19);
	return frac(p.x * p.y * p.z);
}

float Noise(in float3 p) {

	float3 i = floor(p);
	float3 f = frac(p); 
	f *= f * (3.0-2.0*f);

	return lerp(
		lerp(lerp(Hash(i + float3(0.,0.,0.)), Hash(i + float3(1.,0.,0.)),f.x),
			lerp(Hash(i + float3(0.,1.,0.)), Hash(i + float3(1.,1.,0.)),f.x),
			f.y),
		lerp(lerp(Hash(i + float3(0.,0.,1.)), Hash(i + float3(1.,0.,1.)),f.x),
			lerp(Hash(i + float3(0.,1.,1.)), Hash(i + float3(1.,1.,1.)),f.x),
			f.y),
		f.z);
}
