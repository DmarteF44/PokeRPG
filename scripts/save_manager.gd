extends Node

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

const SETTINGS_PATH = "user://settings.json"
const SAVES_DIR = "user://saves"
const MAX_SAVE_SLOTS = 3
const DEFAULT_SETTINGS = {
	"music_enabled": true,
	"sfx_enabled": true,
	"language": "en",
}
const DEFAULT_INVENTORY = {
	"poke_ball": 5,
	"potion": 3,
	"town_map": 1,
}
const DEFAULT_ENERGY_MAX = 30
const MAX_TEAM_SIZE = 5
const MAX_STORAGE_SIZE = 500

var _settings: Dictionary = DEFAULT_SETTINGS.duplicate(true)
var _current_save: Dictionary = {}


func _ready() -> void:
	load_settings()


func load_settings() -> Dictionary:
	_settings = DEFAULT_SETTINGS.duplicate(true)

	if not FileAccess.file_exists(SETTINGS_PATH):
		return _settings.duplicate(true)

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return _settings.duplicate(true)

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		var parsed_settings: Dictionary = parsed
		for key in DEFAULT_SETTINGS.keys():
			if parsed_settings.has(key):
				_settings[key] = parsed_settings[key]

	return _settings.duplicate(true)


func save_settings(settings: Dictionary) -> void:
	for key in DEFAULT_SETTINGS.keys():
		if settings.has(key):
			_settings[key] = settings[key]

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_settings, "\t"))


func get_settings() -> Dictionary:
	return _settings.duplicate(true)


func create_save(slot: int, data: Dictionary) -> Dictionary:
	_ensure_saves_dir()

	var save_slot := clampi(slot, 1, MAX_SAVE_SLOTS)
	var now := Time.get_datetime_string_from_system()
	var starter_id := _starter_id_from_data(data)
	var starter_definition := PokemonHelpers.get_definition(starter_id)
	var starter_pokemon := _starter_from_profile_data(data, starter_id)
	var raw_team = data.get("team", [])
	if typeof(raw_team) != TYPE_ARRAY or raw_team.is_empty():
		raw_team = [starter_pokemon]
	var raw_seen = data.get("seen_pokemon", [starter_id])
	var raw_owned = data.get("owned_pokemon", [starter_id])
	var save_data := {
		"slot": save_slot,
		"player_name": str(data.get("player_name", _default_player_name())).strip_edges(),
		"avatar_id": int(data.get("avatar_id", 1)),
		"avatar_type": str(data.get("avatar_type", "preset")),
		"avatar_custom_path": str(data.get("avatar_custom_path", "")),
		"starter_generation": int(data.get("starter_generation", 1)),
		"starter_id": starter_id,
		"starter_name": str(data.get("starter_name", starter_definition.get("name", "Charmander"))),
		"starter_dex_number": int(data.get("starter_dex_number", starter_definition.get("dex_number", 4))),
		"money": int(data.get("money", 3000)),
		"badges": int(data.get("badges", 0)),
		"level": max(1, int(data.get("level", 1))),
		"energy_current": int(data.get("energy_current", DEFAULT_ENERGY_MAX)),
		"energy_max": int(data.get("energy_max", DEFAULT_ENERGY_MAX)),
		"last_energy_reset": str(data.get("last_energy_reset", _today_string())),
		"inventory": _normalized_inventory(data.get("inventory", DEFAULT_INVENTORY)),
		"team": _normalized_team(raw_team, starter_id),
		"storage": _normalized_storage(data.get("storage", [])),
		"active_pokemon_index": int(data.get("active_pokemon_index", 0)),
		"seen_pokemon": _normalized_seen_pokemon(raw_seen, raw_owned),
		"owned_pokemon": _normalized_owned_pokemon(raw_owned, raw_team, starter_id, data.get("storage", [])),
		"gyms_completed": _normalized_string_array(data.get("gyms_completed", [])),
		"gym_leaders_defeated": _normalized_string_array(data.get("gym_leaders_defeated", [])),
		"badges_obtained": _normalized_string_array(data.get("badges_obtained", [])),
		"gym_challenge": _normalized_gym_challenge(data.get("gym_challenge", {})),
		"current_scene": str(data.get("current_scene", "HomeScreen")),
		"current_map": str(data.get("current_map", "")),
		"settings_language": str(_settings.get("language", "en")),
		"created_at": str(data.get("created_at", now)),
		"updated_at": now,
	}

	if save_data["player_name"] == "":
		save_data["player_name"] = _default_player_name()

	_write_save(save_slot, save_data)
	set_current_save(save_data)
	return save_data.duplicate(true)


