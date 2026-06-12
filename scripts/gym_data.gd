extends RefCounted

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

const GYMS = [
	{
		"id": "pewter",
		"badge_number": 1,
		"city": "Pewter City",
		"leader": "Brock",
		"type": "Rock",
		"badge": "Boulder Badge",
		"min_badges": 0,
		"min_level": 1,
		"reward_money": 1400,
		"opponents": [
			{"name": "Camper Liam", "role": "trainer", "pokemon_id": "geodude", "level": 10},
			{"name": "Brock", "role": "leader", "pokemon_id": "onix", "level": 12},
		],
	},
	{
		"id": "cerulean",
		"badge_number": 2,
		"city": "Cerulean City",
		"leader": "Misty",
		"type": "Water",
		"badge": "Cascade Badge",
		"min_badges": 1,
		"min_level": 8,
		"reward_money": 2200,
		"opponents": [
			{"name": "Swimmer Nora", "role": "trainer", "pokemon_id": "staryu", "level": 18},
			{"name": "Misty", "role": "leader", "pokemon_id": "starmie", "level": 21},
		],
	},
	{
		"id": "vermilion",
		"badge_number": 3,
		"city": "Vermilion City",
		"leader": "Lt. Surge",
		"type": "Electric",
		"badge": "Thunder Badge",
		"min_badges": 2,
		"min_level": 14,
		"reward_money": 3000,
		"opponents": [
			{"name": "Sailor Dax", "role": "trainer", "pokemon_id": "voltorb", "level": 21},
			{"name": "Gentleman Eli", "role": "trainer", "pokemon_id": "pikachu", "level": 23},
			{"name": "Lt. Surge", "role": "leader", "pokemon_id": "raichu", "level": 26},
		],
	},
	{
		"id": "celadon",
		"badge_number": 4,
		"city": "Celadon City",
		"leader": "Erika",
		"type": "Grass",
		"badge": "Rainbow Badge",
		"min_badges": 3,
		"min_level": 20,
		"reward_money": 3800,
		"opponents": [
			{"name": "Lass June", "role": "trainer", "pokemon_id": "bellsprout", "level": 24},
			{"name": "Beauty May", "role": "trainer", "pokemon_id": "weepinbell", "level": 26},
			{"name": "Erika", "role": "leader", "pokemon_id": "vileplume", "level": 29},
		],
	},
	{
		"id": "fuchsia",
		"badge_number": 5,
		"city": "Fuchsia City",
		"leader": "Koga",
		"type": "Poison",
		"badge": "Soul Badge",
		"min_badges": 4,
		"min_level": 26,
		"reward_money": 4600,
		"opponents": [
			{"name": "Juggler Kai", "role": "trainer", "pokemon_id": "koffing", "level": 31},
			{"name": "Tamer Rei", "role": "trainer", "pokemon_id": "muk", "level": 33},
			{"name": "Koga", "role": "leader", "pokemon_id": "weezing", "level": 37},
		],
	},
	{
		"id": "saffron",
		"badge_number": 6,
		"city": "Saffron City",
		"leader": "Sabrina",
		"type": "Psychic",
		"badge": "Marsh Badge",
		"min_badges": 5,
		"min_level": 32,
		"reward_money": 5400,
		"opponents": [
			{"name": "Psychic Ana", "role": "trainer", "pokemon_id": "kadabra", "level": 38},
			{"name": "Channeler Ivy", "role": "trainer", "pokemon_id": "mr_mime", "level": 39},
			{"name": "Sabrina", "role": "leader", "pokemon_id": "alakazam", "level": 43},
		],
	},
	{
		"id": "cinnabar",
		"badge_number": 7,
		"city": "Cinnabar Island",
		"leader": "Blaine",
		"type": "Fire",
		"badge": "Volcano Badge",
		"min_badges": 6,
		"min_level": 38,
		"reward_money": 6200,
		"opponents": [
			{"name": "Burglar Ron", "role": "trainer", "pokemon_id": "ponyta", "level": 40},
			{"name": "Super Nerd Cal", "role": "trainer", "pokemon_id": "rapidash", "level": 42},
			{"name": "Blaine", "role": "leader", "pokemon_id": "arcanine", "level": 47},
		],
	},
	{
		"id": "viridian",
		"badge_number": 8,
		"city": "Viridian City",
		"leader": "Giovanni",
		"type": "Ground",
		"badge": "Earth Badge",
		"min_badges": 7,
		"min_level": 45,
		"reward_money": 7500,
		"opponents": [
			{"name": "Tamer Cole", "role": "trainer", "pokemon_id": "rhyhorn", "level": 45},
			{"name": "Blackbelt Dan", "role": "trainer", "pokemon_id": "dugtrio", "level": 47},
			{"name": "Giovanni", "role": "leader", "pokemon_id": "rhydon", "level": 50},
		],
	},
]


static func gyms() -> Array:
	return GYMS.duplicate(true)


static func gym_for_id(gym_id: String) -> Dictionary:
	for gym in GYMS:
		if str(gym.get("id", "")) == gym_id:
			return gym.duplicate(true)
	return {}


static func is_completed(save_data: Dictionary, gym_id: String) -> bool:
	var completed = save_data.get("gyms_completed", [])
	return typeof(completed) == TYPE_ARRAY and completed.has(gym_id)


