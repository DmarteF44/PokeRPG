extends Node

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
	# specialization_allocations isn't part of create_save()'s own field
	# list (same as the Pokedex variant lists) - set it the way real
	# gameplay does, via update_current_save.
	SaveManager.update_current_save({"specialization_allocations": {"treinamento": 5}})

	var battle_scene = load("res://scenes/BattleScene.tscn").instantiate()
	get_tree().root.add_child.call_deferred(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	# --- The victory message must show the REAL amount, which varies with
	# the "treinamento" specialization (5 points -> +10%), not a hardcoded
	# "25".
	var expected_amount := int(round(25 * (1.0 + 5 * 0.02)))
	_check("treinamento specialization actually raises the participation XP above the base 25",
		expected_amount > 25, expected_amount)
	var xp_lines: Array = battle_scene._grant_player_pokemon_xp(battle_scene._participation_xp_amount())
	var first_line := str(xp_lines[0])
	_check("the XP-gain message shows the real amount, not a hardcoded '25'",
		first_line.find(str(expected_amount)) != -1 and first_line.find("25 XP") == -1,
		first_line)

	# --- Trainer XP gained must be shown even when no trainer level-up
	# happens (previously nothing was shown at all in that case).
	var trainer_xp_result := {"xp_gained": 7, "level_ups": []}
	var trainer_lines: Array = battle_scene._trainer_xp_lines(trainer_xp_result)
	_check("trainer XP gained is shown even without a level-up",
		not trainer_lines.is_empty() and str(trainer_lines[0]).find("7") != -1, trainer_lines)

	# --- Capturing a wild Pokemon must grant participation XP to the
	# player's own active Pokemon, exactly like defeating it does - and
	# that gain must actually reach the persisted save, not just the
	# in-memory player_pokemon.
	var before_xp := int(battle_scene.player_pokemon.get("xp", 0))
	battle_scene.enemy_pokemon = PokemonHelpers.normalize_pokemon({
		"id": "rattata", "level": 3, "hp": 1, "max_hp": 20, "catch_rate": 255,
	})
	# Replicates the exact sequence _use_capture_item now performs on a
	# successful catch: grant participation XP, sync battle_team (since
	# _capture_enemy()'s own snapshot reads from battle_team, not the loose
	# player_pokemon var), then capture.
	battle_scene._grant_player_pokemon_xp(battle_scene._participation_xp_amount())
	battle_scene.battle_team[battle_scene.player_team_index] = battle_scene._battle_pokemon_copy(battle_scene.player_pokemon)
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
