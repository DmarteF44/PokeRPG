extends RefCounted

const NO_ENCOUNTER_WEIGHT = 25.0
const COMMON_WEIGHT = 50.0
const UNCOMMON_WEIGHT = 20.0
const RARE_WEIGHT = 4.0
const VERY_RARE_WEIGHT = 1.0

static func _map_definitions() -> Array:
	return [
	{
		"key": "forest",
		"type_key": "type_grass",
		"icon": "res://assets/maps/map_forest_64.png",
		"thumbnail": "res://assets/maps/thumbnails/map_forest_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_forest_360x640.png",
		"min_level": 1,
		"min_badges": 0,
		"encounters": [
			{"rarity": "none", "weight": NO_ENCOUNTER_WEIGHT},
			{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": {"id": "wurmple", "dex_number": 265, "name": "Wurmple", "level": 3, "hp": 25, "max_hp": 25, "attack": 8, "defense": 5, "speed": 30, "types": ["Bug"], "icon_path": "res://assets/sprites/sprite_wurmple_96.png"}},
			{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": {"id": "bulbasaur", "dex_number": 1, "name": "Bulbasaur", "level": 5, "hp": 45, "max_hp": 45, "attack": 49, "defense": 49, "speed": 45, "types": ["Grass", "Poison"], "icon_path": "res://assets/pokemon/icons/bulbasaur.png"}},
			{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": {"id": "charmander", "dex_number": 4, "name": "Charmander", "level": 6, "hp": 39, "max_hp": 39, "attack": 52, "defense": 43, "speed": 65, "types": ["Fire"], "icon_path": "res://assets/pokemon/icons/charmander.png"}},
			{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": {"id": "squirtle", "dex_number": 7, "name": "Squirtle", "level": 7, "hp": 44, "max_hp": 44, "attack": 48, "defense": 65, "speed": 43, "types": ["Water"], "icon_path": "res://assets/pokemon/icons/squirtle.png"}},
		],
	},
	{
		"key": "fire",
		"type_key": "type_fire",
		"icon": "res://assets/maps/map_fire_64.png",
		"thumbnail": "res://assets/maps/thumbnails/map_fire_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_fire_360x640.png",
		"min_level": 3,
		"min_badges": 0,
		"encounters": _placeholder_table("fire", "Fire"),
	},
	{
		"key": "cave",
		"type_key": "type_rock",
		"icon": "res://assets/maps/map_cave_64.png",
		"thumbnail": "res://assets/maps/thumbnails/map_cave_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_cave_360x640.png",
		"min_level": 5,
		"min_badges": 1,
		"encounters": _placeholder_table("cave", "Cave"),
	},
	{
		"key": "ice",
		"type_key": "type_ice",
		"icon": "res://assets/maps/map_ice_64.png",
		"thumbnail": "res://assets/maps/thumbnails/map_ice_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_ice_360x640.png",
		"min_level": 8,
		"min_badges": 2,
		"encounters": _placeholder_table("ice", "Ice"),
	},
	{
		"key": "factory",
		"type_key": "type_steel",
		"icon": "res://assets/maps/map_factory_64.png",
		"thumbnail": "res://assets/maps/thumbnails/map_factory_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_factory_360x640.png",
		"min_level": 10,
		"min_badges": 2,
		"encounters": _placeholder_table("factory", "Factory"),
	},
	{
		"key": "water",
		"type_key": "type_water",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_water_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_water_360x640.png",
		"min_level": 12,
		"min_badges": 3,
		"encounters": _placeholder_table("water", "Water"),
	},
	{
		"key": "electric",
		"type_key": "type_electric",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_electric_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_electric_360x640.png",
		"min_level": 15,
		"min_badges": 4,
		"encounters": _placeholder_table("electric", "Electric"),
	},
	{
		"key": "desert",
		"type_key": "type_ground",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_desert_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_desert_360x640.png",
		"min_level": 18,
		"min_badges": 5,
		"encounters": _placeholder_table("desert", "Desert"),
	},
	{
		"key": "ghost",
		"type_key": "type_ghost",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_ghost_tower_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_ghost_tower_360x640.png",
		"min_level": 22,
		"min_badges": 6,
		"encounters": _placeholder_table("ghost", "Ghost"),
	},
	{
		"key": "dragon",
		"type_key": "type_dragon",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_dragon_valley_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_dragon_valley_360x640.png",
		"min_level": 28,
		"min_badges": 7,
		"encounters": _placeholder_table("dragon", "Dragon"),
	},
	{
		"key": "safari",
		"type_key": "type_mixed",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_safari_zone_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_safari_zone_360x640.png",
		"min_level": 35,
		"min_badges": 8,
		"encounters": _placeholder_table("safari", "Safari"),
	},
]


static func maps() -> Array:
	return _map_definitions().duplicate(true)


static func map_for_key(map_key: String) -> Dictionary:
	var definitions := _map_definitions()
	for map_data in definitions:
		if str(map_data.get("key", "")) == map_key:
			return map_data.duplicate(true)
	return definitions[0].duplicate(true)


static func meets_requirements(save_data: Dictionary, map_data: Dictionary) -> bool:
	return max(1, int(save_data.get("level", 1))) >= int(map_data.get("min_level", 1)) and int(save_data.get("badges", 0)) >= int(map_data.get("min_badges", 0))


static func roll_encounter(map_key: String) -> Dictionary:
	var map_data := map_for_key(map_key)
	var table: Array = map_data.get("encounters", [])
	if table.is_empty():
		return {}

	var total_weight := 0.0
	for entry in table:
		total_weight += maxf(0.0, float(entry.get("weight", 0.0)))

	var roll := randf() * total_weight
	for entry in table:
		roll -= maxf(0.0, float(entry.get("weight", 0.0)))
		if roll <= 0.0:
			if str(entry.get("rarity", "")) == "none":
				return {}
			var pokemon = entry.get("pokemon", {})
			if typeof(pokemon) == TYPE_DICTIONARY:
				return _complete_pokemon_model(pokemon)
			return {}
	return {}


static func _placeholder_table(map_key: String, label: String) -> Array:
	var safe_label := label.strip_edges()
	var safe_id := "%s_placeholder" % map_key
	return [
		{"rarity": "none", "weight": NO_ENCOUNTER_WEIGHT},
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _placeholder_pokemon(safe_id, "%s Common" % safe_label, 5)},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _placeholder_pokemon(safe_id, "%s Uncommon" % safe_label, 8)},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _placeholder_pokemon(safe_id, "%s Rare" % safe_label, 12)},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _placeholder_pokemon(safe_id, "%s Very Rare" % safe_label, 16)},
	]


