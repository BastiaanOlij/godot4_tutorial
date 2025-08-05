shader_type spatial;
render_mode cull_disabled, unshaded, depth_test_disabled;

uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float radius : hint_range(0.0, 2.0) = 1.0;
uniform float fade = 0.05;

varying float dist;

void vertex() {
	// Called for every vertex the material is visible on.
	vec2 v = VERTEX.xy;
	dist = length(v);
	
	// dist = 2.0 means outer circle, 1.0 means inner circle
	if (dist < 1.5) {
		dist = radius;
		v *= radius;
		
		// Adjust this by eye center
		vec4 eye = PROJECTION_MATRIX * vec4(0.0, 0.0, 100.0, 1.0);
		v += eye.xy / eye.w;
	}
	
	// check for reverse Z
	float z = PROJECTION_MATRIX[2][2] < 0.0 ? 0.0 : 1.0;
	POSITION = vec4(v, z, 1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = color.rgb;
	ALPHA = clamp((dist - radius) / fade, 0.0, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
