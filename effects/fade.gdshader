shader_type spatial;
render_mode depth_test_disabled, skip_vertex_transform, unshaded, cull_disabled;

uniform float alpha = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
	POSITION = vec4(VERTEX.x, -VERTEX.y, 1.0, 1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(0.0, 0.0, 0.0);
	ALPHA = alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