func get_save(slot: int) -> Dictionary:
	var path := _save_path(slot)
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}

	var save_data: Dictionary = parsed
	return _normalized_save(save_data)


func get_all_saves() -> Array:
	var saves := []
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		saves.append(get_save(slot))
	return saves


func load_save(slot: int) -> Dictionary:
	var save_data := get_save(slot)
	if save_data.is_empty():
		return {}

	save_data["updated_at"] = Time.get_datetime_string_from_system()
	_write_save(slot, save_data)
	set_current_save(save_data)
	return save_data.duplicate(true)


func delete_save(slot: int) -> void:
	if not has_save(slot):
		return

	var dir := DirAccess.open(SAVES_DIR)
	if dir != null:
		dir.remove(_save_file_name(slot))

	if int(_current_save.get("slot", 0)) == clampi(slot, 1, MAX_SAVE_SLOTS):
		_current_save.clear()


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_save_path(slot))


func get_current_save() -> Dictionary:
	if not _current_save.is_empty():
		var normalized := _normalized_save(_current_save)
		if normalized != _current_save:
			_current_save = normalized
			_write_save(int(_current_save.get("slot", 1)), _current_save)
	return _current_save.duplicate(true)


func set_current_save(save_data: Dictionary) -> void:
	_current_save = _normalized_save(save_data)


func update_current_save(changes: Dictionary) -> Dictionary:
	if _current_save.is_empty():
		return {}

	var updated := _current_save.duplicate(true)
	for key in changes.keys():
		updated[key] = changes[key]

	updated["updated_at"] = Time.get_datetime_string_from_system()
	updated = _normalized_save(updated)
	_write_save(int(updated.get("slot", 1)), updated)
	set_current_save(updated)
	return _current_save.duplicate(true)


func save_current_save(save_data: Dictionary) -> Dictionary:
	if save_data.is_empty():
		return {}

	var normalized := _normalized_save(save_data)
	normalized["updated_at"] = Time.get_datetime_string_from_system()
	_write_save(int(normalized.get("slot", 1)), normalized)
	set_current_save(normalized)
	return _current_save.duplicate(true)


func _normalized_save(save_data: Dictionary) -> Dictionary:
	if save_data.is_empty():
		return {}

	var normalized := save_data.duplicate(true)
	normalized["slot"] = int(normalized.get("slot", 1))
	normalized["player_name"] = str(normalized.get("player_name", _default_player_name()))
	normalized["avatar_id"] = int(normalized.get("avatar_id", 1))
	normalized["avatar_type"] = str(normalized.get("avatar_type", "preset"))
	normalized["avatar_custom_path"] = str(normalized.get("avatar_custom_path", ""))
	normalized["starter_generation"] = int(normalized.get("starter_generation", 1))
	var starter_id := _starter_id_from_data(normalized)
	var starter_definition := PokemonHelpers.get_definition(starter_id)
	normalized["starter_id"] = starter_id
	normalized["starter_name"] = str(normalized.get("starter_name", starter_definition.get("name", "Charmander")))
	normalized["starter_dex_number"] = int(normalized.get("starter_dex_number", starter_definition.get("dex_number", 4)))
	normalized["money"] = int(normalized.get("money", 3000))
	normalized["badges"] = int(normalized.get("badges", 0))
	normalized["level"] = max(1, int(normalized.get("level", 1)))
	_apply_daily_energy_reset(normalized)
	normalized["inventory"] = _normalized_inventory(normalized.get("inventory", DEFAULT_INVENTORY))
	normalized["team"] = _normalized_team(normalized.get("team", []), starter_id)
	normalized["storage"] = _normalized_storage(normalized.get("storage", []))
	normalized["active_pokemon_index"] = clampi(int(normalized.get("active_pokemon_index", 0)), 0, maxi(0, normalized["team"].size() - 1))
	normalized["owned_pokemon"] = _normalized_owned_pokemon(normalized.get("owned_pokemon", []), normalized["team"], starter_id, normalized["storage"])
	_backfill_owned_pokemon_instances(normalized)
	normalized["owned_pokemon"] = _normalized_owned_pokemon(normalized.get("owned_pokemon", []), normalized["team"], starter_id, normalized["storage"])
	normalized["seen_pokemon"] = _normalized_seen_pokemon(normalized.get("seen_pokemon", []), normalized["owned_pokemon"])
	normalized["gyms_completed"] = _normalized_string_array(normalized.get("gyms_completed", []))
	normalized["gym_leaders_defeated"] = _normalized_string_array(normalized.get("gym_leaders_defeated", []))
	normalized["badges_obtained"] = _normalized_string_array(normalized.get("badges_obtained", []))
	normalized["gym_challenge"] = _normalized_gym_challenge(normalized.get("gym_challenge", {}))
	normalized["current_scene"] = str(normalized.get("current_scene", "HomeScreen"))
	normalized["current_map"] = str(normalized.get("current_map", ""))
	normalized["settings_language"] = str(normalized.get("settings_language", _settings.get("language", "en")))
	normalized["created_at"] = str(normalized.get("created_at", ""))
	normalized["updated_at"] = str(normalized.get("updated_at", ""))
	return normalized


