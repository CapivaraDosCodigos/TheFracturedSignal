shader_type canvas_item;

uniform float horizontal_oscillation : hint_range(0.0, 1, 0.001) = 0.01;
uniform float vertical_oscillation : hint_range(0.0, 1, 0.001) = 0.01;
uniform float scanline_wave_frequency : hint_range(1.0, 100.0, 0.1) = 40.0;
uniform float scanline_wave_speed : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform bool alternate_direction = true;

uniform vec2 viewport_size;

// 🟪 Paleta externa (1px de altura, horizontal)
uniform sampler2D palette_tex;
uniform int palette_size = 8;
uniform float offset_y = 0.0;

void fragment() {
	vec2 uv = UV;
	float pixel_y = SCREEN_UV.y * viewport_size.y;
	int scanline = int(floor(pixel_y));
	float wave = sin(pixel_y / scanline_wave_frequency + TIME * scanline_wave_speed);
	float x_offset = wave * horizontal_oscillation;
	if (alternate_direction && (scanline % 2 == 1)) {
		x_offset = -x_offset;
	}
	float y_offset = wave * vertical_oscillation;

	uv.x += x_offset;
	uv.y += y_offset;

	vec4 tex_color = texture(TEXTURE, uv);
	if (tex_color.a < 0.001) {
		COLOR = tex_color;
	} else {
		float index = clamp(tex_color.r, 0.0, 1.0);
		float step = 1.0 / float(palette_size);
		float palette_x = floor(index * float(palette_size)) * step + step * 0.5;
		vec2 palette_uv = vec2(palette_x, offset_y);
		vec4 final_color = texture(palette_tex, palette_uv);

		COLOR = vec4(final_color.rgb, tex_color.a);
	}
}
