extends Node
# Regression suite for the encounter-XP system: total XP depends on the
# defeated/caught Pokemon's own species and level (not a flat amount), and
# it's split across every team member that actually fought in the
# encounter, proportional to damage dealt - not just whichever Pokemon is
# active when the battle ends. See battle_scene.gd's
# _total_encounter_xp/_grant_encounter_xp/_grant_xp_to_team_slot.

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

var failures := []
var passes := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame

	SaveManager.create_save(1, {
		"player_name": "Tester",
		"team": [
			PokemonHelpers.normalize_pokemon({"id": "charmander", "level": 10, "xp": 0}),
			PokemonHelpers.normalize_pokemon({"id": "squirtle", "level": 10, "xp": 0}),
		],
	})

	var battle_scene = load("res://scenes/BattleScene.tscn").instantiate()
	get_tree().root.add_child.call_deferred(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	# --- Total XP depends on the enemy's own species/level, not a flat
	# amount - a higher xp_yield or higher level opponent is worth more.
	battle_scene.enemy_pokemon = {"xp_yield": 64, "level": 10, "trainer_battle": false}
	var low_value: int = battle_scene._total_encounter_xp()
	battle_scene.enemy_pokemon = {"xp_yield": 64, "level": 50, "trainer_battle": false}
	var high_level_value: int = battle_scene._total_encounter_xp()
	battle_scene.enemy_pokemon = {"xp_yield": 300, "level": 10, "trainer_battle": false}
	var high_yield_value: int = battle_scene._total_encounter_xp()
	_check("a higher-level opponent is worth more total XP", high_level_value > low_value, [low_value, high_level_value])
	_check("a higher xp_yield species is worth more total XP", high_yield_value > low_value, [low_value, high_yield_value])
	battle_scene.enemy_pokemon = {"xp_yield": 64, "level": 10, "trainer_battle": true}
	var trainer_value: int = battle_scene._total_encounter_xp()
	_check("a trainer battle is worth more than an identical wild encounter", trainer_value > low_value, [low_value, trainer_value])

	# --- Splitting: two Pokemon fought (team 0 dealt more damage than team
	# 1, simulating "one fainted/was swapped out, the other finished it")
	# - both must receive XP, proportional to their share, not an even
	# split and not all-or-nothing.
	battle_scene.enemy_pokemon = {"xp_yield": 200, "level": 20, "trainer_battle": false}
	battle_scene.player_team_index = 1
	battle_scene.battle_participants = {0: 30.0, 1: 10.0}
	var before_xp_0 := int(battle_scene.battle_team[0].get("xp", 0))
	var before_xp_1 := int(battle_scene.battle_team[1].get("xp", 0))
	var total_before_split: int = battle_scene._total_encounter_xp()
	battle_scene._grant_encounter_xp()
	var after_xp_0 := int(battle_scene.battle_team[0].get("xp", 0))
	var after_xp_1 := int(battle_scene.battle_team[1].get("xp", 0))
	var gained_0 := after_xp_0 - before_xp_0
	var gained_1 := after_xp_1 - before_xp_1
	_check("both participants that dealt damage receive some XP", gained_0 > 0 and gained_1 > 0, [gained_0, gained_1])
	_check("the participant that dealt more damage (30 vs 10) receives more XP",
		gained_0 > gained_1, [gained_0, gained_1])
	_check("the two shares add up to (approximately) the total encounter XP - nothing lost or invented",
		absi(gained_0 + gained_1 - total_before_split) <= 1, [gained_0, gained_1, total_before_split])

	# --- A team member that never dealt any damage this encounter gets
	# nothing, even if it's on the team.
	battle_scene.enemy_pokemon = {"xp_yield": 64, "level": 10, "trainer_battle": false}
	battle_scene.player_team_index = 0
	battle_scene.battle_participants = {0: 15.0}
	var before_bench_xp := int(battle_scene.battle_team[1].get("xp", 0))
	battle_scene._grant_encounter_xp()
	var after_bench_xp := int(battle_scene.battle_team[1].get("xp", 0))
	_check("a team member with zero tracked participation this encounter gains no XP",
		after_bench_xp == before_bench_xp, [before_bench_xp, after_bench_xp])

	# --- Fallback: no damage tracked at all (e.g. first-turn Master Ball
	# catch) grants the full amount to the active Pokemon alone, not zero.
	battle_scene.battle_participants = {}
	battle_scene.player_team_index = 0
	var before_fallback_xp := int(battle_scene.battle_team[0].get("xp", 0))
	var fallback_total: int = battle_scene._total_encounter_xp()
	battle_scene._grant_encounter_xp()
	var after_fallback_xp := int(battle_scene.battle_team[0].get("xp", 0))
	_check("with no tracked damage, the active Pokemon still gets the full encounter XP (not zero)",
		after_fallback_xp - before_fallback_xp == fallback_total, [before_fallback_xp, after_fallback_xp, fallback_total])

	# --- Move-learn resolution must target the Pokemon that actually
	# leveled up, not whichever one is currently active - a benched
	# participant's move-learn choice must never get written into the
	# active Pokemon's moveset.
	battle_scene.player_team_index = 0
	battle_scene.player_pokemon = battle_scene.battle_team[0]
	var active_moves_before: Array = battle_scene.player_pokemon.get("moves", []).duplicate(true)
	var bench_mon: Dictionary = battle_scene.battle_team[1].duplicate(true)
	bench_mon["moves"] = [PokemonHelpers.move_by_name("Tackle"), PokemonHelpers.move_by_name("Growl")]
	battle_scene.battle_team[1] = bench_mon
	var new_move := PokemonHelpers.move_by_name("Water Gun")
	battle_scene._resolve_move_learn(Control.new(), 0, new_move, 1)
	var active_moves_after: Array = battle_scene.player_pokemon.get("moves", [])
	var bench_moves_after: Array = battle_scene.battle_team[1].get("moves", [])
	_check("the active Pokemon's moveset is untouched by a benched Pokemon's move-learn resolution",
		active_moves_after.size() == active_moves_before.size() and str(active_moves_after[0].get("name", "")) == str(active_moves_before[0].get("name", "")),
		[active_moves_before, active_moves_after])
	_check("the benched Pokemon actually learned the move at the resolved slot",
		str(bench_moves_after[0].get("name", "")) == "Water Gun", bench_moves_after)

	print("\n=== ENCOUNTER XP SPLIT TEST: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("FAIL: " + f)
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check(label: String, condition: bool, detail) -> void:
	if condition:
		passes += 1
	else:
		failures.append("%s (got: %s)" % [label, str(detail)])
		print("FAIL: %s (got: %s)" % [label, str(detail)])
