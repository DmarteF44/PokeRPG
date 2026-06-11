extends RefCounted

const DATA_PATH = "res://data/pokemon_data.json"
const MANIFEST_PATH = "res://data/pokemon_assets_manifest.json"
const STARTER_IDS = ["bulbasaur", "charmander", "squirtle"]
const DEFAULT_STARTER_ID = "charmander"
const ANIMATION_FPS = 30.0
const AnimatedTextureRect = preload("res://scripts/pokemon_animated_texture_rect.gd")

const FALLBACK_DEFINITIONS = {
	"bulbasaur": {
		"id": "bulbasaur",
		"dex_number": 1,
		"name": "Bulbasaur",
		"generation": 1,
		"types": ["Grass", "Poison"],
		"base_level": 5,
		"max_hp": 45,
		"hp": 45,
		"attack": 49,
		"defense": 49,
		"speed": 45,
		"starter": true,
		"seen": true,
		"owned": false,
		"description_en": "A small seed Pokemon that stores energy in the bulb on its back. Its body combines natural endurance with grass attacks.",
		"description_pt": "Um pequeno Pokemon de semente que guarda energia no bulbo em suas costas. Seu corpo mistura resistencia natural e ataques de planta.",
	},
	"charmander": {
		"id": "charmander",
		"dex_number": 4,
		"name": "Charmander",
		"generation": 1,
		"types": ["Fire"],
		"base_level": 5,
		"max_hp": 39,
		"hp": 39,
		"attack": 52,
		"defense": 43,
		"speed": 65,
		"starter": true,
		"seen": true,
		"owned": false,
		"description_en": "A fire lizard Pokemon with a burning tail. Its flame represents its vitality and battle spirit.",
		"description_pt": "Um Pokemon lagarto de fogo com uma chama na cauda. Sua chama representa sua vitalidade e seu espirito de batalha.",
	},
	"squirtle": {
		"id": "squirtle",
		"dex_number": 7,
		"name": "Squirtle",
		"generation": 1,
		"types": ["Water"],
		"base_level": 5,
		"max_hp": 44,
		"hp": 44,
		"attack": 48,
		"defense": 65,
		"speed": 43,
		"starter": true,
		"seen": true,
		"owned": false,
		"description_en": "A tiny turtle Pokemon protected by a sturdy shell. It uses water attacks and solid defense to win battles.",
		"description_pt": "Um pequeno Pokemon tartaruga protegido por um casco resistente. Usa ataques de agua e defesa firme para vencer combates.",
	},
}

const STARTER_MOVES = {
	"bulbasaur": [
		{"name": "Tackle", "power": 40, "type": "Normal"},
		{"name": "Vine Whip", "power": 45, "type": "Grass"},
	],
	"charmander": [
		{"name": "Scratch", "power": 40, "type": "Normal"},
		{"name": "Ember", "power": 45, "type": "Fire"},
	],
	"squirtle": [
		{"name": "Tackle", "power": 40, "type": "Normal"},
		{"name": "Water Gun", "power": 45, "type": "Water"},
	],
}


static func starter_ids() -> Array:
	return STARTER_IDS.duplicate()


static func is_starter_id(pokemon_id: String) -> bool:
	return STARTER_IDS.has(pokemon_id)


static func id_from_name(name: String) -> String:
	var safe_name := name.strip_edges().to_lower().replace(" ", "_").replace("-", "_")
	if is_starter_id(safe_name):
		return safe_name
	for pokemon_id in STARTER_IDS:
		var definition := get_definition(pokemon_id)
		if str(definition.get("name", "")).to_lower() == name.strip_edges().to_lower():
			return pokemon_id
	return DEFAULT_STARTER_ID


static func id_from_dex(dex_number: int) -> String:
	for pokemon_id in STARTER_IDS:
		if int(get_definition(pokemon_id).get("dex_number", 0)) == dex_number:
			return pokemon_id
	return DEFAULT_STARTER_ID


static func get_definition(pokemon_id: String) -> Dictionary:
	var safe_id := pokemon_id.strip_edges().to_lower().replace(" ", "_").replace("-", "_")
	var loaded := _loaded_definitions()
	if loaded.has(safe_id):
		return _with_asset_paths(loaded[safe_id].duplicate(true))
	if FALLBACK_DEFINITIONS.has(safe_id):
		return _with_asset_paths(FALLBACK_DEFINITIONS[safe_id].duplicate(true))
	return _with_asset_paths(FALLBACK_DEFINITIONS[DEFAULT_STARTER_ID].duplicate(true))


static func starter_save_data(pokemon_id: String) -> Dictionary:
	var definition := get_definition(pokemon_id)
	var max_hp := int(definition.get("max_hp", definition.get("hp", 39)))
	return {
		"id": str(definition.get("id", DEFAULT_STARTER_ID)),
		"dex_number": int(definition.get("dex_number", 4)),
		"name": str(definition.get("name", "Charmander")),
		"level": int(definition.get("base_level", definition.get("level", 5))),
		"xp": 0,
		"hp": max_hp,
		"max_hp": max_hp,
		"attack": int(definition.get("attack", 50)),
		"defense": int(definition.get("defense", 45)),
		"speed": int(definition.get("speed", 50)),
		"types": definition.get("types", ["Fire"]),
		"starter": true,
	}


