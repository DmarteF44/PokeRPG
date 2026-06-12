extends RefCounted

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

const NO_ENCOUNTER_WEIGHT = 25.0
const COMMON_WEIGHT = 50.0
const UNCOMMON_WEIGHT = 20.0
const RARE_WEIGHT = 4.0
const VERY_RARE_WEIGHT = 1.0
const DEFAULT_NOTHING_CHANCE = 25.0
const DEFAULT_ITEM_CHANCE = 20.0
const MAP_ENCOUNTERS_PATH = "res://data/map_encounters.json"

static var _map_encounters_cache := {}

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
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _forest_item_table(),
		"encounters": _encounters_for_map("forest", _forest_encounters()),
	},
	{
		"key": "fire",
		"type_key": "type_fire",
		"icon": "res://assets/maps/map_fire_64.png",
		"thumbnail": "res://assets/maps/thumbnails/map_fire_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_fire_360x640.png",
		"min_level": 3,
		"min_badges": 0,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _fire_item_table(),
		"encounters": _encounters_for_map("fire", _fire_encounters()),
	},
	{
		"key": "cave",
		"type_key": "type_rock",
		"icon": "res://assets/maps/map_cave_64.png",
		"thumbnail": "res://assets/maps/thumbnails/map_cave_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_cave_360x640.png",
		"min_level": 5,
		"min_badges": 1,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _default_item_table(),
		"encounters": _encounters_for_map("cave", _cave_encounters()),
	},
	{
		"key": "ice",
		"type_key": "type_ice",
		"icon": "res://assets/maps/map_ice_64.png",
		"thumbnail": "res://assets/maps/thumbnails/map_ice_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_ice_360x640.png",
		"min_level": 8,
		"min_badges": 2,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _default_item_table(),
		"encounters": _encounters_for_map("ice", _ice_encounters()),
	},
	{
		"key": "factory",
		"type_key": "type_steel",
		"icon": "res://assets/maps/map_factory_64.png",
		"thumbnail": "res://assets/maps/thumbnails/map_factory_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_factory_360x640.png",
		"min_level": 10,
		"min_badges": 2,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _default_item_table(),
		"encounters": _encounters_for_map("factory", _factory_encounters()),
	},
	{
		"key": "water",
		"type_key": "type_water",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_water_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_water_360x640.png",
		"min_level": 12,
		"min_badges": 3,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _water_item_table(),
		"encounters": _encounters_for_map("water", _water_encounters()),
	},
	{
		"key": "electric",
		"type_key": "type_electric",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_electric_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_electric_360x640.png",
		"min_level": 15,
		"min_badges": 4,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _default_item_table(),
		"encounters": _encounters_for_map("electric", _electric_encounters()),
	},
	{
		"key": "desert",
		"type_key": "type_ground",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_desert_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_desert_360x640.png",
		"min_level": 18,
		"min_badges": 5,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _default_item_table(),
		"encounters": _encounters_for_map("desert", _desert_encounters()),
	},
	{
		"key": "ghost",
		"type_key": "type_ghost",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_ghost_tower_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_ghost_tower_360x640.png",
		"min_level": 22,
		"min_badges": 6,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _default_item_table(),
		"encounters": _encounters_for_map("ghost", _ghost_encounters()),
	},
	{
		"key": "dragon",
		"type_key": "type_dragon",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_dragon_valley_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_dragon_valley_360x640.png",
		"min_level": 28,
		"min_badges": 7,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _default_item_table(),
		"encounters": _encounters_for_map("dragon", _dragon_encounters()),
	},
	{
		"key": "safari",
		"type_key": "type_mixed",
		"icon": "",
		"thumbnail": "res://assets/maps/thumbnails/map_safari_zone_96x64.png",
		"background": "res://assets/maps/backgrounds/bg_safari_zone_360x640.png",
		"min_level": 35,
		"min_badges": 8,
		"nothing_chance": DEFAULT_NOTHING_CHANCE,
		"item_table": _default_item_table(),
		"encounters": _encounters_for_map("safari", _safari_encounters()),
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


static func roll_exploration(map_key: String) -> Dictionary:
	var map_data := map_for_key(map_key)
	var nothing_chance := clampf(float(map_data.get("nothing_chance", DEFAULT_NOTHING_CHANCE)), 0.0, 100.0)
	if randf() * 100.0 < nothing_chance:
		return {"type": "nothing"}

	var item_table: Array = map_data.get("item_table", [])
	if not item_table.is_empty() and randf() * 100.0 < DEFAULT_ITEM_CHANCE:
		var item := _roll_weighted_entry(item_table)
		if not item.is_empty():
			return {
				"type": "item",
				"item_id": str(item.get("item_id", "potion")),
				"amount": maxi(1, int(item.get("amount", 1))),
			}

	var pokemon := _roll_pokemon_encounter(map_data)
	if pokemon.is_empty():
		return {"type": "nothing"}
	return {"type": "pokemon", "pokemon": pokemon}


static func roll_encounter(map_key: String) -> Dictionary:
	var map_data := map_for_key(map_key)
	return _roll_pokemon_encounter(map_data)


static func _roll_pokemon_encounter(map_data: Dictionary) -> Dictionary:
	var table: Array = map_data.get("encounters", [])
	if table.is_empty():
		return {}

	var entry := _roll_weighted_entry(table)
	if entry.is_empty() or str(entry.get("rarity", "")) == "none":
		return {}
	if entry.has("pokemon_id"):
		var pokemon_id := str(entry.get("pokemon_id", ""))
		if pokemon_id != "" and PokemonHelpers.has_definition(pokemon_id):
			return _starter_pokemon(pokemon_id, maxi(1, int(entry.get("level", 5))))
	var pokemon = entry.get("pokemon", {})
	if typeof(pokemon) == TYPE_DICTIONARY:
		return _complete_pokemon_model(pokemon)
	return {}


static func _roll_weighted_entry(table: Array) -> Dictionary:
	var total_weight := 0.0
	for entry in table:
		if typeof(entry) == TYPE_DICTIONARY:
			total_weight += maxf(0.0, float(entry.get("weight", 0.0)))
	if total_weight <= 0.0:
		return {}

	var roll := randf() * total_weight
	for entry in table:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		roll -= maxf(0.0, float(entry.get("weight", 0.0)))
		if roll <= 0.0:
			return entry
	return {}


static func _encounters_for_map(map_key: String, fallback: Array) -> Array:
	var all_tables := _loaded_map_encounters()
	var rows_value = all_tables.get(map_key, [])
	if typeof(rows_value) != TYPE_ARRAY:
		return fallback
	var rows: Array = rows_value
	var encounters := []
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var pokemon_id := str(row.get("pokemon_id", row.get("id", "")))
		if pokemon_id == "" or not PokemonHelpers.has_definition(pokemon_id):
			continue
		encounters.append({
			"rarity": str(row.get("rarity", "common")),
			"weight": maxf(0.0, float(row.get("weight", COMMON_WEIGHT))),
			"pokemon_id": pokemon_id,
			"level": maxi(1, int(row.get("level", 5))),
		})
	return encounters if not encounters.is_empty() else fallback


static func _loaded_map_encounters() -> Dictionary:
	if not _map_encounters_cache.is_empty():
		return _map_encounters_cache
	if not FileAccess.file_exists(MAP_ENCOUNTERS_PATH):
		return {}
	var file := FileAccess.open(MAP_ENCOUNTERS_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	_map_encounters_cache = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
	return _map_encounters_cache


static func _forest_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("caterpie", 10, "Caterpie", 3, ["Bug"])},
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("weedle", 13, "Weedle", 3, ["Bug", "Poison"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("pidgey", 16, "Pidgey", 4, ["Normal", "Flying"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _starter_pokemon("bulbasaur", 5)},
	]


static func _fire_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("vulpix", 37, "Vulpix", 5, ["Fire"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("growlithe", 58, "Growlithe", 6, ["Fire"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("ponyta", 77, "Ponyta", 7, ["Fire"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _starter_pokemon("charmander", 7)},
	]


static func _water_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("poliwag", 60, "Poliwag", 10, ["Water"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("psyduck", 54, "Psyduck", 11, ["Water"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("tentacool", 72, "Tentacool", 12, ["Water", "Poison"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _starter_pokemon("squirtle", 12)},
	]


static func _cave_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("zubat", 41, "Zubat", 8, ["Poison", "Flying"])},
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("geodude", 74, "Geodude", 9, ["Rock", "Ground"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("machop", 66, "Machop", 10, ["Fighting"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("onix", 95, "Onix", 12, ["Rock", "Ground"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _wild_pokemon("clefairy", 35, "Clefairy", 12, ["Fairy"])},
	]


static func _ice_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("seel", 86, "Seel", 14, ["Water"])},
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("shellder", 90, "Shellder", 15, ["Water"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("dewgong", 87, "Dewgong", 17, ["Water", "Ice"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("jynx", 124, "Jynx", 18, ["Ice", "Psychic"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _wild_pokemon("lapras", 131, "Lapras", 20, ["Water", "Ice"])},
	]


static func _factory_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("magnemite", 81, "Magnemite", 16, ["Electric", "Steel"])},
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("voltorb", 100, "Voltorb", 16, ["Electric"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("grimer", 88, "Grimer", 18, ["Poison"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("koffing", 109, "Koffing", 20, ["Poison"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _wild_pokemon("magneton", 82, "Magneton", 22, ["Electric", "Steel"])},
	]


static func _electric_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("pikachu", 25, "Pikachu", 18, ["Electric"])},
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("voltorb", 100, "Voltorb", 19, ["Electric"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("magnemite", 81, "Magnemite", 20, ["Electric", "Steel"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("electabuzz", 125, "Electabuzz", 23, ["Electric"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _wild_pokemon("raichu", 26, "Raichu", 25, ["Electric"])},
	]


static func _desert_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("sandshrew", 27, "Sandshrew", 20, ["Ground"])},
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("diglett", 50, "Diglett", 20, ["Ground"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("cubone", 104, "Cubone", 22, ["Ground"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("rhyhorn", 111, "Rhyhorn", 24, ["Ground", "Rock"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _wild_pokemon("kangaskhan", 115, "Kangaskhan", 26, ["Normal"])},
	]


static func _ghost_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("gastly", 92, "Gastly", 24, ["Ghost", "Poison"])},
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("cubone", 104, "Cubone", 24, ["Ground"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("haunter", 93, "Haunter", 26, ["Ghost", "Poison"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("marowak", 105, "Marowak", 28, ["Ground"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _wild_pokemon("gengar", 94, "Gengar", 30, ["Ghost", "Poison"])},
	]


static func _dragon_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("magikarp", 129, "Magikarp", 28, ["Water"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("gyarados", 130, "Gyarados", 30, ["Water", "Flying"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("dratini", 147, "Dratini", 32, ["Dragon"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("dragonair", 148, "Dragonair", 36, ["Dragon"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _wild_pokemon("dragonite", 149, "Dragonite", 40, ["Dragon", "Flying"])},
	]


static func _safari_encounters() -> Array:
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("nidoran_f", 29, "Nidoran-f", 35, ["Poison"])},
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _wild_pokemon("nidoran_m", 32, "Nidoran-m", 35, ["Poison"])},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _wild_pokemon("paras", 46, "Paras", 36, ["Bug", "Grass"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("scyther", 123, "Scyther", 38, ["Bug", "Flying"])},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _wild_pokemon("pinsir", 127, "Pinsir", 38, ["Bug"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _wild_pokemon("chansey", 113, "Chansey", 40, ["Normal"])},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _wild_pokemon("tauros", 128, "Tauros", 40, ["Normal"])},
	]


static func _placeholder_table(map_key: String, label: String) -> Array:
	var safe_label := label.strip_edges()
	var safe_id := "%s_placeholder" % map_key
	return [
		{"rarity": "common", "weight": COMMON_WEIGHT, "pokemon": _placeholder_pokemon(safe_id, "%s Common" % safe_label, 5)},
		{"rarity": "uncommon", "weight": UNCOMMON_WEIGHT, "pokemon": _placeholder_pokemon(safe_id, "%s Uncommon" % safe_label, 8)},
		{"rarity": "rare", "weight": RARE_WEIGHT, "pokemon": _placeholder_pokemon(safe_id, "%s Rare" % safe_label, 12)},
		{"rarity": "very_rare", "weight": VERY_RARE_WEIGHT, "pokemon": _placeholder_pokemon(safe_id, "%s Very Rare" % safe_label, 16)},
	]


static func _forest_item_table() -> Array:
	return [
		{"item_id": "potion", "amount": 1, "weight": 55.0},
		{"item_id": "poke_ball", "amount": 1, "weight": 35.0},
		{"item_id": "energy_snack", "amount": 1, "weight": 10.0},
	]


static func _fire_item_table() -> Array:
	return [
		{"item_id": "potion", "amount": 1, "weight": 45.0},
		{"item_id": "super_potion", "amount": 1, "weight": 35.0},
		{"item_id": "energy_snack", "amount": 1, "weight": 20.0},
	]


static func _water_item_table() -> Array:
	return [
		{"item_id": "potion", "amount": 1, "weight": 45.0},
		{"item_id": "poke_ball", "amount": 1, "weight": 25.0},
		{"item_id": "energy_drink", "amount": 1, "weight": 30.0},
	]


static func _default_item_table() -> Array:
	return [
		{"item_id": "potion", "amount": 1, "weight": 45.0},
		{"item_id": "super_potion", "amount": 1, "weight": 25.0},
		{"item_id": "poke_ball", "amount": 1, "weight": 20.0},
		{"item_id": "energy_snack", "amount": 1, "weight": 10.0},
	]


static func _starter_pokemon(pokemon_id: String, level: int) -> Dictionary:
	var pokemon := PokemonHelpers.starter_save_data(pokemon_id)
	pokemon["level"] = maxi(1, level)
	var stats := PokemonHelpers.stats_for_level(pokemon_id, int(pokemon["level"]))
	pokemon["max_hp"] = int(stats.get("max_hp", pokemon.get("max_hp", 1)))
	pokemon["hp"] = int(pokemon["max_hp"])
	pokemon["attack"] = int(stats.get("attack", pokemon.get("attack", 1)))
	pokemon["defense"] = int(stats.get("defense", pokemon.get("defense", 1)))
	pokemon["sp_attack"] = int(stats.get("sp_attack", pokemon.get("sp_attack", 1)))
	pokemon["sp_defense"] = int(stats.get("sp_defense", pokemon.get("sp_defense", 1)))
	pokemon["speed"] = int(stats.get("speed", pokemon.get("speed", 1)))
	pokemon["moves"] = PokemonHelpers.moves_for(pokemon_id, int(pokemon["level"]))
	pokemon["pp_max"] = []
	for move in pokemon["moves"]:
		if typeof(move) == TYPE_DICTIONARY:
			pokemon["pp_max"].append(maxi(1, int(move.get("pp", 35))))
	pokemon["pp_current"] = pokemon["pp_max"].duplicate(true)
	pokemon["starter"] = false
	return pokemon


static func _wild_pokemon(pokemon_id: String, dex_number: int, pokemon_name: String, level: int, types: Array) -> Dictionary:
	return _complete_pokemon_model({
		"id": pokemon_id,
		"dex_number": dex_number,
		"name": pokemon_name,
		"species": pokemon_name,
		"level": level,
		"hp": 24 + level * 2,
		"max_hp": 24 + level * 2,
		"attack": 8 + level,
		"defense": 7 + level,
		"sp_attack": 7 + level,
		"sp_defense": 7 + level,
		"speed": 10 + level,
		"types": types,
		"icon_path": "res://assets/pokemon/icons/%s.png" % pokemon_id,
		"moves": [PokemonHelpers.move_by_name("Tackle")],
		"pp_max": [35],
		"pp_current": [35],
	})


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
		"icon_path": "res://assets/pokemon/icons/charmander.png",
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
