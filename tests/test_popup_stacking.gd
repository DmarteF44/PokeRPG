extends Node
# Regression suite for the "queue_free() without remove_child()" popup/
# panel-stacking bug class: queue_free() doesn't detach a node until end
# of frame, so any show-popup function that can be re-entered before that
# (a fast double-tap) needs remove_child() first or the stale popup stacks
# under the fresh one. Several instances of this were found and fixed
# across the app - this suite pins down the highest-traffic ones so a
# future edit can't silently reintroduce it.

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

var failures := []
var passes := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	SaveManager.create_save(1, {
		"player_name": "Tester", "money": 5000,
		"team": [PokemonHelpers.normalize_pokemon({"id": "charizard", "level": 30})],
	})

	var home = load("res://scenes/HomeScreen.tscn").instantiate()
	get_tree().root.add_child.call_deferred(home)
	await get_tree().process_frame
	await get_tree().process_frame

	home._show_tournament()
	home._show_tournament()
	await get_tree().process_frame
	_check_single_child(home, "TournamentPopup", "double-tapping the trophy icon")

	home._show_world_map()
	home._show_world_map()
	await get_tree().process_frame
	_check_single_child(home, "WorldMapPopup", "double-tapping the World Map icon")

	home._show_debug_menu()
	home._show_debug_menu()
	await get_tree().process_frame
	_check_single_child(home, "DebugPopup", "rapid re-invocation of the debug menu")

	home._show_specialization()
	home._show_specialization()
	await get_tree().process_frame
	_check_single_child(home, "SpecializationPopup", "double-tapping the specialization screen")

	var battle_scene = load("res://scenes/BattleScene.tscn").instantiate()
	get_tree().root.add_child.call_deferred(battle_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	battle_scene._show_bag()
	battle_scene._show_pokemon()
	await get_tree().process_frame
	var stale_bag: Node = battle_scene.get_node_or_null("BagPanel")
	var live_pokemon_panel: Node = battle_scene.get_node_or_null("PokemonPanel")
	_check("switching Bag -> Pokemon leaves no stale BagPanel stacked underneath", stale_bag == null, stale_bag)
	_check("switching Bag -> Pokemon leaves the new PokemonPanel present", live_pokemon_panel != null, live_pokemon_panel)

	var main_menu = load("res://scenes/MainMenu.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main_menu)
	await get_tree().process_frame
	await get_tree().process_frame

	main_menu._show_load_game()
	main_menu._show_load_game()
	await get_tree().process_frame
	_check_single_child(main_menu, "Popup", "double-tapping Load Game")

	main_menu._show_new_game()
	await get_tree().process_frame
	main_menu.selected_generation = 1
	main_menu._refresh_starter_buttons()
	main_menu.selected_generation = 2
	main_menu._refresh_starter_buttons()
	await get_tree().process_frame
	var child_names := []
	for child in main_menu.new_game_content.get_children():
		child_names.append(str(child.name))
	_check("switching starter generation removes the previous generation's buttons",
		not (child_names.has("Bulbasaur") or child_names.has("Charmander") or child_names.has("Squirtle")), child_names)

	print("\n=== POPUP STACKING TEST: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("FAIL: " + f)
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check_single_child(parent: Node, child_name: String, label: String) -> void:
	var count := 0
	for child in parent.get_children():
		if child.name == child_name:
			count += 1
	_check("%s leaves exactly one %s" % [label, child_name], count == 1, count)


func _check(label: String, condition: bool, detail) -> void:
	if condition:
		passes += 1
	else:
		failures.append("%s (got: %s)" % [label, str(detail)])
		print("FAIL: %s (got: %s)" % [label, str(detail)])
