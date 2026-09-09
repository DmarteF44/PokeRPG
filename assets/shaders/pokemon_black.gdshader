shader_type canvas_item;

// Darkens + desaturates the sprite and mixes in a tint, giving Black/
// Possuido its own visual identity without a second sprite set - same
// shader for every species/generation (see PokemonHelpers._variant_material).
uniform vec3 tint_color : source_color = vec3(0.55, 0.15, 0.75);
uniform float darkness : hint_range(0.0, 1.0) = 0.55;
uniform float tint_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 desaturated = mix(tex_color.rgb, vec3(gray), 0.4);
	vec3 darkened = desaturated * (1.0 - darkness);
	vec3 tinted = mix(darkened, tint_color, tint_strength);
	COLOR = vec4(tinted, tex_color.a);
}
