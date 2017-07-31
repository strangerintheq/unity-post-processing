
// Union
float opU(float d1, float d2) {
	return min(d1, d2);
}

// Union (with material data)
float2 opU_mat(float2 d1, float2 d2) {
	return (d1.x<d2.x) ? d1 : d2;
}

// Subtraction
float opS(float d1, float d2) {
	return max(-d1, d2);
}

// Intersection
float opI(float d1, float d2) {
	return max(d1, d2);
}

// Union (with extra data)
// d1,d2.x: Distance field result
// d1,d2.y: Extra data (material data for example)
float opU(float2 d1, float2 d2) {
	return (d1.x < d2.x) ? d1 : d2;
}

// Intersection (with extra data)
// d1,d2.x: Distance field result
// d1,d2.y: Extra data (material data for example)
float opI(float2 d1, float2 d2) {
	return (d1.x > d2.x) ? d1 : d2;
}


// http://www.iquilezles.org/www/articles/smin/smin.htm
float smoothMinimumExponential(float d1, float d2) {
	const int k = 32;
	float res = exp(-k * d1) + exp(-k * d2);
    return -log(res) / k;
}

float smoothMinimumPolynomial (float d1, float d2, float k) {
	//const fixed k = 0.1;
	float h = clamp( 0.5+0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) - k*h*(1.0-h);
}

float smoothMinimumPower(float d1, float d2) {
	const int k = 8;
	d1 = pow( d1, k ); d2 = pow( d2, k );
    return pow( (d1*d2)/(d1+d2), 1.0/k );

}