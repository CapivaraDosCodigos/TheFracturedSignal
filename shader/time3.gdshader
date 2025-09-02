shader_type canvas_item;

uniform vec4 darkest: source_color;
uniform vec4 dark : source_color;
uniform vec4 light: source_color;
uniform vec4 lightest: source_color;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	float alpha = tex_color.a * COLOR.a;
				
	vec3 final_color;
					
	if (gray < 0.25) {
		final_color = darkest.rgb;
	} else if (gray < 0.5) {
		final_color = dark.rgb;
	} else if (gray < 0.75) {
		final_color = light.rgb;
	} else {
		final_color = lightest.rgb;
	}
																						
	COLOR = vec4(final_color, alpha);
}
