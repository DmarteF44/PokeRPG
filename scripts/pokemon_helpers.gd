extends RefCounted

const SPECIES_PATH = "res://data/pokemon_species.json"
const MOVES_PATH = "res://data/moves.json"
const MANIFEST_PATH = "res://data/pokemon_assets_manifest.json"
const SPECIES_IDS = ["bulbasaur", "ivysaur", "venusaur", "charmander", "charmeleon", "charizard", "squirtle", "wartortle", "blastoise"]
const STARTER_IDS = ["bulbasaur", "charmander", "squirtle"]
const DEFAULT_STARTER_ID = "charmander"
const ANIMATION_FPS = 30.0
const DEFAULT_XP_TO_NEXT_LEVEL = 100
const DEFAULT_FRIENDSHIP = 70
const MAX_MOVE_SLOTS = 4
const MAX_LEVEL = 100
const STAT_BOOST_AMOUNT = 5
const STAT_KEYS = ["max_hp", "attack", "defense", "sp_attack", "sp_defense", "speed"]
const STAT_LIMITS = {
	"max_hp": 999,
	"attack": 255,
	"defense": 255,
	"sp_attack": 255,
	"sp_defense": 255,
	"speed": 255,
}
const AnimatedTextureRect = preload("res://scripts/pokemon_animated_texture_rect.gd")

const FALLBACK_MOVES = {
	"Tackle": {"name": "Tackle", "type": "Normal", "category": "Physical", "power": 40, "accuracy": 100, "pp": 35},
	"Growl": {"name": "Growl", "type": "Normal", "category": "Status", "power": 0, "accuracy": 100, "pp": 40},
	"Vine Whip": {"name": "Vine Whip", "type": "Grass", "category": "Physical", "power": 45, "accuracy": 100, "pp": 25},
	"Leech Seed": {"name": "Leech Seed", "type": "Grass", "category": "Status", "power": 0, "accuracy": 90, "pp": 10},
	"Scratch": {"name": "Scratch", "type": "Normal", "category": "Physical", "power": 40, "accuracy": 100, "pp": 35},
	"Ember": {"name": "Ember", "type": "Fire", "category": "Special", "power": 40, "accuracy": 100, "pp": 25},
	"Smokescreen": {"name": "Smokescreen", "type": "Normal", "category": "Status", "power": 0, "accuracy": 100, "pp": 20},
	"Tail Whip": {"name": "Tail Whip", "type": "Normal", "category": "Status", "power": 0, "accuracy": 100, "pp": 30},
	"Water Gun": {"name": "Water Gun", "type": "Water", "category": "Special", "power": 40, "accuracy": 100, "pp": 25},
	"Bubble": {"name": "Bubble", "type": "Water", "category": "Special", "power": 40, "accuracy": 100, "pp": 30},
}