static func is_unlocked(save_data: Dictionary, gym: Dictionary) -> bool:
	return int(save_data.get("badges", 0)) >= int(gym.get("min_badges", 0)) and max(1, int(save_data.get("level", 1))) >= int(gym.get("min_level", 1))


static func challenge_for(gym_id: String, opponent_index: int = 0) -> Dictionary:
	return {
		"active": true,
		"gym_id": gym_id,
		"opponent_index": opponent_index,
	}


static func opponent_count(gym_id: String) -> int:
	var gym := gym_for_id(gym_id)
	var opponents = gym.get("opponents", [])
	return opponents.size() if typeof(opponents) == TYPE_ARRAY else 0


static func opponent_label(gym_id: String, opponent_index: int) -> String:
	var opponent := _opponent_for(gym_id, opponent_index)
	return str(opponent.get("name", "Trainer"))


static func opponent_encounter(gym_id: String, opponent_index: int) -> Dictionary:
	var gym := gym_for_id(gym_id)
	var opponent := _opponent_for(gym_id, opponent_index)
	if gym.is_empty() or opponent.is_empty():
		return {}

	var pokemon_id := str(opponent.get("pokemon_id", PokemonHelpers.DEFAULT_STARTER_ID))
	var level := maxi(1, int(opponent.get("level", 5)))
	var pokemon := PokemonHelpers.starter_save_data(pokemon_id)
	var stats := PokemonHelpers.stats_for_level(pokemon_id, level)
	var moves := PokemonHelpers.moves_for(pokemon_id, level)
	var pp_max := []
	for move in moves:
		if typeof(move) == TYPE_DICTIONARY:
			pp_max.append(maxi(1, int(move.get("pp", 35))))

	pokemon["level"] = level
	pokemon["xp"] = 0
	pokemon["xp_to_next_level"] = PokemonHelpers.xp_to_next_level_for(level)
	pokemon["max_hp"] = int(stats.get("max_hp", pokemon.get("max_hp", 1)))
	pokemon["hp"] = int(pokemon["max_hp"])
	pokemon["attack"] = int(stats.get("attack", pokemon.get("attack", 1)))
	pokemon["defense"] = int(stats.get("defense", pokemon.get("defense", 1)))
	pokemon["sp_attack"] = int(stats.get("sp_attack", pokemon.get("sp_attack", 1)))
	pokemon["sp_defense"] = int(stats.get("sp_defense", pokemon.get("sp_defense", 1)))
	pokemon["speed"] = int(stats.get("speed", pokemon.get("speed", 1)))
	pokemon["moves"] = moves
	pokemon["pp_max"] = pp_max
	pokemon["pp_current"] = pp_max.duplicate(true)
	pokemon["starter"] = false
	pokemon["trainer_battle"] = true
	pokemon["trainer_name"] = str(opponent.get("name", "Trainer"))
	pokemon["trainer_role"] = str(opponent.get("role", "trainer"))
	pokemon["gym_id"] = gym_id
	pokemon["gym_opponent_index"] = opponent_index
	pokemon["gym_badge"] = str(gym.get("badge", "Badge"))
	pokemon["capture_rate"] = 0
	pokemon["catch_rate"] = 0
	return PokemonHelpers.normalize_pokemon(pokemon, pokemon_id)


static func next_victory_state(save_data: Dictionary) -> Dictionary:
	var challenge = save_data.get("gym_challenge", {})
	if typeof(challenge) != TYPE_DICTIONARY or not bool(challenge.get("active", false)):
		return {}

	var gym_id := str(challenge.get("gym_id", ""))
	var gym := gym_for_id(gym_id)
	if gym.is_empty():
		return {}

	var current_index := int(challenge.get("opponent_index", 0))
	var next_index := current_index + 1
	var total := opponent_count(gym_id)
	if next_index < total:
		return {
			"completed": false,
			"next_index": next_index,
			"next_encounter": opponent_encounter(gym_id, next_index),
			"next_label": opponent_label(gym_id, next_index),
		}

	var completed := _string_array(save_data.get("gyms_completed", []))
	var leaders := _string_array(save_data.get("gym_leaders_defeated", []))
	var badges := _string_array(save_data.get("badges_obtained", []))
	if not completed.has(gym_id):
		completed.append(gym_id)
	var leader := str(gym.get("leader", "Leader"))
	if not leaders.has(leader):
		leaders.append(leader)
	var badge := str(gym.get("badge", "Badge"))
	if not badges.has(badge):
		badges.append(badge)

	return {
		"completed": true,
		"gym": gym,
		"gyms_completed": completed,
		"gym_leaders_defeated": leaders,
		"badges_obtained": badges,
		"badges": maxi(int(save_data.get("badges", 0)), int(gym.get("badge_number", 0))),
		"money": int(save_data.get("money", 3000)) + int(gym.get("reward_money", 0)),
	}


static func _opponent_for(gym_id: String, opponent_index: int) -> Dictionary:
	var gym := gym_for_id(gym_id)
	var opponents = gym.get("opponents", [])
	if typeof(opponents) != TYPE_ARRAY or opponent_index < 0 or opponent_index >= opponents.size():
		return {}
	return opponents[opponent_index].duplicate(true)


static func _string_array(value) -> Array:
	var result := []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		var text := str(entry)
		if text != "" and not result.has(text):
			result.append(text)
	return result
