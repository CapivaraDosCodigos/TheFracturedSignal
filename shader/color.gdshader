shader_type canvas_item;

uniform sampler2D palette_tex;
uniform int palette_size = 8;      // número de cores na paleta
uniform float offset_y = 0.0;      // linha da paleta

// Lista de cores que devem ser transparentes
uniform int transparent_count = 0;
uniform vec3 transparent_colors[16]; // até 16 cores para remover (RGB normalizado)

void fragment() {
    // Pega a cor original
    vec4 base_color = texture(TEXTURE, UV);

    // Se já for transparente
    if (base_color.a < 0.001) {
        COLOR = vec4(0.0);
    } else {
        // Determina índice na paleta
        float index = base_color.r;
        index = clamp(index, 0.0, 1.0);

        float step = 1.0 / float(palette_size);
        int palette_index = int(floor(index * float(palette_size)));

        // Pega a cor mapeada
        float palette_x = float(palette_index) * step + step * 0.5;
        vec2 palette_uv = vec2(palette_x, offset_y);
        vec4 mapped_color = texture(palette_tex, palette_uv);

        // Verifica se é uma das cores proibidas
        bool is_transparent = false;
        for (int i = 0; i < transparent_count; i++) {
            if (distance(mapped_color.rgb, transparent_colors[i]) < 0.05) {
                is_transparent = true;
                break;
            }
        }

        if (is_transparent) {
            COLOR = vec4(0.0); // fica transparente
        } else {
            COLOR = vec4(mapped_color.rgb, base_color.a);
        }
    }
}