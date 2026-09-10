extends Node
# Regression suite for the XP message text and the capture-XP fix.
# See test_encounter_xp_split.gd for the total-XP formula and multi-
# participant split themselves - this file covers the surrounding wiring:
# the message text is never a hardcoded literal amount, trainer XP is
# shown even without a level-up, and a capture's XP gain actually reaches
# the persisted save (not just the in-memory Pokemon).

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

var failures := []
var passes := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame

	SaveManager.create_save(1, {
		"player_name": "Tester",
		"team": [PokemonHelpers.normalize_pokemon({"id": "charmander", "level": 5, "xp": 0})],
	})

	var battle_scene = load("res://scenes/BattleScene.tscn").instantiate()
	get_tree().root.add_child.call_deferred(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	# --- The XP-gain message must never be a hardcoded literal amount
	# (the old "%s gained 25 XP!" bug) - it has to reflect whatever
	# _total_encounter_xp() actually computed for this specific encounter.
	battle_scene.enemy_pokemon = {"xp_yield": 140, "level": 20, "trainer_battle": false}
	battle_scene.player_team_index = 0
	battle_scene.battle_participants = {0: 10.0}
	var expected_amount: int = battle_scene._total_encounter_xp()
	var xp_lines: Array = battle_scene._grant_encounter_xp()
	var first_line := str(xp_lines[0])
	_check("the XP-gain message shows the real computed amount",
		first_line.find(str(expected_amount)) != -1, [first_line, expected_amount])
	_check("the XP-gain message is never the old hardcoded '25 XP' literal",
		first_line.find("gained 25 XP") == -1, first_line)

	# --- Trainer XP gained must be shown even when no trainer level-up
	# happens (previously nothing was shown at all in that case).
	var trainer_xp_result := {"xp_gained": 7, "level_ups": []}
	var trainer_lines: Array = battle_scene._trainer_xp_lines(trainer_xp_result)
	_check("trainer XP gained is shown even without a level-up",
		not trainer_lines.is_empty() and str(trainer_lines[0]).find("7") != -1, trainer_lines)

	# --- Capturing a wild Pokemon must grant participation XP to the
	# player's own active Pokemon (via the same _grant_encounter_xp path
	# _use_capture_item now calls before _capture_enemy() runs), and that
	# gain must actually reach the persisted save, not just the in-memory
	# player_pokemon.
	var before_xp := int(battle_scene.player_pokemon.get("xp", 0))
	battle_scene.enemy_pokemon = PokemonHelpers.normalize_pokemon({
		"id": "rattata", "level": 3, "hp": 1, "max_hp": 20, "catch_rate": 255,
	})
	battle_scene.battle_participants = {0: 5.0}
	battle_scene._grant_encounter_xp()
	battle_scene._capture_enemy()
	var saved := SaveManager.get_current_save()
	var saved_team: Array = saved.get("team", [])
	_check("post-capture persisted save reflects the XP gain on the active Pokemon",
		saved_team.size() > 0 and int(saved_team[0].get("xp", -1)) > before_xp, [before_xp, saved_team[0].get("xp", -1) if saved_team.size() > 0 else "no team"])

	print("\n=== XP DISPLAY / CAPTURE XP TEST: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("FAIL: " + f)
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check(label: String, condition: bool, detail) -> void:
	if condition:
		passes += 1
	else:
		failures.append("%s (got: %s)" % [label, str(detail)])
		print("FAIL: %s (got: %s)" % [label, str(detail)])
