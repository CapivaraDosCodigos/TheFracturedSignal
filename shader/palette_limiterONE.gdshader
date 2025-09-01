shader_type canvas_item;

uniform sampler2D palette; // Textura com as cores da paleta
uniform int palette_width = 8;           // Número de cores (em X)
uniform int palette_height = 1;          // Número de linhas (geralmente 1)
uniform float color_match_strength : hint_range(0.0, 10.0) = 1.0;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	if (base_color.a == 0.0) {
		COLOR = base_color;
	} else {
		float best_diff = 100.0;
		vec3 final_color = base_color.rgb;

				// Percorre a paleta (assume paleta pequena)
		for (int y = 0; y < palette_height; y++) {
			for (int x = 0; x < palette_width; x++) {
				vec2 uv = vec2(
					(float(x) + 0.5) / float(palette_width),
					(float(y) + 0.5) / float(palette_height)
					);
				vec3 pal_color = texture(palette, uv).rgb;
				// Simples diferença RGB
				float diff =
					abs(base_color.r - pal_color.r) +
					abs(base_color.g - pal_color.g) +
					abs(base_color.b - pal_color.b);

				if (diff < best_diff) {
					best_diff = diff;
					final_color = pal_color;
				}
			}
		}
	COLOR = vec4(final_color, base_color.a);
	}
}
