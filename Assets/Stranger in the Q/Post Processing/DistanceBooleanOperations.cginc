
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