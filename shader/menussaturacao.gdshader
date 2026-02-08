shader_type canvas_item;

uniform float saturation : hint_range(0.0, 1.0) = 0.4; // 0.4 = -60%

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	// luminância (percepção humana)
	float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));

	vec3 desaturated = mix(vec3(gray), col.rgb, saturation);

	COLOR = vec4(desaturated, col.a);
}