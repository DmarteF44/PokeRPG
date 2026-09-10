extends Node
# Regression suite for evolution: no duplication in any code path, and
# every identity/rarity field that isn't species-derived (level, xp,
# nature, gender, shiny/alpha/lucky/purified, held_item, nickname) must
# survive the transformation. See scripts/pokemon_helpers.gd:evolve_pokemon
# and grant_xp.

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

var failures := []
var passes := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame

	var source: Dictionary = PokemonHelpers.normalize_pokemon({
		"id": "charmander", "level": 16, "xp": 5, "nature": "Jolly", "gender": "Female",
		"shiny": true, "alpha": true, "lucky": true, "purified": true,
		"held_item": "charcoal", "nickname": "Sparky", "hp": 20, "max_hp": 39,
	})
	var evolved: Dictionary = PokemonHelpers.evolve_pokemon(source, "charmeleon")

	_check("species/id updates to the evolution target", str(evolved.get("id", "")) == "charmeleon", evolved.get("id"))
	var expected_target_types: Array = PokemonHelpers.normalize_pokemon({"id": "charmeleon"}).get("types", [])
	_check("types update to the evolution target's own real types",
		evolved.get("types", []) == expected_target_types, evolved.get("types"))
	_check("level is preserved across evolution", int(evolved.get("level", -1)) == 16, evolved.get("level"))
	_check("xp is preserved across evolution", int(evolved.get("xp", -1)) == 5, evolved.get("xp"))
	_check("nature is preserved across evolution", str(evolved.get("nature", "")) == "Jolly", evolved.get("nature"))
	_check("gender is preserved across evolution", str(evolved.get("gender", "")) == "Female", evolved.get("gender"))
	_check("shiny/alpha/lucky/purified all survive together",
		bool(evolved.get("shiny", false)) and bool(evolved.get("alpha", false)) and bool(evolved.get("lucky", false)) and bool(evolved.get("purified", false)),
		[evolved.get("shiny"), evolved.get("alpha"), evolved.get("lucky"), evolved.get("purified")])
	_check("held_item is preserved across evolution", str(evolved.get("held_item", "")) == "charcoal", evolved.get("held_item"))
	_check("nickname is preserved across evolution", str(evolved.get("nickname", "")) == "Sparky", evolved.get("nickname"))
	var missing_before := 39 - 20
	var missing_after := int(evolved.get("max_hp", 0)) - int(evolved.get("hp", 0))
	_check("absolute missing HP (damage already taken) is preserved across evolution, not the ratio",
		missing_after == missing_before, [missing_before, missing_after])

	# Team-array integration: leveling into an evolution must replace the
	# evolving slot in place - team size never changes, other slots
	# untouched.
	var untouched: Dictionary = PokemonHelpers.normalize_pokemon({"id": "squirtle", "level": 12, "nickname": "Shelly"})
	var evolving: Dictionary = PokemonHelpers.normalize_pokemon({"id": "charmander", "level": 15, "shiny": true})
	var team: Array = [evolving.duplicate(true), untouched.duplicate(true)]
	var xp_result := PokemonHelpers.grant_xp(team[0], 500, {})
	team[0] = xp_result.get("pokemon", team[0])
	_check("team size is unchanged after a level-up evolution (no duplicate slot appended)", team.size() == 2, team.size())
	_check("untouched teammate is completely unaffected", str(team[1].get("id", "")) == "squirtle" and int(team[1].get("level", -1)) == 12, team[1])

	# Multi-stage: Charmander -> Charmeleon -> Charizard in one grant_xp call.
	var multi: Dictionary = PokemonHelpers.normalize_pokemon({"id": "charmander", "level": 1, "shiny": true})
	var multi_result := PokemonHelpers.grant_xp(multi, 200000, {})
	var final_form: Dictionary = multi_result.get("pokemon", multi)
	_check("a big XP grant evolves through both stages to Charizard, not stuck at Charmeleon",
		str(final_form.get("id", "")) == "charizard", final_form.get("id"))
	_check("shiny survives two chained evolutions in one grant_xp call", bool(final_form.get("shiny", false)), final_form.get("shiny"))
	var evo_log: Array = multi_result.get("evolutions", [])
	_check("both evolution steps are individually reported, not collapsed into one", evo_log.size() == 2, evo_log.size())

	print("\n=== EVOLUTION TEST: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("FAIL: " + f)
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check(label: String, condition: bool, detail) -> void:
	if condition:
		passes += 1
	else:
		failures.append("%s (got: %s)" % [label, str(detail)])
		print("FAIL: %s (got: %s)" % [label, str(detail)])