const FALLBACK_DEFINITIONS = {
	"bulbasaur": {
		"id": "bulbasaur",
		"dex_number": 1,
		"species": "Bulbasaur",
		"name": "Bulbasaur",
		"generation": 1,
		"types": ["Grass", "Poison"],
		"ability": "Overgrow",
		"base_level": 5,
		"base_stats": {"hp": 45, "attack": 49, "defense": 49, "sp_attack": 65, "sp_defense": 65, "speed": 45},
		"friendship": 70,
		"learnset": {"1": ["Tackle", "Growl"], "7": ["Vine Whip"], "10": ["Leech Seed"]},
		"starter": true,
		"seen": true,
		"owned": false,
		"description_en": "A small seed Pokemon that stores energy in the bulb on its back. Its body combines natural endurance with grass attacks.",
		"description_pt": "Um pequeno Pokemon de semente que guarda energia no bulbo em suas costas. Seu corpo mistura resistencia natural e ataques de planta.",
	},
	"charmander": {
		"id": "charmander",
		"dex_number": 4,
		"species": "Charmander",
		"name": "Charmander",
		"generation": 1,
		"types": ["Fire"],
		"ability": "Blaze",
		"base_level": 5,
		"base_stats": {"hp": 39, "attack": 52, "defense": 43, "sp_attack": 60, "sp_defense": 50, "speed": 65},
		"friendship": 70,
		"learnset": {"1": ["Scratch", "Growl"], "7": ["Ember"], "10": ["Smokescreen"]},
		"starter": true,
		"seen": true,
		"owned": false,
		"description_en": "A fire lizard Pokemon with a burning tail. Its flame represents its vitality and battle spirit.",
		"description_pt": "Um Pokemon lagarto de fogo com uma chama na cauda. Sua chama representa sua vitalidade e seu espirito de batalha.",
	},
	"squirtle": {
		"id": "squirtle",
		"dex_number": 7,
		"species": "Squirtle",
		"name": "Squirtle",
		"generation": 1,
		"types": ["Water"],
		"ability": "Torrent",
		"base_level": 5,
		"base_stats": {"hp": 44, "attack": 48, "defense": 65, "sp_attack": 50, "sp_defense": 64, "speed": 43},
		"friendship": 70,
		"learnset": {"1": ["Tackle", "Tail Whip"], "7": ["Bubble"], "10": ["Water Gun"]},
		"starter": true,
		"seen": true,
		"owned": false,
		"description_en": "A tiny turtle Pokemon protected by a sturdy shell. It uses water attacks and solid defense to win battles.",
		"description_pt": "Um pequeno Pokemon tartaruga protegido por um casco resistente. Usa ataques de agua e defesa firme para vencer combates.",
	},
}


static func starter_ids() -> Array:
	return STARTER_IDS.duplicate()


static func species_ids() -> Array:
	return SPECIES_IDS.duplicate()


static func is_starter_id(pokemon_id: String) -> bool:
	return STARTER_IDS.has(_safe_id(pokemon_id))


static func is_species_id(pokemon_id: String) -> bool:
	return SPECIES_IDS.has(_safe_id(pokemon_id)) or _loaded_definitions().has(_safe_id(pokemon_id))


static func id_from_name(name: String) -> String:
	var safe_name := _safe_id(name)
	if is_species_id(safe_name):
		return safe_name
	for pokemon_id in species_ids():
		var definition := get_definition(pokemon_id)
		var species_name := str(definition.get("species", definition.get("name", ""))).to_lower()
		var display_name := str(definition.get("name", "")).to_lower()
		if species_name == name.strip_edges().to_lower() or display_name == name.strip_edges().to_lower():
			return pokemon_id
	return DEFAULT_STARTER_ID


static func id_from_dex(dex_number: int) -> String:
	for pokemon_id in species_ids():
		if int(get_definition(pokemon_id).get("dex_number", 0)) == dex_number:
			return pokemon_id
	return DEFAULT_STARTER_ID


static func get_definition(pokemon_id: String) -> Dictionary:
	var safe_id := _safe_id(pokemon_id)
	var definitions := _loaded_definitions()
	var definition: Dictionary = {}
	if definitions.has(safe_id):
		definition = definitions[safe_id].duplicate(true)
	elif FALLBACK_DEFINITIONS.has(safe_id):
		definition = FALLBACK_DEFINITIONS[safe_id].duplicate(true)
	else:
		definition = FALLBACK_DEFINITIONS[DEFAULT_STARTER_ID].duplicate(true)
	return _with_asset_paths(_complete_species_definition(definition))