func _write_save(slot: int, save_data: Dictionary) -> void:
	_ensure_saves_dir()
	var file := FileAccess.open(_save_path(slot), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(save_data, "\t"))


func _ensure_saves_dir() -> void:
	var dir := DirAccess.open("user://")
	if dir != null and not dir.dir_exists("saves"):
		dir.make_dir_recursive("saves")


func _save_path(slot: int) -> String:
	return "%s/%s" % [SAVES_DIR, _save_file_name(slot)]


func _save_file_name(slot: int) -> String:
	return "save_%d.json" % clampi(slot, 1, MAX_SAVE_SLOTS)


func _default_player_name() -> String:
	return "Jogador" if str(_settings.get("language", "en")) == "pt" else "Player"


func _apply_daily_energy_reset(save_data: Dictionary) -> void:
	var energy_max: int = max(1, int(save_data.get("energy_max", DEFAULT_ENERGY_MAX)))
	var energy_current: int = clampi(int(save_data.get("energy_current", energy_max)), 0, energy_max)
	var today := _today_string()
	var last_reset := str(save_data.get("last_energy_reset", ""))

	if last_reset != today:
		energy_current = energy_max
		last_reset = today

	save_data["energy_max"] = energy_max
	save_data["energy_current"] = energy_current
	save_data["last_energy_reset"] = last_reset


func _today_string() -> String:
	var date := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [int(date["year"]), int(date["month"]), int(date["day"])]


func _normalized_inventory(value) -> Dictionary:
	var inventory := {}
	if typeof(value) == TYPE_DICTIONARY:
		var source: Dictionary = value
		for item_id in source.keys():
			inventory[str(item_id)] = max(0, int(source[item_id]))

	if inventory.is_empty():
		return DEFAULT_INVENTORY.duplicate(true)

	return inventory


func _normalized_string_array(value) -> Array:
	var result := []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		var text := str(entry)
		if text != "" and not result.has(text):
			result.append(text)
	return result


func _normalized_gym_challenge(value) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	var source: Dictionary = value
	if not bool(source.get("active", false)):
		return {}
	var gym_id := str(source.get("gym_id", ""))
	if gym_id == "":
		return {}
	return {
		"active": true,
		"gym_id": gym_id,
		"opponent_index": maxi(0, int(source.get("opponent_index", 0))),
	}


func _normalized_team(value, starter_id: String = PokemonHelpers.DEFAULT_STARTER_ID) -> Array:
	var team := []
	if typeof(value) == TYPE_ARRAY:
		for entry in value:
			if typeof(entry) == TYPE_DICTIONARY:
				team.append(PokemonHelpers.normalize_pokemon(entry, starter_id))
				if team.size() >= MAX_TEAM_SIZE:
					break

	if team.is_empty():
		team.append(PokemonHelpers.starter_save_data(starter_id))

	return team


