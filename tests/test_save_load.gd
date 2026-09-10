extends Node
# Regression suite for SaveManager: every field must survive an actual
# JSON-file round-trip (not just the in-memory cache), slots must stay
# isolated from each other, and load_save must be idempotent.

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

var failures := []
var passes := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame

	if SaveManager.has_save(1):
		SaveManager.delete_save(1)
	if SaveManager.has_save(2):
		SaveManager.delete_save(2)

	var team := [
		PokemonHelpers.normalize_pokemon({
			"id": "charizard", "level": 42, "xp": 1234, "nature": "Adamant", "shiny": true,
			"held_item": "charizardite_x", "nickname": "Blaze",
			"moves": [PokemonHelpers.move_by_name("Flamethrower"), PokemonHelpers.move_by_name("Dragon Claw")],
		}),
		PokemonHelpers.normalize_pokemon({"id": "gengar", "level": 30, "black": true, "alpha": true}),
	]
	SaveManager.create_save(1, {
		"player_name": "IntegrityTester", "money": 54321, "badges": 5, "team": team,
		"inventory": {"poke_ball": 12, "flame_plate": 1},
		"badges_obtained": ["boulder_badge", "cascade_badge"],
		"cups": {"kanto_cup": {"participated": true, "completed": true, "won": true, "completed_count": 1}},
	})
	SaveManager.update_current_save({"seen_shiny_pokemon": ["charizard"], "owned_black_pokemon": ["gengar"]})

	# The real integrity test: re-parse from disk, not the in-memory cache.
	var reloaded := SaveManager.get_save(1)
	_check("reloaded save is not empty", not reloaded.is_empty(), reloaded)
	_check("player_name/money/badges survive the JSON round-trip",
		str(reloaded.get("player_name", "")) == "IntegrityTester" and int(reloaded.get("money", -1)) == 54321 and int(reloaded.get("badges", -1)) == 5,
		reloaded)

	var reloaded_team: Array = reloaded.get("team", [])
	_check("team size survives round-trip (2 members)", reloaded_team.size() == 2, reloaded_team.size())
	if reloaded_team.size() == 2:
		var mon0: Dictionary = reloaded_team[0]
		_check("team[0] level/xp/shiny/nickname/held_item survive round-trip",
			int(mon0.get("level", -1)) == 42 and int(mon0.get("xp", -1)) == 1234 and bool(mon0.get("shiny", false))
			and str(mon0.get("nickname", "")) == "Blaze" and str(mon0.get("held_item", "")) == "charizardite_x",
			mon0)
		var move_names := []
		for m in mon0.get("moves", []):
			move_names.append(str(m.get("name", "")))
		_check("team[0] explicit moves survive round-trip", move_names.has("Flamethrower") and move_names.has("Dragon Claw"), move_names)
		var mon1: Dictionary = reloaded_team[1]
		_check("team[1] black/alpha flags survive round-trip (no cross-slot contamination)",
			bool(mon1.get("black", false)) and bool(mon1.get("alpha", false)), mon1)

	var reloaded_cups = reloaded.get("cups", {})
	_check("nested cups progress dict survives round-trip", bool(reloaded_cups.get("kanto_cup", {}).get("won", false)), reloaded_cups)
	var reloaded_seen: Array = reloaded.get("seen_shiny_pokemon", [])
	_check("variant Pokedex list survives round-trip", reloaded_seen.has("charizard"), reloaded_seen)

	# Multi-slot isolation.
	SaveManager.create_save(2, {"player_name": "OtherSlot", "money": 999})
	var slot1_after := SaveManager.get_save(1)
	_check("slot 1 untouched after creating slot 2", str(slot1_after.get("player_name", "")) == "IntegrityTester", slot1_after.get("player_name"))
	_check("slot 2 has independent data", str(SaveManager.get_save(2).get("player_name", "")) == "OtherSlot", SaveManager.get_save(2).get("player_name"))

	# load_save idempotency.
	var first := SaveManager.load_save(1)
	var second := SaveManager.load_save(1)
	_check("loading the same save twice yields identical team data", first.get("team", []).size() == second.get("team", []).size(), [first.get("team", []).size(), second.get("team", []).size()])

	SaveManager.delete_save(2)
	_check("has_save(2) false after delete", not SaveManager.has_save(2), SaveManager.has_save(2))
	_check("slot 1 untouched by deleting slot 2", SaveManager.has_save(1), SaveManager.has_save(1))
	SaveManager.delete_save(1)

	print("\n=== SAVE/LOAD TEST: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("FAIL: " + f)
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check(label: String, condition: bool, detail) -> void:
	if condition:
		passes += 1
	else:
		failures.append("%s (got: %s)" % [label, str(detail)])
		print("FAIL: %s (got: %s)" % [label, str(detail)])