static func starter_save_data(pokemon_id: String) -> Dictionary:
	var definition := get_definition(pokemon_id)
	var safe_id := str(definition.get("id", DEFAULT_STARTER_ID))
	var species := str(definition.get("species", definition.get("name", "Charmander")))
	var level: int = maxi(1, int(definition.get("base_level", definition.get("level", 5))))
	var base_stats: Dictionary = definition.get("base_stats", {})
	var moves := moves_for(safe_id, level)
	var pp_max := _pp_max_for_moves(moves)
	var stats := stats_for_level(safe_id, level)
	return {
		"id": safe_id,
		"dex_number": int(definition.get("dex_number", 4)),
		"species": species,
		"nickname": "",
		"name": species,
		"generation": int(definition.get("generation", 1)),
		"level": level,
		"xp": 0,
		"xp_to_next_level": xp_to_next_level_for(level),
		"nature": "Hardy",
		"ability": str(definition.get("ability", "Blaze")),
		"gender": "Unknown",
		"shiny": false,
		"types": _normalized_types(definition.get("types", ["Fire"])),
		"hp": int(stats.get("max_hp", base_stats.get("hp", 39))),
		"max_hp": int(stats.get("max_hp", base_stats.get("hp", 39))),
		"attack": int(stats.get("attack", base_stats.get("attack", 50))),
		"defense": int(stats.get("defense", base_stats.get("defense", 45))),
		"sp_attack": int(stats.get("sp_attack", base_stats.get("sp_attack", 50))),
		"sp_defense": int(stats.get("sp_defense", base_stats.get("sp_defense", 50))),
		"speed": int(stats.get("speed", base_stats.get("speed", 50))),
		"status_condition": null,
		"held_item": null,
		"moves": moves,
		"pp_current": pp_max.duplicate(true),
		"pp_max": pp_max,
		"friendship": int(definition.get("friendship", DEFAULT_FRIENDSHIP)),
		"capture_date": "",
		"stat_boosts": _empty_stat_boosts(),
		"starter": true,
	}


static func normalize_pokemon(value: Dictionary, fallback_id: String = DEFAULT_STARTER_ID) -> Dictionary:
	var pokemon_id := _species_id_from_value(value, fallback_id)
	var definition := get_definition(pokemon_id)
	var base_stats: Dictionary = definition.get("base_stats", {})
	var normalized := starter_save_data(pokemon_id)
	for key in value.keys():
		normalized[key] = value[key]

	var species := str(definition.get("species", definition.get("name", "Charmander")))
	var nickname := str(normalized.get("nickname", ""))
	var existing_name := str(normalized.get("name", ""))
	if nickname == "" and existing_name != "" and existing_name != species:
		nickname = existing_name

	normalized["id"] = pokemon_id
	normalized["dex_number"] = int(definition.get("dex_number", normalized.get("dex_number", 4)))
	normalized["species"] = species
	normalized["nickname"] = nickname
	normalized["name"] = nickname if nickname != "" else species
	normalized["generation"] = int(definition.get("generation", normalized.get("generation", 1)))
	normalized["level"] = clampi(int(normalized.get("level", definition.get("base_level", 5))), 1, MAX_LEVEL)
	normalized["xp"] = maxi(0, int(normalized.get("xp", 0)))
	if int(normalized["level"]) >= MAX_LEVEL:
		normalized["xp"] = 0
	normalized["xp_to_next_level"] = xp_to_next_level_for(int(normalized["level"]))
	normalized["nature"] = str(normalized.get("nature", "Hardy"))
	normalized["ability"] = str(definition.get("ability", normalized.get("ability", "Unknown")))
	normalized["gender"] = str(normalized.get("gender", "Unknown"))
	normalized["shiny"] = bool(normalized.get("shiny", false))
	normalized["types"] = _normalized_types(definition.get("types", normalized.get("types", ["Fire"])))
	normalized["max_hp"] = maxi(1, int(normalized.get("max_hp", base_stats.get("hp", 39))))
	normalized["hp"] = clampi(int(normalized.get("hp", normalized["max_hp"])), 0, int(normalized["max_hp"]))
	normalized["attack"] = maxi(1, int(normalized.get("attack", base_stats.get("attack", 50))))
	normalized["defense"] = maxi(1, int(normalized.get("defense", base_stats.get("defense", 45))))
	normalized["sp_attack"] = maxi(1, int(normalized.get("sp_attack", base_stats.get("sp_attack", 50))))
	normalized["sp_defense"] = maxi(1, int(normalized.get("sp_defense", base_stats.get("sp_defense", 50))))
	normalized["speed"] = maxi(1, int(normalized.get("speed", base_stats.get("speed", 50))))
	normalized["stat_boosts"] = _normalized_stat_boosts(normalized.get("stat_boosts", {}))
	var status_value = normalized.get("status_condition", null)
	normalized["status_condition"] = null if status_value == null or str(status_value) == "" else str(status_value)
	var held_item_value = normalized.get("held_item", null)
	normalized["held_item"] = null if held_item_value == null or str(held_item_value) == "" else str(held_item_value)
	var moves := _normalized_moves(normalized.get("moves", []), pokemon_id, int(normalized["level"]))
	var pp_max := _pp_max_for_moves(moves)
	normalized["moves"] = moves
	normalized["pp_max"] = pp_max
	normalized["pp_current"] = _normalized_pp_current(normalized.get("pp_current", []), pp_max)
	normalized["friendship"] = clampi(int(normalized.get("friendship", definition.get("friendship", DEFAULT_FRIENDSHIP))), 0, 255)
	var capture_date_value = normalized.get("capture_date", "")
	normalized["capture_date"] = "" if capture_date_value == null else str(capture_date_value)
	normalized["starter"] = bool(normalized.get("starter", false))
	return normalized


