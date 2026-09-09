shader_type canvas_item;

// Tints the sprite towards its current Tera Type's canonical color (see
// PokemonHelpers.TERA_TYPE_COLORS/_tera_material) - a simplified stand-in
// for the real games' crystalline/gem material, which would need a proper
// 3D-lit shader this 2D sprite pipeline doesn't have. One shader shared
// across every species/type, parameterized per-material like the Shiny
// shader's hue_shift.
uniform vec3 tera_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 tinted = mix(tex_color.rgb, tera_color, tint_strength);
	COLOR = vec4(tinted, tex_color.a);
}
