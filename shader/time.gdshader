shader_type canvas_item;

uniform vec4 black: source_color;
uniform vec4 dark : source_color;
uniform vec4 light: source_color;
uniform vec4 white: source_color;

void fragment() { 
	COLOR = texture (TEXTURE, UV);
	float rgb_avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	if (rgb_avg < 0.25) {
		COLOR = black;
	}
	else if (rgb_avg < 0.5) {
		COLOR = dark; 
	} 
	else if (rgb_avg < 0.75) {
		COLOR = light;
	} 
	else {
		COLOR = white;
	}
}