static func moves_for(pokemon_id: String, level: int = -1) -> Array:
	var definition := get_definition(pokemon_id)
	var target_level: int = int(definition.get("base_level", 5)) if level < 0 else maxi(1, level)
	return _moves_for_learnset(definition, target_level)


static func xp_to_next_level_for(level: int) -> int:
	var safe_level := clampi(level, 1, MAX_LEVEL)
	return 0 if safe_level >= MAX_LEVEL else safe_level * 100


static func stats_for_level(pokemon_id: String, level: int) -> Dictionary:
	var definition := get_definition(pokemon_id)
	var base_stats: Dictionary = definition.get("base_stats", {})
	var safe_level := clampi(level, 1, MAX_LEVEL)
	var bonus_level := maxi(0, safe_level - 5)
	return {
		"max_hp": maxi(1, int(base_stats.get("hp", 39)) + bonus_level * 3),
		"attack": maxi(1, int(base_stats.get("attack", 50)) + int(floor(float(bonus_level) * float(base_stats.get("attack", 50)) / 50.0))),
		"defense": maxi(1, int(base_stats.get("defense", 45)) + int(floor(float(bonus_level) * float(base_stats.get("defense", 45)) / 50.0))),
		"sp_attack": maxi(1, int(base_stats.get("sp_attack", 50)) + int(floor(float(bonus_level) * float(base_stats.get("sp_attack", 50)) / 50.0))),
		"sp_defense": maxi(1, int(base_stats.get("sp_defense", 50)) + int(floor(float(bonus_level) * float(base_stats.get("sp_defense", 50)) / 50.0))),
		"speed": maxi(1, int(base_stats.get("speed", 50)) + int(floor(float(bonus_level) * float(base_stats.get("speed", 50)) / 50.0))),
	}


static func stat_keys() -> Array:
	return STAT_KEYS.duplicate()


static func stat_limit(stat_key: String) -> int:
	var safe_key := normalized_stat_key(stat_key)
	return int(STAT_LIMITS.get(safe_key, 255))


static func normalized_stat_key(stat_key: String) -> String:
	var safe_key := _safe_id(stat_key)
	if safe_key == "hp":
		return "max_hp"
	return safe_key if STAT_KEYS.has(safe_key) else ""


static func boost_stat(pokemon: Dictionary, stat_key: String, amount: int = STAT_BOOST_AMOUNT) -> Dictionary:
	var safe_key := normalized_stat_key(stat_key)
	var updated := normalize_pokemon(pokemon)
	var result := {
		"pokemon": updated,
		"stat_key": safe_key,
		"applied": 0,
		"limit": stat_limit(safe_key),
		"capped": true,
	}
	if safe_key == "" or amount <= 0:
		return result

	var limit := stat_limit(safe_key)
	var current_value := int(updated.get(safe_key, 1))
	if current_value >= limit:
		result["limit"] = limit
		return result

	var applied := mini(amount, limit - current_value)
	updated[safe_key] = current_value + applied
	if safe_key == "max_hp":
		updated["hp"] = clampi(int(updated.get("hp", 0)) + applied, 0, int(updated["max_hp"]))

	var boosts: Dictionary = _normalized_stat_boosts(updated.get("stat_boosts", {}))
	boosts[safe_key] = maxi(0, int(boosts.get(safe_key, 0)) + applied)
	updated["stat_boosts"] = boosts

	result["pokemon"] = normalize_pokemon(updated)
	result["applied"] = applied
	result["limit"] = limit
	result["capped"] = int(result["pokemon"].get(safe_key, 0)) >= limit
	return result


