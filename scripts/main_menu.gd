extends Control

const UI = preload("res://scripts/ui_factory.gd")
const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

const CUSTOM_AVATAR_PATH = "user://custom_avatar.png"
const AVATAR_ASSETS = [
	"res://assets/avatars/128/avatar_01_trainer_red_128.png",
	"res://assets/avatars/128/avatar_02_trainer_blue_128.png",
	"res://assets/avatars/128/avatar_03_trainer_green_128.png",
	"res://assets/avatars/128/avatar_04_trainer_gold_128.png",
	"res://assets/avatars/128/avatar_05_trainer_purple_128.png",
	"res://assets/avatars/128/avatar_06_trainer_black_128.png",
]
const AVATAR_ASSETS_96 = [
	"res://assets/avatars/96/avatar_01_trainer_red_96.png",
	"res://assets/avatars/96/avatar_02_trainer_blue_96.png",
	"res://assets/avatars/96/avatar_03_trainer_green_96.png",
	"res://assets/avatars/96/avatar_04_trainer_gold_96.png",
	"res://assets/avatars/96/avatar_05_trainer_purple_96.png",
	"res://assets/avatars/96/avatar_06_trainer_black_96.png",
]
const AVATAR_COLORS = [
	Color(0.86, 0.22, 0.20),
	Color(0.18, 0.42, 0.82),
	Color(0.20, 0.62, 0.34),
	Color(0.92, 0.70, 0.22),
	Color(0.50, 0.24, 0.78),
	Color(0.12, 0.15, 0.20),
]
const STARTERS = [
	{"id": "bulbasaur", "name": "Bulbasaur", "dex": 1, "sprite": "res://assets/pokemon/icons/bulbasaur.png", "available": true},
	{"id": "charmander", "name": "Charmander", "dex": 4, "sprite": "res://assets/pokemon/icons/charmander.png", "available": true},
	{"id": "squirtle", "name": "Squirtle", "dex": 7, "sprite": "res://assets/pokemon/icons/squirtle.png", "available": true},
]
const TEXT = {
	"en": {
		"load_game": "Load Game",
		"new_game": "New Game",
		"options": "Options",
		"about": "About",
		"about_message": "PokeRPG private remake",
		"apply": "Apply",
		"cancel": "Cancel",
		"music": "Music",
		"sfx": "Sound Effects",
		"language": "Language",
		"player_name": "Player Name",
		"name_placeholder": "Enter your name",
		"choose_avatar": "Choose your avatar",
		"custom_image": "Custom Image",
		"use_custom_image": "Use Custom Image",
		"custom_help": "Place your image at user://custom_avatar.png and reload the profile.",
		"choose_generation": "Choose starter generation",
		"choose_starter": "Choose starter",
		"start_game": "Start Game",
		"empty_slot": "Empty Slot",
		"empty_save_slot": "Empty save slot.",
		"load": "Load",
		"delete_save": "Delete Save",
		"delete": "Delete",
		"delete_confirm": "Delete this save?",
		"overwrite": "Slot 1 already has a save. Overwrite it?",
		"yes": "Yes",
		"no": "No",
		"slot": "Slot",
		"level": "Level",
		"money": "Money",
		"badges": "Badges",
		"avatar": "Avatar",
		"starter": "Starter",
			"coming_starter": "Coming soon. Gen 1 starters are available for now.",
		"coming_generation": "Coming soon. Gen 1 is available for now.",
		"player_default": "Player",
	},
	"pt": {
		"load_game": "Carregar Jogo",
		"new_game": "Novo Jogo",
		"options": "Opções",
		"about": "Sobre",
		"about_message": "PokeRPG private remake",
		"apply": "Aplicar",
		"cancel": "Cancelar",
		"music": "Música",
		"sfx": "Efeitos Sonoros",
		"language": "Idioma",
		"player_name": "Nome do Jogador",
		"name_placeholder": "Digite seu nome",
		"choose_avatar": "Escolha seu avatar",
		"custom_image": "Imagem própria",
		"use_custom_image": "Usar Imagem Própria",
		"custom_help": "Coloque sua imagem em user://custom_avatar.png e recarregue o perfil.",
		"choose_generation": "Escolha a geração inicial",
		"choose_starter": "Escolha o inicial",
		"start_game": "Iniciar Jogo",
		"empty_slot": "Slot Vazio",
		"empty_save_slot": "Slot de save vazio.",
		"load": "Carregar",
		"delete_save": "Apagar Save",
		"delete": "Apagar",
		"delete_confirm": "Apagar este save?",
		"overwrite": "O slot 1 já tem save. Deseja sobrescrever?",
		"yes": "Sim",
		"no": "Não",
		"slot": "Slot",
		"level": "Nv.",
		"money": "Dinheiro",
		"badges": "Insígnias",
		"avatar": "Avatar",
		"starter": "Inicial",
			"coming_starter": "Em breve. Os iniciais da Gen 1 estão disponíveis por enquanto.",
		"coming_generation": "Em breve. A Gen 1 está disponível por enquanto.",
		"player_default": "Jogador",
	},
}

