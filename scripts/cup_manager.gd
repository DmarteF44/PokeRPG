extends RefCounted

# Data-driven Tournament ("Cup") system. Named "cups" internally (Kanto Cup,
# Johto Cup, ...) rather than "tournament" because this codebase already
# uses "tournament" as its internal/legacy name for the GYM challenge screen
# (see gym_data.gd, home_screen.gd's tournament_popup) - a real, unrelated
# feature that predates this one. Do not rename either to "fix" the clash.
#
# Mirrors gym_data.gd's architecture on purpose (single-elimination bracket,
# one trainer per round, chained single-Pokemon encounters within a round
# exactly like a gym's opponent list - real Pokemon games never heal or
# reset state between an opposing trainer's team members either, so this is
# the same mechanic, just relabeled at the UI/text level as "trainer sent
# out its next Pokemon" instead of "next trainer"). A cup's "team" per
# round trainer is therefore multiple chained single-Pokemon fights, not a
# new battle-engine feature.

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

const CUPS_PATH = "res://data/cups.json"
const TRAINERS_PATH = "res://data/cup_trainers.json"

static var _cups_cache: Dictionary = {}
static var _trainers_cache: Dictionary = {}


static func _loaded_cups() -> Dictionary:
	if _cups_cache.is_empty():
		if FileAccess.file_exists(CUPS_PATH):
			var file := FileAccess.open(CUPS_PATH, FileAccess.READ)
			if file != null:
				var parsed = JSON.parse_string(file.get_as_text())
				if typeof(parsed) == TYPE_DICTIONARY:
					_cups_cache = parsed
	return _cups_cache


static func _loaded_trainers() -> Dictionary:
	if _trainers_cache.is_empty():
		if FileAccess.file_exists(TRAINERS_PATH):
			var file := FileAccess.open(TRAINERS_PATH, FileAccess.READ)
			if file != null:
				var parsed = JSON.parse_string(file.get_as_text())
				if typeof(parsed) == TYPE_DICTIONARY:
					_trainers_cache = parsed
	return _trainers_cache


# All cup definitions, each with its "id" key injected, sorted by "order".
static func cups() -> Array:
	var source := _loaded_cups()
	var result := []
	for cup_id in source.keys():
		var entry = source[cup_id]
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var cup: Dictionary = entry.duplicate(true)
		cup["id"] = str(cup_id)
		result.append(cup)
	result.sort_custom(func(a, b): return int(a.get("order", 0)) < int(b.get("order", 0)))
	return result


static func cup_for_id(cup_id: String) -> Dictionary:
	var source := _loaded_cups()
	if not source.has(cup_id):
		return {}
	var cup: Dictionary = source[cup_id].duplicate(true)
	cup["id"] = cup_id
	return cup


static func trainer_for_id(trainer_id: String) -> Dictionary:
	var source := _loaded_trainers()
	if not source.has(trainer_id):
		return {}
	var trainer: Dictionary = source[trainer_id].duplicate(true)
	trainer["id"] = trainer_id
	return trainer


static func rounds_for(cup: Dictionary) -> Array:
	var rounds = cup.get("rounds", [])
	return rounds if typeof(rounds) == TYPE_ARRAY else []


static func round_count(cup: Dictionary) -> int:
	return rounds_for(cup).size()


static func round_for_index(cup: Dictionary, round_index: int) -> Dictionary:
	var rounds := rounds_for(cup)
	if round_index < 0 or round_index >= rounds.size():
		return {}
	return rounds[round_index] if typeof(rounds[round_index]) == TYPE_DICTIONARY else {}


# Save-data progress for one cup: {"participated","completed","won","completed_count"}.
static func progress_for(save_data: Dictionary, cup_id: String) -> Dictionary:
	var cups_progress = save_data.get("cups", {})
	if typeof(cups_progress) != TYPE_DICTIONARY or not cups_progress.has(cup_id):
		return {"participated": false, "completed": false, "won": false, "completed_count": 0}
	var entry = cups_progress[cup_id]
	if typeof(entry) != TYPE_DICTIONARY:
		return {"participated": false, "completed": false, "won": false, "completed_count": 0}
	return {
		"participated": bool(entry.get("participated", false)),
		"completed": bool(entry.get("completed", false)),
		"won": bool(entry.get("won", false)),
		"completed_count": int(entry.get("completed_count", 0)),
	}


