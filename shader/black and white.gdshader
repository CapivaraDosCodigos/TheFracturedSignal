// Shader com controle de transparência
shader_type canvas_item;

uniform float horizontal_oscillation : hint_range(0.0, 1, 0.001) = 0.01;
uniform float vertical_oscillation : hint_range(0.0, 1, 0.001) = 0.01;
uniform float scanline_wave_frequency : hint_range(1.0, 100.0, 0.1) = 40.0;
uniform float scanline_wave_speed : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform bool alternate_direction = true;

uniform float transparency : hint_range(0.0, 1.0, 0.01) = 1.0; // 🔹 Controle de transparência
uniform vec2 viewport_size;

void fragment() {
	vec2 uv = UV;

	// posição no eixo Y em pixels da tela
	float pixel_y = SCREEN_UV.y * viewport_size.y;
	int scanline = int(floor(pixel_y));

	// onda senoidal
	float wave = sin(pixel_y / scanline_wave_frequency + TIME * scanline_wave_speed);

	// deslocamentos
	float x_offset = wave * horizontal_oscillation;
	if (alternate_direction && (scanline % 2 == 1)) {
		x_offset = -x_offset;
	}
	float y_offset = wave * vertical_oscillation;

	uv.x += x_offset;
	uv.y += y_offset;

	// cor original
	vec4 tex_color = texture(TEXTURE, uv);

	// mantém transparência original
	if (tex_color.a == 0.0) {
		COLOR = tex_color;
	} else {
	// converte para escala de cinza
		float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
		vec3 gray_color = vec3(gray);

		// aplica transparência controlável
		COLOR = vec4(gray_color, tex_color.a * transparency);
	}
}