static func _placeholder_pokemon(pokemon_id: String, pokemon_name: String, level: int) -> Dictionary:
	return _complete_pokemon_model({
		"id": pokemon_id,
		"dex_number": 0,
		"name": pokemon_name,
		"level": level,
		"hp": 30 + level,
		"max_hp": 30 + level,
		"attack": 10 + level,
		"defense": 8 + level,
		"speed": 8 + level,
		"types": ["Normal"],
		"icon_path": "res://assets/sprites/sprite_wurmple_96.png",
	})


static func _complete_pokemon_model(source: Dictionary) -> Dictionary:
	var pokemon := source.duplicate(true)
	var species := str(pokemon.get("species", pokemon.get("name", "Pokemon")))
	pokemon["species"] = species
	pokemon["nickname"] = str(pokemon.get("nickname", ""))
	pokemon["name"] = str(pokemon.get("name", species))
	pokemon["generation"] = max(1, int(pokemon.get("generation", 1)))
	pokemon["level"] = max(1, int(pokemon.get("level", 1)))
	pokemon["xp"] = max(0, int(pokemon.get("xp", 0)))
	pokemon["xp_to_next_level"] = max(1, int(pokemon.get("xp_to_next_level", 100)))
	pokemon["nature"] = str(pokemon.get("nature", "Hardy"))
	pokemon["ability"] = str(pokemon.get("ability", "Unknown"))
	pokemon["gender"] = str(pokemon.get("gender", "Unknown"))
	pokemon["shiny"] = bool(pokemon.get("shiny", false))
	pokemon["hp"] = max(1, int(pokemon.get("hp", 1)))
	pokemon["max_hp"] = max(1, int(pokemon.get("max_hp", pokemon["hp"])))
	pokemon["attack"] = max(1, int(pokemon.get("attack", 1)))
	pokemon["defense"] = max(1, int(pokemon.get("defense", 1)))
	pokemon["sp_attack"] = max(1, int(pokemon.get("sp_attack", pokemon["attack"])))
	pokemon["sp_defense"] = max(1, int(pokemon.get("sp_defense", pokemon["defense"])))
	pokemon["speed"] = max(1, int(pokemon.get("speed", 1)))
	var types_value = pokemon.get("types", [])
	if typeof(types_value) != TYPE_ARRAY or types_value.is_empty():
		pokemon["types"] = ["Normal"]
	var status_value = pokemon.get("status_condition", null)
	pokemon["status_condition"] = null if status_value == null or str(status_value) == "" else str(status_value)
	var held_item_value = pokemon.get("held_item", null)
	pokemon["held_item"] = null if held_item_value == null or str(held_item_value) == "" else str(held_item_value)
	var moves = pokemon.get("moves", [])
	if typeof(moves) != TYPE_ARRAY:
		moves = []
	pokemon["moves"] = moves
	var pp_max = pokemon.get("pp_max", [])
	if typeof(pp_max) != TYPE_ARRAY:
		pp_max = []
	var pp_current = pokemon.get("pp_current", [])
	if typeof(pp_current) != TYPE_ARRAY:
		pp_current = []
	pokemon["pp_max"] = pp_max
	pokemon["pp_current"] = pp_current
	pokemon["friendship"] = clampi(int(pokemon.get("friendship", 70)), 0, 255)
	var capture_date_value = pokemon.get("capture_date", "")
	pokemon["capture_date"] = "" if capture_date_value == null else str(capture_date_value)
	return pokemon