static func is_unlocked(save_data: Dictionary, cup: Dictionary) -> bool:
	if not bool(cup.get("implemented", false)):
		return false
	if max(1, int(save_data.get("level", 1))) < int(cup.get("min_trainer_level", 1)):
		return false
	var requirements = cup.get("requirements", {})
	if typeof(requirements) != TYPE_DICTIONARY:
		return true
	if requirements.has("min_badges") and int(save_data.get("badges", 0)) < int(requirements["min_badges"]):
		return false
	var required_cups = requirements.get("cups_completed", [])
	if typeof(required_cups) == TYPE_ARRAY:
		for required_id in required_cups:
			if not progress_for(save_data, str(required_id)).get("completed", false):
				return false
	return true


# Checks the player's actual current team (save_data.team) against a cup's
# optional "team_rules" - the entry conditions Special Tournaments use for
# real restrictions (Monotype/Shiny/Black/No Items/Level Cap/Team Size),
# not just flavor text. Returns one Dictionary per broken rule
# ({"rule": ..., ...extra info for the message}), empty if the team is
# eligible or the cup declares no team_rules at all. "No items" isn't
# checked here - that's enforced live during the battle (see
# battle_scene.gd's _cup_items_allowed()), not as an entry gate, since it's
# a battle-time restriction, not a team-composition one.
static func team_rule_violations(save_data: Dictionary, cup: Dictionary) -> Array:
	var violations := []
	var rules = cup.get("team_rules", {})
	if typeof(rules) != TYPE_DICTIONARY or rules.is_empty():
		return violations

	var team_value = save_data.get("team", [])
	var team: Array = team_value if typeof(team_value) == TYPE_ARRAY else []

	if rules.has("max_team_size"):
		var cap := int(rules["max_team_size"])
		if team.size() > cap:
			violations.append({"rule": "max_team_size", "cap": cap, "actual": team.size()})

	if rules.has("max_level"):
		var cap := int(rules["max_level"])
		for mon in team:
			if typeof(mon) == TYPE_DICTIONARY and int(mon.get("level", 1)) > cap:
				violations.append({"rule": "max_level", "cap": cap})
				break

	if bool(rules.get("monotype", false)) and not team.is_empty():
		var common: Array = []
		var first := true
		for mon in team:
			if typeof(mon) != TYPE_DICTIONARY:
				continue
			var types_value = mon.get("types", [])
			var types: Array = types_value if typeof(types_value) == TYPE_ARRAY else []
			if first:
				common = types.duplicate()
				first = false
			else:
				var next_common := []
				for t in common:
					if types.has(t):
						next_common.append(t)
				common = next_common
		if common.is_empty():
			violations.append({"rule": "monotype"})

	if rules.has("required_type"):
		var required := str(rules["required_type"])
		for mon in team:
			if typeof(mon) != TYPE_DICTIONARY:
				continue
			var types_value = mon.get("types", [])
			var types: Array = types_value if typeof(types_value) == TYPE_ARRAY else []
			if not types.has(required):
				violations.append({"rule": "required_type", "type": required})
				break

	if rules.has("required_variant"):
		var variant := str(rules["required_variant"])
		for mon in team:
			if typeof(mon) == TYPE_DICTIONARY and not bool(mon.get(variant, false)):
				violations.append({"rule": "required_variant", "variant": variant})
				break

	return violations


# "locked" / "available" / "in_progress" / "completed"
static func status_for(save_data: Dictionary, cup: Dictionary) -> String:
	if not is_unlocked(save_data, cup):
		return "locked"
	var challenge := active_challenge(save_data)
	if not challenge.is_empty() and str(challenge.get("cup_id", "")) == str(cup.get("id", "")):
		return "in_progress"
	if progress_for(save_data, str(cup.get("id", ""))).get("completed", false):
		return "completed"
	return "available"


static func active_challenge(save_data: Dictionary) -> Dictionary:
	var challenge = save_data.get("cup_challenge", {})
	if typeof(challenge) != TYPE_DICTIONARY or not bool(challenge.get("active", false)):
		return {}
	return challenge


static func challenge_for(cup_id: String, round_index: int = 0, team_index: int = 0) -> Dictionary:
	return {
		"active": true,
		"cup_id": cup_id,
		"round_index": round_index,
		"team_index": team_index,
	}


# Builds the enemy-encounter Pokemon dict for the challenge's current
# round/team position - the same shape GymData.opponent_encounter builds,
# stamped with trainer_battle=true so every existing trainer-battle rule
# (no capture, no running, the 1.5x trainer-XP bonus) applies for free.
static func current_encounter(save_data: Dictionary) -> Dictionary:
	var challenge := active_challenge(save_data)
	if challenge.is_empty():
		return {}
	var cup := cup_for_id(str(challenge.get("cup_id", "")))
	var round_index := int(challenge.get("round_index", 0))
	var team_index := int(challenge.get("team_index", 0))
	return _encounter_for(cup, round_index, team_index)


