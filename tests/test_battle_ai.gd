extends Node
# Regression suite for the per-strategy battle AI (battle_scene.gd:
# _enemy_ai_strategy/_choose_enemy_move_index/_score_enemy_move) and its
# wiring from cup_trainers.json through CupManager into the battle scene.

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")
const CupManager = preload("res://scripts/cup_manager.gd")

var failures := []
var passes := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame

	SaveManager.create_save(1, {"player_name": "Tester"})
	var battle_scene = load("res://scenes/BattleScene.tscn").instantiate()
	get_tree().root.add_child.call_deferred(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	var tackle: Dictionary = PokemonHelpers.move_by_name("Tackle")
	var harden: Dictionary = PokemonHelpers.move_by_name("Harden")
	var moves := [tackle, harden]
	battle_scene.player_pokemon = {"name": "Player", "hp": 60, "max_hp": 60, "level": 20, "attack": 30, "defense": 30, "sp_attack": 30, "sp_defense": 30, "speed": 30, "types": ["Normal"]}
	battle_scene.player_stat_stages = {}
	battle_scene.enemy_stat_stages = {}

	battle_scene.enemy_pokemon = {"name": "Def", "hp": 15, "max_hp": 60, "level": 20, "attack": 20, "defense": 20, "sp_attack": 20, "sp_defense": 20, "speed": 20, "types": ["Normal"], "ai_strategy": "defensive"}
	_check("defensive prefers a status move (Harden) at low HP over a weak attack",
		battle_scene._choose_enemy_move_index([0, 1], moves) == 1, battle_scene._choose_enemy_move_index([0, 1], moves))

	battle_scene.enemy_pokemon = {"name": "Off", "hp": 15, "max_hp": 60, "level": 20, "attack": 20, "defense": 20, "sp_attack": 20, "sp_defense": 20, "speed": 20, "types": ["Normal"], "ai_strategy": "offensive"}
	_check("offensive prefers the attack even at low HP",
		battle_scene._choose_enemy_move_index([0, 1], moves) == 0, battle_scene._choose_enemy_move_index([0, 1], moves))

	battle_scene.player_pokemon["hp"] = 5
	for strategy in ["balanced", "defensive", "offensive", "champion"]:
		battle_scene.enemy_pokemon = {"name": "Finisher", "hp": 60, "max_hp": 60, "level": 20, "attack": 30, "defense": 20, "sp_attack": 20, "sp_defense": 20, "speed": 20, "types": ["Normal"], "ai_strategy": strategy}
		_check("%s takes a lethal finishing blow when available" % strategy,
			battle_scene._choose_enemy_move_index([0, 1], moves) == 0, strategy)
	battle_scene.player_pokemon["hp"] = 60

	battle_scene.enemy_pokemon = {"ai_strategy": "type_specialist"}
	_check("type_specialist maps to the offensive scoring curve", battle_scene._enemy_ai_strategy() == "offensive", battle_scene._enemy_ai_strategy())
	battle_scene.enemy_pokemon = {"ai_strategy": "", "trainer_battle": true, "trainer_role": "leader"}
	_check("an undeclared gym leader infers defensive", battle_scene._enemy_ai_strategy() == "defensive", battle_scene._enemy_ai_strategy())
	battle_scene.enemy_pokemon = {"ai_strategy": ""}
	_check("an undeclared non-leader defaults to balanced", battle_scene._enemy_ai_strategy() == "balanced", battle_scene._enemy_ai_strategy())

	battle_scene.enemy_pokemon = {"ai_strategy": "offensive"}
	_check("only the PP-available move can be chosen", battle_scene._choose_enemy_move_index([1], moves) == 1, battle_scene._choose_enemy_move_index([1], moves))

	# End-to-end wiring: CupManager stamps the trainer's declared strategy,
	# and the enemy-normalize whitelist preserves it through a scene reload.
	var synthetic_cup := {"id": "test_cup", "rounds": [{"trainer_id": "cup_specialist_kai"}]}
	var built := CupManager._encounter_for(synthetic_cup, 0, 0)
	_check("CupManager stamps ai_strategy from the trainer onto the encounter",
		str(built.get("ai_strategy", "")) == "type_specialist", built.get("ai_strategy"))
	var normalized: Dictionary = battle_scene._normalize_enemy_pokemon(built)
	_check("_normalize_enemy_pokemon whitelist preserves ai_strategy",
		str(normalized.get("ai_strategy", "")) == "type_specialist", normalized.get("ai_strategy"))

	print("\n=== BATTLE AI TEST: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("FAIL: " + f)
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check(label: String, condition: bool, detail) -> void:
	if condition:
		passes += 1
	else:
		failures.append("%s (got: %s)" % [label, str(detail)])
		print("FAIL: %s (got: %s)" % [label, str(detail)])
