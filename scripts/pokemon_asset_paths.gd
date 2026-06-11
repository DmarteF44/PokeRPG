extends RefCounted

const DEFAULT_ICON_PLACEHOLDER = "res://assets/sprites/sprite_charmander_96.png"
const DEFAULT_FRONT_PLACEHOLDER = "res://assets/sprites/sprite_charmander_96.png"
const DEFAULT_BACK_PLACEHOLDER = "res://assets/sprites/sprite_charmander_96.png"


static func get_pokemon_icon_path(generation: int, dex_number: int, pokemon_name: String) -> String:
	var safe_name := _safe_name(pokemon_name)
	var gen_folder := "res://assets/pokemon/icons/gen_%d" % clampi(generation, 1, 8)
	var candidates := [
		"%s/%03d_%s.png" % [gen_folder, dex_number, safe_name],
		"%s/%s.png" % [gen_folder, safe_name],
		"res://assets/sprites/sprite_%s_96.png" % safe_name,
	]
	return _first_existing_file(candidates, DEFAULT_ICON_PLACEHOLDER)


static func get_pokemon_front_animation_folder(generation: int, pokemon_name: String) -> String:
	var safe_name := _safe_name(pokemon_name)
	var folder := "res://assets/pokemon/battle/animated/gen_%d/front/%s" % [clampi(generation, 1, 8), safe_name]
	return folder if DirAccess.open(folder) != null else DEFAULT_FRONT_PLACEHOLDER


static func get_pokemon_back_animation_folder(generation: int, pokemon_name: String) -> String:
	var safe_name := _safe_name(pokemon_name)
	var folder := "res://assets/pokemon/battle/animated/gen_%d/back/%s" % [clampi(generation, 1, 8), safe_name]
	return folder if DirAccess.open(folder) != null else DEFAULT_BACK_PLACEHOLDER


static func _first_existing_file(paths: Array, fallback: String) -> String:
	for path in paths:
		if FileAccess.file_exists(str(path)):
			return str(path)
	return fallback


static func _safe_name(pokemon_name: String) -> String:
	return pokemon_name.strip_edges().to_lower().replace(" ", "_").replace("-", "_")