func _normalized_storage(value) -> Array:
	var storage := []
	if typeof(value) == TYPE_ARRAY:
		for entry in value:
			if typeof(entry) == TYPE_DICTIONARY:
				storage.append(PokemonHelpers.normalize_pokemon(entry, str(entry.get("id", PokemonHelpers.DEFAULT_STARTER_ID))))
				if storage.size() >= MAX_STORAGE_SIZE:
					break
	return storage


func _starter_from_profile_data(data: Dictionary, starter_id: String) -> Dictionary:
	var starter := PokemonHelpers.starter_save_data(starter_id)
	var nickname := str(data.get("starter_nickname", "")).strip_edges()
	if nickname != "":
		starter["nickname"] = nickname
		starter["name"] = nickname
	return PokemonHelpers.normalize_pokemon(starter, starter_id)


func _normalized_seen_pokemon(value, owned_value = []) -> Array:
	var seen := []
	if typeof(value) == TYPE_ARRAY:
		for entry in value:
			var pokemon_id := str(entry)
			if pokemon_id != "" and not seen.has(pokemon_id):
				seen.append(pokemon_id)

	if typeof(owned_value) == TYPE_ARRAY:
		for entry in owned_value:
			var pokemon_id := str(entry)
			if pokemon_id != "" and not seen.has(pokemon_id):
				seen.append(pokemon_id)
	return seen


func _normalized_owned_pokemon(value, team_value, starter_id: String, storage_value = []) -> Array:
	var owned := []
	if typeof(value) == TYPE_ARRAY:
		for entry in value:
			var pokemon_id := str(entry)
			if pokemon_id != "" and not owned.has(pokemon_id):
				owned.append(pokemon_id)

	if typeof(team_value) == TYPE_ARRAY:
		for entry in team_value:
			if typeof(entry) == TYPE_DICTIONARY:
				var team_id := str(entry.get("id", ""))
				if PokemonHelpers.has_definition(team_id) and not owned.has(team_id):
					owned.append(team_id)
				elif team_id != "" and not owned.has(team_id):
					owned.append(team_id)

	if typeof(storage_value) == TYPE_ARRAY:
		for entry in storage_value:
			if typeof(entry) == TYPE_DICTIONARY:
				var storage_id := str(entry.get("id", ""))
				if PokemonHelpers.has_definition(storage_id) and not owned.has(storage_id):
					owned.append(storage_id)
				elif storage_id != "" and not owned.has(storage_id):
					owned.append(storage_id)

	if owned.is_empty() and PokemonHelpers.is_starter_id(starter_id):
		owned.append(starter_id)
	return owned


func _backfill_owned_pokemon_instances(save_data: Dictionary) -> void:
	var team: Array = save_data.get("team", [])
	var storage: Array = save_data.get("storage", [])
	var owned = save_data.get("owned_pokemon", [])
	if typeof(owned) != TYPE_ARRAY:
		return

	var represented := {}
	for entry in team:
		if typeof(entry) == TYPE_DICTIONARY:
			represented[str(entry.get("id", ""))] = true
	for entry in storage:
		if typeof(entry) == TYPE_DICTIONARY:
			represented[str(entry.get("id", ""))] = true

	for entry in owned:
		var pokemon_id := str(entry)
		if pokemon_id == "" or represented.has(pokemon_id) or not PokemonHelpers.has_definition(pokemon_id):
			continue
		if team.size() < MAX_TEAM_SIZE:
			team.append(PokemonHelpers.starter_save_data(pokemon_id))
		elif storage.size() < MAX_STORAGE_SIZE:
			storage.append(PokemonHelpers.starter_save_data(pokemon_id))
		represented[pokemon_id] = true

	save_data["team"] = team
	save_data["storage"] = storage


func _starter_id_from_data(data: Dictionary) -> String:
	var starter_id := str(data.get("starter_id", ""))
	if PokemonHelpers.is_starter_id(starter_id):
		return starter_id

	var starter_name := str(data.get("starter_name", ""))
	if starter_name != "":
		return PokemonHelpers.id_from_name(starter_name)

	var starter_dex := int(data.get("starter_dex_number", 0))
	if starter_dex > 0:
		return PokemonHelpers.id_from_dex(starter_dex)

	return PokemonHelpers.DEFAULT_STARTER_ID