static func grant_xp(pokemon: Dictionary, amount: int) -> Dictionary:
	var updated := normalize_pokemon(pokemon)
	var result := {
		"pokemon": updated,
		"xp_gained": 0,
		"level_ups": [],
		"evolutions": [],
	}
	if amount <= 0 or int(updated.get("level", 1)) >= MAX_LEVEL:
		updated["xp"] = 0 if int(updated.get("level", 1)) >= MAX_LEVEL else int(updated.get("xp", 0))
		updated["xp_to_next_level"] = xp_to_next_level_for(int(updated.get("level", 1)))
		result["pokemon"] = updated
		return result

	result["xp_gained"] = amount
	updated["xp"] = int(updated.get("xp", 0)) + amount
	while int(updated.get("level", 1)) < MAX_LEVEL:
		var required := xp_to_next_level_for(int(updated.get("level", 1)))
		if required <= 0 or int(updated.get("xp", 0)) < required:
			break
		updated["xp"] = int(updated.get("xp", 0)) - required
		updated["level"] = int(updated.get("level", 1)) + 1
		_recalculate_stats(updated)
		updated = normalize_pokemon(updated)
		var level_ups: Array = result["level_ups"]
		level_ups.append(int(updated["level"]))
		result["level_ups"] = level_ups

		var evolution_target := _evolution_target_for_level(updated)
		while evolution_target != "":
			var before := updated.duplicate(true)
			updated = evolve_pokemon(updated, evolution_target)
			var evolutions: Array = result["evolutions"]
			evolutions.append({"from": before, "to": updated.duplicate(true)})
			result["evolutions"] = evolutions
			evolution_target = _evolution_target_for_level(updated)

	if int(updated.get("level", 1)) >= MAX_LEVEL:
		updated["level"] = MAX_LEVEL
		updated["xp"] = 0
	updated["xp_to_next_level"] = xp_to_next_level_for(int(updated.get("level", 1)))
	result["pokemon"] = normalize_pokemon(updated)
	return result


static func evolve_pokemon(pokemon: Dictionary, target_id: String) -> Dictionary:
	var evolved := normalize_pokemon(pokemon)
	var old_max_hp := int(evolved.get("max_hp", 1))
	var target_definition := get_definition(target_id)
	var target_species := str(target_definition.get("species", target_definition.get("name", target_id)))
	evolved["id"] = str(target_definition.get("id", target_id))
	evolved["dex_number"] = int(target_definition.get("dex_number", evolved.get("dex_number", 0)))
	evolved["species"] = target_species
	evolved["name"] = str(evolved.get("nickname", "")) if str(evolved.get("nickname", "")) != "" else target_species
	evolved["generation"] = int(target_definition.get("generation", evolved.get("generation", 1)))
	evolved["ability"] = str(target_definition.get("ability", evolved.get("ability", "Unknown")))
	evolved["types"] = _normalized_types(target_definition.get("types", evolved.get("types", ["Normal"])))
	_recalculate_stats(evolved, old_max_hp)
	return normalize_pokemon(evolved, str(evolved["id"]))


static func move_by_name(move_name: String) -> Dictionary:
	var moves_database := _loaded_moves()
	if moves_database.has(move_name):
		return moves_database[move_name].duplicate(true)
	if FALLBACK_MOVES.has(move_name):
		return FALLBACK_MOVES[move_name].duplicate(true)
	return FALLBACK_MOVES["Tackle"].duplicate(true)


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
	var safe_id := _safe_id(pokemon_id)
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
	var definitions := {}
	if not FileAccess.file_exists(SPECIES_PATH):
		return definitions
	var file := FileAccess.open(SPECIES_PATH, FileAccess.READ)
	if file == null:
		return definitions
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_ARRAY:
		for entry in parsed:
			if typeof(entry) == TYPE_DICTIONARY:
				var entry_id := _safe_id(str(entry.get("id", "")))
				if entry_id != "":
					definitions[entry_id] = entry
	return definitions


