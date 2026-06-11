extends Control

const UI = preload("res://scripts/ui_factory.gd")

var result_container: Control


func _ready() -> void:
	randomize()
	UI.setup_screen(self)
	UI.add_background(self)
	UI.add_topbar(self)
	UI.add_label(self, "Forest Map", Vector2(60, 6), Vector2(240, 32), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TopTitle")

	UI.add_label(self, "Forest Map", Vector2(20, 54), Vector2(320, 30), 22, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Title")
	UI.add_texture(self, "res://assets/maps/map_forest_64.png", Vector2(148, 88), Vector2(64, 64), "ForestIcon", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	UI.add_label(self, "Explore this map to find rare Pokemon in the forest map exists several types of Pokemon.", Vector2(28, 158), Vector2(304, 70), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Description")
	UI.add_label(self, "On this map you can find Pokemon types:", Vector2(24, 232), Vector2(312, 28), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TypesText")

	_add_badges()
	UI.add_orange_button(self, "Explore Map", Vector2(70, 358), Vector2(220, 48), Callable(self, "_explore_map"), "ExploreButton")

	result_container = Control.new()
	result_container.name = "Result"
	result_container.position = Vector2(0, 412)
	result_container.size = Vector2(360, 210)
	add_child(result_container)


func _add_badges() -> void:
	var badges := [
		["res://assets/badges/type_grass.png", Vector2(20, 274)],
		["res://assets/badges/type_normal.png", Vector2(102, 274)],
		["res://assets/badges/type_ground.png", Vector2(184, 274)],
		["res://assets/badges/type_flying.png", Vector2(266, 274)],
		["res://assets/badges/type_water.png", Vector2(61, 308)],
		["res://assets/badges/type_poison.png", Vector2(143, 308)],
		["res://assets/badges/type_bug.png", Vector2(225, 308)],
	]

	for i in range(badges.size()):
		var row = badges[i]
		UI.add_texture(self, row[0], row[1], Vector2(78, 24), "Badge%d" % i, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)


func _explore_map() -> void:
	_clear_result()
	if randf() < 0.5:
		UI.add_label(result_container, "None pokemon found", Vector2(20, 42), Vector2(320, 42), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "NoneFound")
		return

	UI.add_texture(result_container, "res://assets/sprites/sprite_wurmple_96.png", Vector2(28, 8), Vector2(96, 96), "Wurmple", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	UI.add_label(result_container, "Pokemon Wurmple found!", Vector2(128, 8), Vector2(204, 34), 17, Color(0.2, 0.62, 1.0), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "FoundText")
	UI.add_label(result_container, "Level: 15.", Vector2(128, 46), Vector2(204, 28), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Level")
	UI.add_texture(result_container, "res://assets/badges/type_bug.png", Vector2(192, 78), Vector2(78, 24), "BugBadge", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	UI.add_orange_button(result_container, "Click here to fight!", Vector2(55, 132), Vector2(250, 52), Callable(self, "_open_battle_scene"), "FightButton")


func _clear_result() -> void:
	for child in result_container.get_children():
		child.queue_free()


func _open_battle_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/BattleScene.tscn")