static func _encounter_for(cup: Dictionary, round_index: int, team_index: int) -> Dictionary:
	if cup.is_empty():
		return {}
	var round_data := round_for_index(cup, round_index)
	if round_data.is_empty():
		return {}
	var trainer := trainer_for_id(str(round_data.get("trainer_id", "")))
	if trainer.is_empty():
		return {}
	var team = trainer.get("team", [])
	if typeof(team) != TYPE_ARRAY or team_index < 0 or team_index >= team.size():
		return {}
	var slot = team[team_index]
	if typeof(slot) != TYPE_DICTIONARY:
		return {}

	var pokemon_id := str(slot.get("species", PokemonHelpers.DEFAULT_STARTER_ID))
	var level := maxi(1, int(slot.get("level", 5)))
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
	pokemon["capture_rate"] = 0
	pokemon["catch_rate"] = 0

	var variant = slot.get("variant", {})
	if typeof(variant) == TYPE_DICTIONARY:
		if bool(variant.get("shiny", false)):
			pokemon["shiny"] = true
		if bool(variant.get("black", false)):
			pokemon["black"] = true
		if str(variant.get("form", "")) != "":
			pokemon["form"] = str(variant["form"])
	if str(slot.get("held_item", "")) != "":
		pokemon["held_item"] = str(slot["held_item"])
	if str(slot.get("nature", "")) != "":
		pokemon["nature"] = str(slot["nature"])

	pokemon["trainer_battle"] = true
	pokemon["trainer_name"] = str(trainer.get("name", "Trainer"))
	pokemon["trainer_role"] = "cup"
	pokemon["cup_battle"] = true
	pokemon["cup_id"] = str(cup.get("id", ""))
	pokemon["cup_round_index"] = round_index
	pokemon["cup_team_index"] = team_index
	pokemon["cup_trainer_id"] = str(trainer.get("id", ""))

	return PokemonHelpers.normalize_pokemon(pokemon, pokemon_id)


static func trainer_team_size(cup: Dictionary, round_index: int) -> int:
	var round_data := round_for_index(cup, round_index)
	var trainer := trainer_for_id(str(round_data.get("trainer_id", "")))
	var team = trainer.get("team", [])
	return team.size() if typeof(team) == TYPE_ARRAY else 0