static func _loaded_moves() -> Dictionary:
	var moves_database: Dictionary = FALLBACK_MOVES.duplicate(true)
	if not FileAccess.file_exists(MOVES_PATH):
		return moves_database
	var file := FileAccess.open(MOVES_PATH, FileAccess.READ)
	if file == null:
		return moves_database
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_ARRAY:
		for entry in parsed:
			if typeof(entry) == TYPE_DICTIONARY:
				var move := _canonical_move(entry)
				moves_database[str(move.get("name", "Tackle"))] = move
	return moves_database


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


static func _asset_manifest() -> Dictionary:
	if not FileAccess.file_exists(MANIFEST_PATH):
		return {}
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


static func _complete_species_definition(definition: Dictionary) -> Dictionary:
	var pokemon_id := _safe_id(str(definition.get("id", DEFAULT_STARTER_ID)))
	if pokemon_id == "":
		pokemon_id = DEFAULT_STARTER_ID
	var fallback: Dictionary = FALLBACK_DEFINITIONS[pokemon_id] if FALLBACK_DEFINITIONS.has(pokemon_id) else FALLBACK_DEFINITIONS[DEFAULT_STARTER_ID]
	var species := str(definition.get("species", definition.get("name", fallback.get("species", "Charmander"))))
	var base_stats := _base_stats_from_definition(definition, fallback)
	var learnset_value = definition.get("learnset", fallback.get("learnset", {}))
	var learnset: Dictionary = learnset_value if typeof(learnset_value) == TYPE_DICTIONARY else fallback.get("learnset", {}).duplicate(true)
	var evolutions_value = definition.get("evolutions", [])
	var evolutions: Array = evolutions_value if typeof(evolutions_value) == TYPE_ARRAY else []

	definition["id"] = pokemon_id
	definition["dex_number"] = int(definition.get("dex_number", fallback.get("dex_number", 4)))
	definition["species"] = species
	definition["name"] = str(definition.get("name", species))
	definition["generation"] = maxi(1, int(definition.get("generation", fallback.get("generation", 1))))
	definition["types"] = _normalized_types(definition.get("types", fallback.get("types", ["Fire"])))
	definition["ability"] = str(definition.get("ability", fallback.get("ability", "Unknown")))
	definition["base_level"] = maxi(1, int(definition.get("base_level", fallback.get("base_level", 5))))
	definition["base_stats"] = base_stats
	definition["hp"] = int(base_stats.get("hp", 39))
	definition["max_hp"] = int(base_stats.get("hp", 39))
	definition["attack"] = int(base_stats.get("attack", 50))
	definition["defense"] = int(base_stats.get("defense", 45))
	definition["sp_attack"] = int(base_stats.get("sp_attack", 50))
	definition["sp_defense"] = int(base_stats.get("sp_defense", 50))
	definition["speed"] = int(base_stats.get("speed", 50))
	definition["friendship"] = clampi(int(definition.get("friendship", fallback.get("friendship", DEFAULT_FRIENDSHIP))), 0, 255)
	definition["learnset"] = learnset
	definition["evolutions"] = evolutions
	definition["starter"] = bool(definition.get("starter", true))
	definition["seen"] = bool(definition.get("seen", true))
	definition["owned"] = bool(definition.get("owned", false))
	return definition