var settings: Dictionary = {}
var menu_labels := {}
var selected_avatar_id := 1
var selected_avatar_type := "preset"
var selected_generation := 1
var selected_starter_name := "Charmander"
var selected_starter_id := "charmander"
var selected_starter_dex := 4
var avatar_buttons: Array = []
var custom_avatar_button: Button
var generation_buttons: Array = []
var starter_buttons: Array = []
var player_name_edit: LineEdit
var start_game_button: TextureButton
var load_popup: Control


func _ready() -> void:
	UI.setup_screen(self)
	settings = SaveManager.load_settings()
	_build_main_menu()
	_update_menu_texts()


func _build_main_menu() -> void:
	UI.add_background(self)
	UI.add_texture(self, "res://assets/ui/logo_pokerpg_512x200.png", Vector2(36, 70), Vector2(288, 112), "Logo", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_menu_button("load_game", Vector2(70, 250), Callable(self, "_show_load_game"))
	_add_menu_button("new_game", Vector2(70, 310), Callable(self, "_show_new_game"))
	_add_menu_button("options", Vector2(70, 370), Callable(self, "_show_options"))
	_add_menu_button("about", Vector2(70, 430), Callable(self, "_show_about"))
	UI.add_label(self, "Private remake prototype", Vector2(20, 594), Vector2(320, 24), 13, Color(0.86, 0.9, 0.94), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Footer")


func _add_menu_button(key: String, pos: Vector2, callback: Callable) -> void:
	var button := UI.add_orange_button(self, "", pos, Vector2(220, 48), callback, key.capitalize().replace(" ", ""))
	menu_labels[key] = button.get_node("Text")


func _update_menu_texts() -> void:
	for key in ["load_game", "new_game", "options", "about"]:
		if menu_labels.has(key):
			menu_labels[key].text = _text(key)


func _show_load_game() -> void:
	if load_popup != null and is_instance_valid(load_popup):
		load_popup.queue_free()

	load_popup = _create_popup(_text("load_game"), 60.0, 520.0)
	for slot in range(1, SaveManager.MAX_SAVE_SLOTS + 1):
		_add_save_slot(load_popup, slot, 134.0 + float(slot - 1) * 104.0)

	var cancel_callback = func():
		load_popup.queue_free()
	UI.add_orange_button(load_popup, _text("cancel"), Vector2(70, 522), Vector2(220, 48), cancel_callback, "CancelLoad")


func _add_save_slot(parent: Control, slot: int, y: float) -> void:
	var save_data := SaveManager.get_save(slot)
	var slot_button := Button.new()
	slot_button.name = "SaveSlot%d" % slot
	slot_button.position = Vector2(28, y)
	slot_button.size = Vector2(172, 82)
	slot_button.focus_mode = Control.FOCUS_NONE
	slot_button.add_theme_font_size_override("font_size", 11)
	slot_button.add_theme_color_override("font_color", UI.PANEL_TEXT)
	slot_button.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	slot_button.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	UI.style_panel_button(slot_button, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
	parent.add_child(slot_button)

	if save_data.is_empty():
		slot_button.size = Vector2(304, 82)
		slot_button.add_theme_font_size_override("font_size", 13)
		slot_button.text = "%s %d\n%s" % [_text("slot"), slot, _text("empty_slot")]
		slot_button.pressed.connect(Callable(self, "_show_empty_save_slot_message"))
		return

	slot_button.size = Vector2(304, 82)
	slot_button.text = ""
	_add_save_avatar(slot_button, save_data, Vector2(10, 13), Vector2(48, 48))
	UI.add_panel_label(slot_button, "%s %d\n%s\n%s: %s\n%s: $%d | %s %d | %s %d" % [
		_text("slot"),
		slot,
		str(save_data.get("player_name", _text("player_default"))),
		_text("starter"),
		str(save_data.get("starter_name", "Charmander")),
		_text("money"),
		int(save_data.get("money", 3000)),
		_text("level"),
		max(1, int(save_data.get("level", 1))),
		_text("badges"),
		int(save_data.get("badges", 0)),
	], Vector2(66, 7), Vector2(132, 68), 11, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "SaveText")
	slot_button.pressed.connect(Callable(self, "_load_save").bind(slot))

	var load_button := Button.new()
	load_button.name = "LoadSave%d" % slot
	load_button.text = _text("load")
	load_button.position = Vector2(206, y + 10)
	load_button.size = Vector2(58, 30)
	load_button.focus_mode = Control.FOCUS_NONE
	load_button.add_theme_font_size_override("font_size", 11)
	load_button.add_theme_color_override("font_color", UI.PANEL_TEXT)
	UI.style_panel_button(load_button, Color(0.95, 0.78, 0.32), Color(0.92, 0.46, 0.08), 2)
	parent.add_child(load_button)
	load_button.pressed.connect(Callable(self, "_load_save").bind(slot))

	var delete_button := Button.new()
	delete_button.name = "DeleteSave%d" % slot
	delete_button.text = _text("delete")
	delete_button.position = Vector2(270, y + 10)
	delete_button.size = Vector2(58, 30)
	delete_button.focus_mode = Control.FOCUS_NONE
	delete_button.add_theme_font_size_override("font_size", 11)
	delete_button.add_theme_color_override("font_color", Color.WHITE)
	UI.style_panel_button(delete_button, Color(0.74, 0.18, 0.16), Color(0.44, 0.08, 0.08), 2)
	parent.add_child(delete_button)
	delete_button.pressed.connect(Callable(self, "_confirm_delete_save").bind(slot))


func _load_save(slot: int) -> void:
	var save_data := SaveManager.load_save(slot)
	if save_data.is_empty():
		UI.show_message_popup(self, _text("load_game"), _text("empty_save_slot"))
		return

	GameState.apply_save(save_data)
	get_tree().change_scene_to_file("res://scenes/HomeScreen.tscn")


func _confirm_delete_save(slot: int) -> void:
	var save_data := SaveManager.get_save(slot)
	if save_data.is_empty():
		UI.show_message_popup(self, _text("delete_save"), _text("empty_save_slot"))
		return

	var on_yes = func():
		SaveManager.delete_save(slot)
		if load_popup != null and is_instance_valid(load_popup):
			load_popup.queue_free()
		call_deferred("_show_load_game")
	UI.show_confirm_popup(self, _text("delete_save"), _text("delete_confirm"), _text("yes"), _text("no"), on_yes)


func _show_new_game() -> void:
	selected_avatar_id = 1
	selected_avatar_type = "preset"
	selected_generation = 1
	selected_starter_name = "Charmander"
	selected_starter_id = "charmander"
	selected_starter_dex = 4
	avatar_buttons.clear()
	custom_avatar_button = null
	generation_buttons.clear()
	starter_buttons.clear()

	var popup := _create_popup(_text("new_game"), 42.0, 560.0)
	var scroll := ScrollContainer.new()
	scroll.name = "NewGameScroll"
	scroll.position = Vector2(28, 112)
	scroll.size = Vector2(304, 420)
	popup.add_child(scroll)

	var content := Control.new()
	content.name = "NewGameContent"
	content.custom_minimum_size = Vector2(304, 740)
	scroll.add_child(content)

	_build_new_game_content(content)

	var cancel_callback = func():
		popup.queue_free()
	UI.add_orange_button(popup, _text("cancel"), Vector2(36, 546), Vector2(140, 44), cancel_callback, "CancelNewGame")

	var start_callback = func():
		_try_start_new_game()
	start_game_button = UI.add_orange_button(popup, _text("start_game"), Vector2(184, 546), Vector2(140, 44), start_callback, "StartGame")
	_update_new_game_selection_styles()


func _build_new_game_content(content: Control) -> void:
	UI.add_panel_label(content, _text("player_name"), Vector2(0, 0), Vector2(296, 24), 15, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "NameLabel")
	player_name_edit = LineEdit.new()
	player_name_edit.name = "PlayerName"
	player_name_edit.position = Vector2(0, 28)
	player_name_edit.size = Vector2(296, 40)
	player_name_edit.placeholder_text = _text("name_placeholder")
	player_name_edit.add_theme_font_size_override("font_size", 16)
	player_name_edit.add_theme_color_override("font_color", UI.PANEL_TEXT)
	content.add_child(player_name_edit)

	UI.add_panel_label(content, _text("choose_avatar"), Vector2(0, 88), Vector2(296, 28), 17, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "AvatarLabel")
	for avatar_id in range(1, 7):
		var x := float((avatar_id - 1) % 3) * 102.0
		var y := 122.0 + float(int((avatar_id - 1) / 3)) * 102.0
		_add_avatar_button(content, avatar_id, Vector2(x, y))

	UI.add_panel_label(content, _text("custom_image"), Vector2(0, 322), Vector2(296, 24), 16, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "CustomLabel")
	_add_custom_avatar_button(content, Vector2(102, 352))

	UI.add_panel_label(content, _text("choose_generation"), Vector2(0, 466), Vector2(296, 28), 17, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "GenerationLabel")
	for generation in range(1, 9):
		var button := Button.new()
		button.name = "Gen%d" % generation
		button.text = "Gen %d" % generation
		button.position = Vector2(float((generation - 1) % 4) * 74.0, 502.0 + float(int((generation - 1) / 4)) * 42.0)
		button.size = Vector2(68, 36)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 13)
		button.add_theme_color_override("font_color", UI.PANEL_TEXT)
		button.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
		button.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
		content.add_child(button)
		generation_buttons.append(button)
		button.pressed.connect(Callable(self, "_select_generation").bind(generation))

	UI.add_panel_label(content, _text("choose_starter"), Vector2(0, 600), Vector2(296, 28), 17, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "StarterLabel")
	for i in range(STARTERS.size()):
		_add_starter_button(content, STARTERS[i], Vector2(float(i) * 102.0, 636.0))


func _add_avatar_button(parent: Control, avatar_id: int, pos: Vector2) -> void:
	var button := Button.new()
	button.name = "Avatar%d" % avatar_id
	button.position = pos
	button.size = Vector2(92, 92)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	parent.add_child(button)
	avatar_buttons.append(button)

	var asset_path := _avatar_asset_path(avatar_id)
	if asset_path != "":
		_add_texture_from_path(button, asset_path, Vector2(18, 8), Vector2(56, 56), "AvatarImage")
	else:
		var swatch := ColorRect.new()
		swatch.name = "AvatarColor"
		swatch.position = Vector2(18, 8)
		swatch.size = Vector2(56, 54)
		swatch.color = AVATAR_COLORS[avatar_id - 1]
		swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(swatch)
		UI.add_panel_label(button, "Avatar", Vector2(0, 22), Vector2(92, 24), 12, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "AvatarInitial")

	UI.add_panel_label(button, "%s %d" % [_text("avatar"), avatar_id], Vector2(0, 66), Vector2(92, 20), 12, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "AvatarText")
	button.pressed.connect(Callable(self, "_select_avatar").bind(avatar_id))


func _add_custom_avatar_button(parent: Control, pos: Vector2) -> void:
	var button := Button.new()
	button.name = "AvatarCustom"
	button.position = pos
	button.size = Vector2(92, 92)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	parent.add_child(button)
	custom_avatar_button = button

	var custom_path := CUSTOM_AVATAR_PATH if FileAccess.file_exists(CUSTOM_AVATAR_PATH) else "res://assets/avatars/avatar_card_custom_image.png"
	if custom_path != "" and FileAccess.file_exists(custom_path):
		_add_texture_from_path(button, custom_path, Vector2(17, 7), Vector2(58, 58), "AvatarImage")
	else:
		var swatch := ColorRect.new()
		swatch.name = "CustomAvatarColor"
		swatch.position = Vector2(18, 8)
		swatch.size = Vector2(56, 54)
		swatch.color = Color(0.36, 0.46, 0.62)
		swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(swatch)
		UI.add_panel_label(button, "IMG", Vector2(0, 22), Vector2(92, 24), 13, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "CustomAvatarInitial")

	UI.add_panel_label(button, _text("custom_image"), Vector2(4, 64), Vector2(84, 24), 10, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "AvatarText")
	button.pressed.connect(Callable(self, "_select_custom_avatar"))


func _add_starter_button(parent: Control, starter: Dictionary, pos: Vector2) -> void:
	var button := Button.new()
	button.name = str(starter["name"])
	button.position = pos
	button.size = Vector2(92, 86)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	parent.add_child(button)
	starter_buttons.append(button)

	var sprite_path := str(starter.get("sprite", ""))
	if sprite_path != "" and FileAccess.file_exists(sprite_path):
		UI.add_texture(button, sprite_path, Vector2(18, 4), Vector2(56, 56), "StarterSprite", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	else:
		UI.add_panel_label(button, "?", Vector2(0, 8), Vector2(92, 42), 28, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "StarterPlaceholder")

	UI.add_panel_label(button, str(starter["name"]), Vector2(0, 60), Vector2(92, 20), 12, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "StarterText")
	button.pressed.connect(Callable(self, "_select_starter").bind(starter))


func _select_avatar(avatar_id: int) -> void:
	selected_avatar_id = avatar_id
	selected_avatar_type = "preset"
	_update_new_game_selection_styles()


func _select_custom_avatar() -> void:
	selected_avatar_id = 0
	selected_avatar_type = "custom"
	_update_new_game_selection_styles()
	if not FileAccess.file_exists(CUSTOM_AVATAR_PATH):
		UI.show_message_popup(self, _text("custom_image"), _text("custom_help"))


func _select_generation(generation: int) -> void:
	selected_generation = generation
	if generation == 1:
		selected_starter_name = "Charmander"
		selected_starter_id = "charmander"
		selected_starter_dex = 4
	else:
		selected_starter_name = ""
		selected_starter_id = ""
		selected_starter_dex = 0
		UI.show_message_popup(self, "Gen %d" % generation, _text("coming_generation"))
	_update_new_game_selection_styles()


func _select_starter(starter: Dictionary) -> void:
	if not bool(starter.get("available", false)):
		UI.show_message_popup(self, str(starter["name"]), _text("coming_starter"))
		return

	selected_generation = 1
	selected_starter_id = str(starter.get("id", PokemonHelpers.id_from_name(str(starter["name"]))))
	selected_starter_name = str(starter["name"])
	selected_starter_dex = int(starter["dex"])
	_update_new_game_selection_styles()


func _starter_is_available(starter_name: String) -> bool:
	for starter in STARTERS:
		if str(starter.get("name", "")) == starter_name:
			return bool(starter.get("available", false))
	return false


func _update_new_game_selection_styles() -> void:
	for i in range(avatar_buttons.size()):
		var button: Button = avatar_buttons[i]
		var selected := selected_avatar_type == "preset" and selected_avatar_id == i + 1
		UI.style_panel_button(button, Color(0.95, 0.78, 0.32) if selected else Color(0.82, 0.88, 0.94), Color(0.92, 0.46, 0.08) if selected else Color(0.36, 0.50, 0.62), 3 if selected else 2)

	for i in range(generation_buttons.size()):
		var button: Button = generation_buttons[i]
		var gen := i + 1
		var selected := selected_generation == gen
		var fill := Color(0.95, 0.78, 0.32) if selected else Color(0.82, 0.88, 0.94)
		if gen != 1:
			fill = Color(0.70, 0.76, 0.82) if not selected else Color(0.88, 0.70, 0.30)
		UI.style_panel_button(button, fill, Color(0.92, 0.46, 0.08) if selected else Color(0.36, 0.50, 0.62), 3 if selected else 2)

	for button: Button in starter_buttons:
		var starter_name: String = button.name
		var selected: bool = selected_generation == 1 and selected_starter_name == starter_name
		var available := _starter_is_available(starter_name)
		var fill := Color(0.95, 0.78, 0.32) if selected else Color(0.82, 0.88, 0.94)
		if not available:
			fill = Color(0.72, 0.76, 0.80)
		UI.style_panel_button(button, fill, Color(0.92, 0.46, 0.08) if selected else Color(0.36, 0.50, 0.62), 3 if selected else 2)

	if start_game_button != null and is_instance_valid(start_game_button):
		var can_start := selected_generation == 1 and PokemonHelpers.is_starter_id(selected_starter_id)
		start_game_button.disabled = not can_start
		start_game_button.modulate = Color(1, 1, 1, 1) if can_start else Color(0.62, 0.62, 0.62, 0.88)

	if custom_avatar_button != null and is_instance_valid(custom_avatar_button):
		var selected_custom := selected_avatar_type == "custom"
		UI.style_panel_button(custom_avatar_button, Color(0.95, 0.78, 0.32) if selected_custom else Color(0.82, 0.88, 0.94), Color(0.92, 0.46, 0.08) if selected_custom else Color(0.36, 0.50, 0.62), 3 if selected_custom else 2)


func _try_start_new_game() -> void:
	if selected_generation != 1 or not PokemonHelpers.is_starter_id(selected_starter_id):
		UI.show_message_popup(self, _text("new_game"), _text("coming_starter"))
		return

	if SaveManager.has_save(1):
		var on_yes = func():
			_create_save_and_start()
		UI.show_confirm_popup(self, _text("new_game"), _text("overwrite"), _text("yes"), _text("no"), on_yes)
		return

	_create_save_and_start()


func _create_save_and_start() -> void:
	var player_name := player_name_edit.text.strip_edges()
	if player_name == "":
		player_name = _text("player_default")

	var starter_pokemon := PokemonHelpers.starter_save_data(selected_starter_id)
	var save_data := SaveManager.create_save(1, {
		"player_name": player_name,
		"avatar_id": selected_avatar_id,
		"avatar_type": selected_avatar_type,
		"avatar_custom_path": CUSTOM_AVATAR_PATH if selected_avatar_type == "custom" else "",
		"starter_generation": selected_generation,
		"starter_id": selected_starter_id,
		"starter_name": selected_starter_name,
		"starter_dex_number": selected_starter_dex,
		"money": 3000,
		"level": 1,
		"badges": 0,
		"inventory": {
			"poke_ball": 5,
			"potion": 3,
			"town_map": 1,
		},
		"team": [starter_pokemon],
		"seen_pokemon": PokemonHelpers.starter_ids(),
		"owned_pokemon": [selected_starter_id],
		"current_scene": "HomeScreen",
		"current_map": "",
	})
	GameState.apply_save(save_data)
	get_tree().change_scene_to_file("res://scenes/HomeScreen.tscn")


func _show_options() -> void:
	UI.show_options_popup(self, _text("options"), _options_labels(), Callable(self, "_on_options_applied"))


func _on_options_applied(new_settings: Dictionary) -> void:
	settings = new_settings
	_update_menu_texts()


func _show_about() -> void:
	UI.show_message_popup(self, _text("about"), _text("about_message"))


func _create_popup(title: String, panel_y: float, panel_height: float) -> Control:
	var overlay := Control.new()
	overlay.name = "Popup"
	overlay.position = Vector2.ZERO
	overlay.size = UI.SCREEN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = UI.SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.44)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)

	var panel := UI.add_texture(overlay, UI.POPUP_PANEL, Vector2(15, panel_y), Vector2(330, panel_height), "Panel", TextureRect.STRETCH_SCALE)
	UI.add_panel_label(overlay, title, Vector2(50, panel_y + 26.0), Vector2(260, 34), 23, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "PopupTitle")

	var close := UI.add_icon_button(overlay, "res://assets/icons/icon_close_32.png", Vector2(298, panel_y + 20.0), Callable(), "Close")
	close.pressed.connect(func():
		overlay.queue_free()
	)

	_animate_popup(overlay, panel)
	return overlay


func _animate_popup(overlay: Control, panel: Control) -> void:
	overlay.modulate.a = 0.0
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.96, 0.96)
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _avatar_asset_path(avatar_id: int) -> String:
	var index := avatar_id - 1
	if index >= 0 and index < AVATAR_ASSETS_96.size() and FileAccess.file_exists(AVATAR_ASSETS_96[index]):
		return AVATAR_ASSETS_96[index]
	if index >= 0 and index < AVATAR_ASSETS.size() and FileAccess.file_exists(AVATAR_ASSETS[index]):
		return AVATAR_ASSETS[index]
	return ""


