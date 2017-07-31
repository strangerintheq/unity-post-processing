// Math Noise 3d
float Hash3(float3 p) {
	const float3 mod3 = float3(0.123456, 0.123457, 0.123458);
	p  = frac(p * mod3);
	p += dot(p.xyz, p.yzx + 19.19);
	return frac(p.x * p.y * p.z);
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