# Heal modes: "full" (restore HP/PP/status), "partial" (50% HP restore, PP/
# status untouched), "none". Applied only at round transitions, never
# between one trainer's own team members (see file header).
static func _healed_team(team: Array, mode: String) -> Array:
	var healed := team.duplicate(true)
	for i in range(healed.size()):
		if typeof(healed[i]) != TYPE_DICTIONARY:
			continue
		var pokemon: Dictionary = healed[i]
		var max_hp := maxi(1, int(pokemon.get("max_hp", 1)))
		match mode:
			"full":
				pokemon["hp"] = max_hp
				pokemon["status_condition"] = null
				pokemon["pp_current"] = pokemon.get("pp_max", []).duplicate(true)
				pokemon["healing"] = false
				pokemon["healing_finish_timestamp"] = 0
			"partial":
				pokemon["hp"] = clampi(int(pokemon.get("hp", max_hp)) + int(max_hp * 0.5), 0, max_hp)
			_:
				pass
		healed[i] = PokemonHelpers.normalize_pokemon(pokemon, str(pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	return healed


# What happens after the player's current opponent Pokemon faints: next
# team member of the same trainer, next round's trainer (with the cup's
# heal_between_rounds rule + that round's rewards applied), or the cup is
# won outright (final round + rewards + badge, first-completion vs. repeat
# rewards, cups_completed/badge bookkeeping).
static func next_victory_state(save_data: Dictionary) -> Dictionary:
	var challenge := active_challenge(save_data)
	if challenge.is_empty():
		return {}
	var cup_id := str(challenge.get("cup_id", ""))
	var cup := cup_for_id(cup_id)
	if cup.is_empty():
		return {}

	var round_index := int(challenge.get("round_index", 0))
	var team_index := int(challenge.get("team_index", 0))
	var round_data := round_for_index(cup, round_index)
	var team_size := trainer_team_size(cup, round_index)
	var next_team_index := team_index + 1

	if next_team_index < team_size:
		return {
			"result": "next_team_member",
			"changes": {
				"cup_challenge": challenge_for(cup_id, round_index, next_team_index),
			},
		}

	var round_rewards = round_data.get("rewards", {})
	var money_gain := int(round_rewards.get("money", 0)) if typeof(round_rewards) == TYPE_DICTIONARY else 0
	var xp_gain := int(round_rewards.get("xp", 0)) if typeof(round_rewards) == TYPE_DICTIONARY else 0
	var item_gains = round_rewards.get("items", {}) if typeof(round_rewards) == TYPE_DICTIONARY else {}

	var next_round_index := round_index + 1
	var total_rounds := round_count(cup)

	if next_round_index < total_rounds:
		var heal_mode := str(cup.get("heal_between_rounds", "full"))
		var healed_team := _healed_team(_array_from(save_data.get("team", [])), heal_mode)
		return {
			"result": "next_round",
			"money_gain": money_gain,
			"xp_gain": xp_gain,
			"item_gains": item_gains,
			"changes": {
				"cup_challenge": challenge_for(cup_id, next_round_index, 0),
				"team": healed_team,
				"money": int(save_data.get("money", 0)) + money_gain,
			},
		}

	# Final round won - the cup is complete.
	var progress := progress_for(save_data, cup_id)
	var already_completed: bool = progress.get("completed", false)
	var completion_rewards = cup.get("repeat_rewards", {}) if already_completed else cup.get("first_completion_rewards", {})
	var completion_money := int(completion_rewards.get("money", 0)) if typeof(completion_rewards) == TYPE_DICTIONARY else 0
	var completion_xp := int(completion_rewards.get("xp", 0)) if typeof(completion_rewards) == TYPE_DICTIONARY else 0
	var completion_items = completion_rewards.get("items", {}) if typeof(completion_rewards) == TYPE_DICTIONARY else {}

	var merged_items: Dictionary = {}
	if typeof(item_gains) == TYPE_DICTIONARY:
		for k in item_gains.keys():
			merged_items[k] = int(merged_items.get(k, 0)) + int(item_gains[k])
	if typeof(completion_items) == TYPE_DICTIONARY:
		for k in completion_items.keys():
			merged_items[k] = int(merged_items.get(k, 0)) + int(completion_items[k])

	var cups_progress: Dictionary = save_data.get("cups", {}).duplicate(true) if typeof(save_data.get("cups", {})) == TYPE_DICTIONARY else {}
	cups_progress[cup_id] = {
		"participated": true,
		"completed": true,
		"won": true,
		"completed_count": int(progress.get("completed_count", 0)) + 1,
	}

	var badge_name := str(cup.get("badge_name_pt", cup.get("badge_name_en", "Cup Badge")))
	var cup_badges := _string_array(save_data.get("cup_badges_obtained", []))
	if not already_completed and not cup_badges.has(badge_name):
		cup_badges.append(badge_name)

	return {
		"result": "cup_completed",
		"already_completed": already_completed,
		"money_gain": money_gain + completion_money,
		"xp_gain": xp_gain + completion_xp,
		"item_gains": merged_items,
		"badge_name": badge_name,
		"changes": {
			"cup_challenge": {},
			"cups": cups_progress,
			"cup_badges_obtained": cup_badges,
			"money": int(save_data.get("money", 0)) + money_gain + completion_money,
		},
	}


# The player's whole team fainted mid-cup: the run ends (eliminated), no
# round/completion rewards, cup goes back to "available" so it can be
# retried, but "participated" is recorded (for participate_tournament-style
# evolution conditions - see PokemonHelpers.PLAYER_PROGRESS_METHODS).
static func defeat_state(save_data: Dictionary) -> Dictionary:
	var challenge := active_challenge(save_data)
	if challenge.is_empty():
		return {}
	var cup_id := str(challenge.get("cup_id", ""))
	var cups_progress: Dictionary = save_data.get("cups", {}).duplicate(true) if typeof(save_data.get("cups", {})) == TYPE_DICTIONARY else {}
	var progress := progress_for(save_data, cup_id)
	cups_progress[cup_id] = {
		"participated": true,
		"completed": progress.get("completed", false),
		"won": progress.get("won", false),
		"completed_count": int(progress.get("completed_count", 0)),
	}
	return {
		"changes": {
			"cup_challenge": {},
			"cups": cups_progress,
		},
	}


static func _array_from(value) -> Array:
	return value if typeof(value) == TYPE_ARRAY else []


static func _string_array(value) -> Array:
	var result := []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		var text := str(entry)
		if text != "" and not result.has(text):
			result.append(text)
	return result
