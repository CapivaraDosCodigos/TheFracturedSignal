shader_type canvas_item;

uniform sampler2D palette_tex;
uniform int palette_size = 8; // número de cores na paleta
uniform float offset_y = 0.0; // linha da paleta (pra animação ou troca de paletas)

void fragment() {
		// Pega a cor original
	vec4 base_color = texture(TEXTURE, UV);
	if (abs(base_color.a) < 0.001) {
		COLOR = base_color;
	} else {
		float index = base_color.r; // ou media de RGB se preferir precisão
		index = clamp(index, 0.0, 1.0);

		float step = 1.0 / float(palette_size);
		float palette_x = floor(index * float(palette_size)) * step + step * 0.5;
		vec2 palette_uv = vec2(palette_x, offset_y);

		vec4 mapped_color = texture(palette_tex, palette_uv);

		COLOR = vec4(mapped_color.rgb, base_color.a); // mantém alpha original
	}
}