static func _base_stats_from_definition(definition: Dictionary, fallback: Dictionary) -> Dictionary:
	var fallback_stats_value = fallback.get("base_stats", {})
	var fallback_stats: Dictionary = fallback_stats_value if typeof(fallback_stats_value) == TYPE_DICTIONARY else {}
	var source_value = definition.get("base_stats", {})
	var source: Dictionary = source_value if typeof(source_value) == TYPE_DICTIONARY else {}
	return {
		"hp": maxi(1, int(source.get("hp", definition.get("hp", fallback_stats.get("hp", 39))))),
		"attack": maxi(1, int(source.get("attack", definition.get("attack", fallback_stats.get("attack", 50))))),
		"defense": maxi(1, int(source.get("defense", definition.get("defense", fallback_stats.get("defense", 45))))),
		"sp_attack": maxi(1, int(source.get("sp_attack", definition.get("sp_attack", fallback_stats.get("sp_attack", 50))))),
		"sp_defense": maxi(1, int(source.get("sp_defense", definition.get("sp_defense", fallback_stats.get("sp_defense", 50))))),
		"speed": maxi(1, int(source.get("speed", definition.get("speed", fallback_stats.get("speed", 50))))),
	}


static func _moves_for_learnset(definition: Dictionary, level: int) -> Array:
	var learnset_value = definition.get("learnset", {})
	if typeof(learnset_value) != TYPE_DICTIONARY:
		return [move_by_name("Tackle")]
	var learnset: Dictionary = learnset_value
	var levels := []
	for level_key in learnset.keys():
		levels.append(int(level_key))
	levels.sort()

	var learned_moves := []
	var seen_names := {}
	for learn_level in levels:
		if int(learn_level) > level:
			continue
		var names_value = learnset.get(str(learn_level), learnset.get(learn_level, []))
		if typeof(names_value) != TYPE_ARRAY:
			continue
		for move_name in names_value:
			var move := move_by_name(str(move_name))
			var canonical_name := str(move.get("name", ""))
			if canonical_name != "" and not seen_names.has(canonical_name):
				learned_moves.append(move)
				seen_names[canonical_name] = true

	while learned_moves.size() > MAX_MOVE_SLOTS:
		learned_moves.pop_front()
	if learned_moves.is_empty():
		learned_moves.append(move_by_name("Tackle"))
	return learned_moves


static func _normalized_moves(value, pokemon_id: String, level: int) -> Array:
	var moves := []
	if typeof(value) == TYPE_ARRAY:
		for entry in value:
			var move := _move_from_saved_value(entry)
			if not move.is_empty():
				moves.append(move)
			if moves.size() >= MAX_MOVE_SLOTS:
				break
	if moves.is_empty():
		return moves_for(pokemon_id, level)
	var learned_moves := moves_for(pokemon_id, level)
	var known_names := {}
	for move in moves:
		if typeof(move) == TYPE_DICTIONARY:
			known_names[str(move.get("name", ""))] = true
	for learned_move in learned_moves:
		if moves.size() >= MAX_MOVE_SLOTS:
			break
		if typeof(learned_move) != TYPE_DICTIONARY:
			continue
		var learned_name := str(learned_move.get("name", ""))
		if learned_name != "" and not known_names.has(learned_name):
			moves.append(learned_move)
			known_names[learned_name] = true
	return moves


static func _move_from_saved_value(value) -> Dictionary:
	if typeof(value) == TYPE_STRING:
		return move_by_name(str(value))
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	var saved_move: Dictionary = value
	var move_name := str(saved_move.get("name", ""))
	if move_name == "":
		return {}
	var canonical := move_by_name(move_name)
	for key in saved_move.keys():
		if not canonical.has(key):
			canonical[key] = saved_move[key]
	return canonical


static func _canonical_move(source: Dictionary) -> Dictionary:
	return {
		"name": str(source.get("name", "Tackle")),
		"type": str(source.get("type", "Normal")),
		"category": str(source.get("category", "Physical")),
		"power": maxi(0, int(source.get("power", 40))),
		"accuracy": clampi(int(source.get("accuracy", 100)), 0, 100),
		"pp": maxi(1, int(source.get("pp", 35))),
	}


static func _pp_max_for_moves(moves: Array) -> Array:
	var pp_max := []
	for move in moves:
		if typeof(move) == TYPE_DICTIONARY:
			pp_max.append(maxi(1, int(move.get("pp", 35))))
	return pp_max


