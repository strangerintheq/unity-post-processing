uniform float4 _MainTex_TexelSize;
void fixUV(float2 uv) {
	#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0) {
			uv.y = 1 - uv.y;
		}
	#endif
}