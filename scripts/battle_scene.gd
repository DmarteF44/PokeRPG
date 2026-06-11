extends Control

const UI = preload("res://scripts/ui_factory.gd")

var message_label: Label
var action_panel: Control
var attack_panel: Control
var enemy_hp_fill: ColorRect
var enemy_hp_label: Label


func _ready() -> void:
	UI.setup_screen(self)
	UI.add_background(self)
	UI.add_topbar(self)
	UI.add_label(self, "Battle", Vector2(60, 6), Vector2(240, 32), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TopTitle")

	_add_enemy_area()
	_add_player_area()
	_add_message_box()
	_add_action_buttons()


func _add_enemy_area() -> void:
	UI.add_label(self, "Wurmple Lv. 15", Vector2(18, 62), Vector2(180, 24), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "EnemyName")
	_add_hp_bar(Vector2(18, 92), Vector2(146, 12), 1.0, "Enemy")
	enemy_hp_label = UI.add_label(self, "HP 60/60", Vector2(18, 108), Vector2(146, 22), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "EnemyHpText")
	UI.add_texture(self, "res://assets/sprites/sprite_wurmple_96.png", Vector2(226, 70), Vector2(96, 96), "EnemySprite", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)


func _add_player_area() -> void:
	UI.add_texture(self, "res://assets/sprites/sprite_charmander_96.png", Vector2(36, 266), Vector2(112, 112), "PlayerSprite", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	UI.add_label(self, "Charmander Lv. 15", Vector2(166, 278), Vector2(178, 24), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER, "PlayerName")
	_add_hp_bar(Vector2(198, 310), Vector2(146, 12), 1.0, "Player")
	UI.add_label(self, "HP 60/60", Vector2(198, 326), Vector2(146, 22), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER, "PlayerHpText")


func _add_message_box() -> void:
	var box := ColorRect.new()
	box.name = "MessageBox"
	box.position = Vector2(16, 404)
	box.size = Vector2(328, 92)
	box.color = Color(0.05, 0.11, 0.19, 0.88)
	add_child(box)

	message_label = UI.add_label(box, "Wild Wurmple appeared!\nGo! Charmander!\nWhat will Charmander do?", Vector2(16, 10), Vector2(296, 72), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "BattleText")


func _add_action_buttons() -> void:
	action_panel = Control.new()
	action_panel.name = "ActionPanel"
	action_panel.position = Vector2.ZERO
	action_panel.size = UI.SCREEN_SIZE
	add_child(action_panel)

	UI.add_orange_button(action_panel, "Fight", Vector2(28, 512), Vector2(140, 44), Callable(self, "_show_attack_panel"), "Fight")
	UI.add_orange_button(action_panel, "Bag", Vector2(192, 512), Vector2(140, 44), Callable(self, "_show_bag"), "Bag")
	UI.add_orange_button(action_panel, "Pokemon", Vector2(28, 570), Vector2(140, 44), Callable(self, "_show_pokemon"), "Pokemon")
	UI.add_orange_button(action_panel, "Run", Vector2(192, 570), Vector2(140, 44), Callable(self, "_run"), "Run")


func _show_attack_panel() -> void:
	if attack_panel != null and is_instance_valid(attack_panel):
		attack_panel.queue_free()

	attack_panel = Control.new()
	attack_panel.name = "AttackPanel"
	attack_panel.position = Vector2.ZERO
	attack_panel.size = UI.SCREEN_SIZE
	add_child(attack_panel)

	var bg := ColorRect.new()
	bg.name = "AttackPanelBg"
	bg.position = Vector2(16, 504)
	bg.size = Vector2(328, 116)
	bg.color = Color(0.03, 0.10, 0.17, 0.92)
	attack_panel.add_child(bg)

	UI.add_orange_button(attack_panel, "Scratch", Vector2(28, 516), Vector2(140, 44), Callable(self, "_use_scratch"), "Scratch")
	UI.add_orange_button(attack_panel, "Metal Claw", Vector2(192, 516), Vector2(140, 44), Callable(self, "_use_metal_claw"), "MetalClaw")
	UI.add_orange_button(attack_panel, "Ember", Vector2(110, 570), Vector2(140, 44), Callable(self, "_use_ember"), "Ember")


func _use_scratch() -> void:
	_hide_attack_panel()
	message_label.text = "Charmander used Scratch!\nWurmple is still standing.\nWhat will Charmander do?"


func _use_metal_claw() -> void:
	_hide_attack_panel()
	message_label.text = "Charmander used Metal Claw!\nWurmple is still standing.\nWhat will Charmander do?"


func _use_ember() -> void:
	_hide_attack_panel()
	message_label.text = "Charmander used Ember!\nDamage: 30\nWurmple used Bug Bite!"
	enemy_hp_fill.size = Vector2(73, 8)
	enemy_hp_label.text = "HP 30/60"


func _hide_attack_panel() -> void:
	if attack_panel != null and is_instance_valid(attack_panel):
		attack_panel.queue_free()


func _show_bag() -> void:
	UI.show_message_popup(self, "Bag", "Bag placeholder")


func _show_pokemon() -> void:
	UI.show_message_popup(self, "Pokemon", "Pokemon placeholder")


func _run() -> void:
	get_tree().change_scene_to_file("res://scenes/ForestMap.tscn")


func _add_hp_bar(pos: Vector2, node_size: Vector2, ratio: float, node_name: String) -> void:
	var bg := ColorRect.new()
	bg.name = "%sHpBack" % node_name
	bg.position = pos
	bg.size = node_size
	bg.color = Color(0.02, 0.02, 0.02, 0.95)
	add_child(bg)

	var fill := ColorRect.new()
	fill.name = "%sHpFill" % node_name
	fill.position = pos + Vector2(2, 2)
	fill.size = Vector2((node_size.x - 4.0) * ratio, node_size.y - 4.0)
	fill.color = Color(0.24, 0.85, 0.24)
	add_child(fill)

	if node_name == "Enemy":
		enemy_hp_fill = fill