static func _normalized_pp_current(value, pp_max: Array) -> Array:
	var pp_current := []
	if typeof(value) == TYPE_ARRAY:
		for i in range(min(value.size(), pp_max.size())):
			pp_current.append(clampi(int(value[i]), 0, int(pp_max[i])))
	for i in range(pp_current.size(), pp_max.size()):
		pp_current.append(int(pp_max[i]))
	if pp_current.size() > pp_max.size():
		pp_current.resize(pp_max.size())
	return pp_current


static func _normalized_types(value) -> Array:
	var types := []
	if typeof(value) == TYPE_ARRAY:
		for entry in value:
			var type_name := str(entry)
			if type_name != "":
				types.append(type_name)
	if types.is_empty():
		types.append("Fire")
	return types


static func _empty_stat_boosts() -> Dictionary:
	var boosts := {}
	for stat_key in STAT_KEYS:
		boosts[str(stat_key)] = 0
	return boosts


static func _normalized_stat_boosts(value) -> Dictionary:
	var boosts := _empty_stat_boosts()
	if typeof(value) != TYPE_DICTIONARY:
		return boosts
	var source: Dictionary = value
	for stat_key in STAT_KEYS:
		boosts[str(stat_key)] = maxi(0, int(source.get(stat_key, 0)))
	return boosts


static func _species_id_from_value(value: Dictionary, fallback_id: String) -> String:
	var raw_id := str(value.get("id", fallback_id))
	if has_definition(raw_id):
		return _safe_id(raw_id)
	var species_name := str(value.get("species", value.get("name", "")))
	if species_name != "":
		return id_from_name(species_name)
	return DEFAULT_STARTER_ID if not has_definition(fallback_id) else _safe_id(fallback_id)


static func _recalculate_stats(pokemon: Dictionary, old_max_hp_override: int = -1) -> void:
	var old_max_hp := old_max_hp_override if old_max_hp_override > 0 else int(pokemon.get("max_hp", 1))
	var new_stats := stats_for_level(str(pokemon.get("id", DEFAULT_STARTER_ID)), int(pokemon.get("level", 1)))
	var boosts := _normalized_stat_boosts(pokemon.get("stat_boosts", {}))
	var new_max_hp := mini(stat_limit("max_hp"), int(new_stats.get("max_hp", old_max_hp)) + int(boosts.get("max_hp", 0)))
	pokemon["max_hp"] = new_max_hp
	pokemon["hp"] = clampi(int(pokemon.get("hp", new_max_hp)) + maxi(0, new_max_hp - old_max_hp), 0, new_max_hp)
	pokemon["attack"] = mini(stat_limit("attack"), int(new_stats.get("attack", pokemon.get("attack", 1))) + int(boosts.get("attack", 0)))
	pokemon["defense"] = mini(stat_limit("defense"), int(new_stats.get("defense", pokemon.get("defense", 1))) + int(boosts.get("defense", 0)))
	pokemon["sp_attack"] = mini(stat_limit("sp_attack"), int(new_stats.get("sp_attack", pokemon.get("sp_attack", 1))) + int(boosts.get("sp_attack", 0)))
	pokemon["sp_defense"] = mini(stat_limit("sp_defense"), int(new_stats.get("sp_defense", pokemon.get("sp_defense", 1))) + int(boosts.get("sp_defense", 0)))
	pokemon["speed"] = mini(stat_limit("speed"), int(new_stats.get("speed", pokemon.get("speed", 1))) + int(boosts.get("speed", 0)))
	pokemon["stat_boosts"] = boosts


static func _evolution_target_for_level(pokemon: Dictionary) -> String:
	var definition := get_definition(str(pokemon.get("id", DEFAULT_STARTER_ID)))
	var evolutions_value = definition.get("evolutions", [])
	if typeof(evolutions_value) != TYPE_ARRAY:
		return ""
	var level := int(pokemon.get("level", 1))
	for entry in evolutions_value:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if level >= int(entry.get("level", MAX_LEVEL + 1)):
			var target_id := _safe_id(str(entry.get("target", "")))
			if has_definition(target_id):
				return target_id
	return ""


static func _safe_id(value: String) -> String:
	return value.strip_edges().to_lower().replace(" ", "_").replace("-", "_")
