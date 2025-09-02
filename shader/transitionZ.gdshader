shader_type canvas_item;

uniform float screen_width = 1920.0;
uniform float screen_height = 1080.0;
uniform vec2 center = vec2(0.5);
uniform vec2 player = vec2(0.5);

uniform float progress : hint_range(0, 1) = 0.0;
uniform float pixel_size = 15.0;
uniform float circle_size : hint_range(0, 2) = 1.5;
uniform float curtains : hint_range(0, 1) = 1.0;

uniform int type : hint_range(0, 4) = 0;

void fragment() {
	vec2 uv = UV;
	vec4 tex_color = texture(TEXTURE, uv);
	float ratio = screen_width / screen_height;

	bool show = true;

	if (type == 0) {
		vec2 frag_pixel = uv * vec2(screen_width, screen_height);
		float xFraction = fract(frag_pixel.x / pixel_size);
		float yFraction = fract(frag_pixel.y / pixel_size);
		float xDistance = abs(xFraction - 0.5);
		float yDistance = abs(yFraction - 0.5);
		show = (xDistance + yDistance <= progress);
	}
	else if (type == 1) {
		vec2 corrected_uv = vec2(uv.x * ratio, uv.y);
		vec2 corrected_player = vec2(player.x * ratio, player.y);
		show = (distance(corrected_player, corrected_uv) <= circle_size * progress);
	}
	else if (type == 2) {
		vec2 corrected_uv = vec2(uv.x * ratio, uv.y);
		vec2 corrected_center = vec2(center.x * ratio, center.y);
		show = (distance(corrected_center, corrected_uv) <= circle_size * progress);
	}
	else if (type == 3) {
		show = (abs(uv.x - 0.5) <= curtains * progress);
	}
	else if (type == 4) {
		show = (abs(uv.y - 0.5) <= curtains * progress);
	}

	if (!show) {
		discard;
	}

	COLOR = tex_color * COLOR;
}
