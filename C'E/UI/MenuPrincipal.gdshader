shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable;
uniform float zoom = 14;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV / zoom;
	uv.y += TIME * 0.003;
	vec4 noise = texture(noise_texture, uv);
	COLOR = noise;
}


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