func _save_avatar_path(save_data: Dictionary) -> String:
	if str(save_data.get("avatar_type", "preset")) == "custom":
		var custom_path := str(save_data.get("avatar_custom_path", CUSTOM_AVATAR_PATH))
		if custom_path != "" and FileAccess.file_exists(custom_path):
			return custom_path
		if FileAccess.file_exists("res://assets/avatars/avatar_card_custom_image.png"):
			return "res://assets/avatars/avatar_card_custom_image.png"
	return _avatar_asset_path(int(save_data.get("avatar_id", 1)))


func _add_save_avatar(parent: Control, save_data: Dictionary, pos: Vector2, node_size: Vector2) -> void:
	var avatar_path := _save_avatar_path(save_data)
	if avatar_path != "":
		_add_texture_from_path(parent, avatar_path, pos, node_size, "SaveAvatar")
		return

	var swatch := ColorRect.new()
	swatch.name = "SaveAvatarFallback"
	swatch.position = pos
	swatch.size = node_size
	swatch.color = Color(0.34, 0.50, 0.62)
	swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(swatch)
	UI.add_panel_label(parent, "AV", pos, node_size, 12, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "SaveAvatarText")


func _add_texture_from_path(parent: Node, path: String, pos: Vector2, node_size: Vector2, node_name: String) -> TextureRect:
	if path.begins_with("user://"):
		var image := Image.new()
		if image.load(path) == OK:
			var texture := ImageTexture.create_from_image(image)
			var texture_rect := TextureRect.new()
			texture_rect.name = node_name
			texture_rect.texture = texture
			texture_rect.position = pos
			texture_rect.size = node_size
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			parent.add_child(texture_rect)
			return texture_rect

	return UI.add_texture(parent, path, pos, node_size, node_name, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)


func _show_empty_save_slot_message() -> void:
	UI.show_message_popup(self, _text("load_game"), _text("empty_save_slot"))


func _options_labels() -> Dictionary:
	return {
		"music": _text("music"),
		"sfx": _text("sfx"),
		"language": _text("language"),
		"apply": _text("apply"),
		"cancel": _text("cancel"),
	}


func _text(key: String) -> String:
	var language := str(settings.get("language", "en"))
	if not TEXT.has(language):
		language = "en"
	var language_text: Dictionary = TEXT[language]
	var english_text: Dictionary = TEXT["en"]
	return str(language_text.get(key, english_text.get(key, key)))
