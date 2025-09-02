shader_type canvas_item;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

				// Se o pixel for muito escuro, torná-lo transparente
	if (gray < 0.2) {
		discard;
	}

	float final_alpha = tex_color.a * COLOR.a;
		COLOR = vec4(vec3(gray), final_alpha);
}