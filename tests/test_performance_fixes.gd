extends Node
# Regression suite for the "sprites feel slow / screens stutter" fixes:
# - _textures_from_folder now caches per folder, instead of re-probing up
#   to MAX_FRAMES files from disk on every single call.
# - Storage screens (which can hold up to 500 Pokemon) now build their
#   rows in yielding batches like the Pokedex already did, instead of
#   blocking a single frame for the whole list - this test proves that
#   batching doesn't silently drop any rows.

const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

var failures := []
var passes := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame

	# --- Frame texture cache: a second call for the same species/direction
	# must return the exact cached array (not rebuild it from disk again).
	var charizard_def := PokemonHelpers.get_definition("charizard")
	var folder := str(charizard_def.get("front_frames_path", ""))
	_check("setup: charizard has a real front_frames_path to test caching with", folder != "", folder)
	var first_call: Array = PokemonHelpers._textures_from_folder(folder)
	_check("first call actually loads frames", not first_call.is_empty(), first_call.size())
	var second_call: Array = PokemonHelpers._textures_from_folder(folder)
	_check("second call for the same folder returns the cached array (not a fresh rebuild)",
		first_call == second_call and PokemonHelpers._frame_textures_cache.has(folder), [first_call.size(), second_call.size()])

	# --- Large storage batching: build a save with a large storage (well
	# past one ROWS_PER_BATCH) and confirm every row still gets built once
	# the batched render finishes - proving the yield-per-batch change
	# doesn't silently truncate the list.
	var storage_mons := []
	for i in range(120):
		storage_mons.append(PokemonHelpers.normalize_pokemon({"id": "rattata", "level": 5, "nickname": "Mon%d" % i}))
	SaveManager.create_save(1, {"player_name": "Tester", "storage": storage_mons})

	var home = load("res://scenes/HomeScreen.tscn").instantiate()
	get_tree().root.add_child.call_deferred(home)
	await get_tree().process_frame
	await get_tree().process_frame

	home._show_storage()
	# Batches yield one frame per 40 rows - 120 rows needs several frames
	# to fully finish; wait generously long enough for all of them.
	for i in range(10):
		await get_tree().process_frame

	var storage_popup: Node = home.get_node_or_null("StoragePopup")
	_check("StoragePopup exists after the batched build finishes", storage_popup != null, storage_popup)
	if storage_popup != null:
		var content: Node = storage_popup.get_node("StorageScroll").get_child(0)
		var withdraw_buttons := 0
		for child in content.get_children():
			if str(child.name).begins_with("Withdraw"):
				withdraw_buttons += 1
		_check("all 120 storage rows exist once the batched render completes (none silently dropped)",
			withdraw_buttons == 120, withdraw_buttons)

	print("\n=== PERFORMANCE FIXES TEST: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("FAIL: " + f)
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check(label: String, condition: bool, detail) -> void:
	if condition:
		passes += 1
	else:
		failures.append("%s (got: %s)" % [label, str(detail)])
		print("FAIL: %s (got: %s)" % [label, str(detail)])