static func normalize_pokemon(value: Dictionary, fallback_id: String = DEFAULT_STARTER_ID) -> Dictionary:
	var pokemon_id := str(value.get("id", fallback_id))
	if pokemon_id == "":
		pokemon_id = fallback_id
	var normalized := starter_save_data(pokemon_id)
	for key in value.keys():
		normalized[key] = value[key]

	normalized["id"] = str(normalized.get("id", pokemon_id))
	normalized["dex_number"] = int(normalized.get("dex_number", get_definition(pokemon_id).get("dex_number", 4)))
	normalized["name"] = str(normalized.get("name", get_definition(pokemon_id).get("name", "Charmander")))
	normalized["level"] = max(1, int(normalized.get("level", normalized.get("base_level", 5))))
	normalized["xp"] = max(0, int(normalized.get("xp", 0)))
	normalized["max_hp"] = max(1, int(normalized.get("max_hp", 39)))
	normalized["hp"] = clampi(int(normalized.get("hp", normalized["max_hp"])), 0, int(normalized["max_hp"]))
	normalized["attack"] = max(1, int(normalized.get("attack", 50)))
	normalized["defense"] = max(1, int(normalized.get("defense", 45)))
	normalized["speed"] = max(1, int(normalized.get("speed", 50)))
	var types_value = normalized.get("types", [])
	if typeof(types_value) != TYPE_ARRAY or types_value.is_empty():
		normalized["types"] = get_definition(pokemon_id).get("types", ["Fire"])
	normalized["starter"] = bool(normalized.get("starter", false))
	return normalized


static func moves_for(pokemon_id: String) -> Array:
	var safe_id := id_from_name(pokemon_id)
	if STARTER_MOVES.has(safe_id):
		return STARTER_MOVES[safe_id].duplicate(true)
	return STARTER_MOVES[DEFAULT_STARTER_ID].duplicate(true)


static func add_animated_sprite(parent: Node, pokemon: Dictionary, pos: Vector2, node_size: Vector2, use_back: bool = false, node_name: String = "PokemonSprite") -> TextureRect:
	var texture_rect := AnimatedTextureRect.new()
	texture_rect.name = node_name
	texture_rect.position = pos
	texture_rect.size = node_size
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture_rect)

	var frames := frame_textures(str(pokemon.get("id", DEFAULT_STARTER_ID)), use_back)
	texture_rect.set_frames(frames, _fallback_texture(pokemon), ANIMATION_FPS)
	return texture_rect


static func frame_textures(pokemon_id: String, use_back: bool = false) -> Array:
	if not has_definition(pokemon_id):
		return []
	var definition := get_definition(pokemon_id)
	var folder_key := "back_frames_path" if use_back else "front_frames_path"
	var fallback_key := "front_frames_path" if use_back else "back_frames_path"
	var folder := str(definition.get(folder_key, ""))
	var frames := _textures_from_folder(folder)
	if frames.is_empty():
		frames = _textures_from_folder(str(definition.get(fallback_key, "")))
	return frames


static func has_definition(pokemon_id: String) -> bool:
	var safe_id := pokemon_id.strip_edges().to_lower().replace(" ", "_").replace("-", "_")
	if FALLBACK_DEFINITIONS.has(safe_id):
		return true
	return _loaded_definitions().has(safe_id)


static func _textures_from_folder(folder: String) -> Array:
	var textures := []
	if folder == "":
		return textures
	for index in range(0, 160):
		var path := "%s%03d.png" % [folder, index]
		if not FileAccess.file_exists(path):
			if index == 0:
				return textures
			break
		var texture = load(path)
		if texture != null:
			textures.append(texture)
	return textures


static func _fallback_texture(pokemon: Dictionary) -> Texture2D:
	var definition := get_definition(str(pokemon.get("id", DEFAULT_STARTER_ID)))
	var candidates := [
		str(pokemon.get("icon_path", "")),
		str(definition.get("icon_path", "")),
		"res://assets/sprites/sprite_%s_96.png" % str(definition.get("id", DEFAULT_STARTER_ID)),
		"res://assets/sprites/sprite_%s_96.png" % str(pokemon.get("id", DEFAULT_STARTER_ID)),
		"res://assets/sprites/sprite_charmander_96.png",
	]
	for path in candidates:
		if path != "" and FileAccess.file_exists(path):
			return load(path)
	return null


static func _loaded_definitions() -> Dictionary:
	if not FileAccess.file_exists(DATA_PATH):
		return {}
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	var definitions := {}
	if typeof(parsed) == TYPE_ARRAY:
		for entry in parsed:
			if typeof(entry) == TYPE_DICTIONARY:
				definitions[str(entry.get("id", ""))] = entry
	return definitions


static func _asset_manifest() -> Dictionary:
	if not FileAccess.file_exists(MANIFEST_PATH):
		return {}
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


static func _with_asset_paths(definition: Dictionary) -> Dictionary:
	var manifest := _asset_manifest()
	var pokemon_id := str(definition.get("id", DEFAULT_STARTER_ID))
	if manifest.has(pokemon_id) and typeof(manifest[pokemon_id]) == TYPE_DICTIONARY:
		var assets: Dictionary = manifest[pokemon_id]
		for key in ["icon_path", "front_frames_path", "back_frames_path", "has_animation"]:
			if assets.has(key):
				definition[key] = assets[key]
	if not definition.has("icon_path"):
		definition["icon_path"] = "res://assets/pokemon/icons/%s.png" % pokemon_id
	if not definition.has("front_frames_path"):
		definition["front_frames_path"] = "res://assets/pokemon/battle/animated/gen_1/front/%s/" % pokemon_id
	if not definition.has("back_frames_path"):
		definition["back_frames_path"] = "res://assets/pokemon/battle/animated/gen_1/back/%s/" % pokemon_id
	return definition
