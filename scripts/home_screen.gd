extends Control

const UI = preload("res://scripts/ui_factory.gd")

const ITEMS_PATH = "res://data/items.json"
const CATEGORIES = ["pokeballs", "potions", "evolution", "key_items"]
const TEXT = {
	"en": {
		"hello": "Hello %s,",
		"player_default": "Player",
		"welcome_to": "Welcome to",
		"tutorial_prompt": "New here? See the tutorial:",
		"tutorial": "Tutorial / Web Page",
		"tutorial_soon": "Tutorial page coming soon.",
		"money": "Money",
		"level": "Lv.",
		"badges_short": "%d badges",
		"explore_world": "Explore World",
		"my_pokemon": "My Pokemon",
		"bag": "Bag",
		"shop": "Shop",
		"pokedex": "PokeDex",
		"tournament": "Tournament",
		"options": "Options",
		"exit": "Exit",
		"profile": "Profile",
		"my_pokemon_soon": "My Pokemon coming soon",
		"pokedex_soon": "PokeDex coming soon",
		"return_menu": "Return to Main Menu?",
		"yes": "Yes",
		"no": "No",
		"music": "Music",
		"sfx": "Sound Effects",
		"language": "Language",
		"apply": "Apply",
		"cancel": "Cancel",
		"world_map": "World Map",
		"available": "Available",
		"coming_soon": "Coming soon",
		"map_soon": "Coming soon",
		"type": "Type",
		"forest": "Forest Map",
		"fire": "Fire Map",
		"water": "Water Map",
		"cave": "Cave Map",
		"ice": "Ice Map",
		"mansion": "Mansion Map",
		"factory": "Factory Map",
		"electric": "Electric Map",
		"desert": "Desert Map",
		"ghost": "Ghost Tower",
		"dragon": "Dragon Valley",
		"safari": "Safari Zone",
		"pokeballs": "Pokeballs",
		"potions": "Potions",
		"evolution": "Evolution",
		"key_items": "Key Items",
		"quantity": "Qty",
		"use": "Use",
		"buy": "Buy",
		"price": "Price",
		"requires": "Requires Lv. %d and %d badges.",
		"available_status": "Available",
		"locked": "Locked",
		"not_enough_money": "Not enough money.",
		"bought": "Bought %s!",
		"select_item": "Select an item to see details.",
		"pokeball_use": "Pokeballs are used during wild battles.",
		"potion_use": "Healing items will be usable in battle soon.",
		"evolution_use": "Evolution system coming soon.",
		"fishing_soon": "Fishing coming soon.",
		"tournament_soon": "Battle tournaments will be available soon.",
		"beginner_cup": "Beginner Cup",
		"forest_cup": "Forest Cup",
		"master_league": "Master League",
	},
	"pt": {
		"hello": "Olá %s,",
		"player_default": "Jogador",
		"welcome_to": "Bem-vindo ao",
		"tutorial_prompt": "Novo aqui? Veja o tutorial:",
		"tutorial": "Tutorial / Web Page",
		"tutorial_soon": "Página de tutorial em breve.",
		"money": "Dinheiro",
		"level": "Nv.",
		"badges_short": "%d insígnias",
		"explore_world": "Explorar Mundo",
		"my_pokemon": "Meus Pokémon",
		"bag": "Mochila",
		"shop": "Loja",
		"pokedex": "PokéDex",
		"tournament": "Torneio",
		"options": "Opções",
		"exit": "Sair",
		"profile": "Perfil",
		"my_pokemon_soon": "Meus Pokémon em breve",
		"pokedex_soon": "PokéDex em breve",
		"return_menu": "Voltar ao Menu Principal?",
		"yes": "Sim",
		"no": "Não",
		"music": "Música",
		"sfx": "Efeitos Sonoros",
		"language": "Idioma",
		"apply": "Aplicar",
		"cancel": "Cancelar",
		"world_map": "Mapa do Mundo",
		"available": "Disponível",
		"coming_soon": "Em breve",
		"map_soon": "Em breve",
		"type": "Tipo",
		"forest": "Floresta",
		"fire": "Mapa de Fogo",
		"water": "Mapa de Água",
		"cave": "Caverna",
		"ice": "Mapa de Gelo",
		"mansion": "Mansão",
		"factory": "Fábrica",
		"electric": "Mapa Elétrico",
		"desert": "Deserto",
		"ghost": "Torre Fantasma",
		"dragon": "Vale dos Dragões",
		"safari": "Zona Safari",
		"pokeballs": "Pokébolas",
		"potions": "Poções",
		"evolution": "Evolução",
		"key_items": "Itens-chave",
		"quantity": "Qtd",
		"use": "Usar",
		"buy": "Comprar",
		"price": "Preço",
		"requires": "Requer Nv. %d e %d insígnias.",
		"available_status": "Disponível",
		"locked": "Bloqueado",
		"not_enough_money": "Dinheiro insuficiente.",
		"bought": "%s comprado!",
		"select_item": "Selecione um item para ver detalhes.",
		"pokeball_use": "Pokébolas são usadas em batalhas selvagens.",
		"potion_use": "Itens de cura poderão ser usados em batalha em breve.",
		"evolution_use": "Sistema de evolução em breve.",
		"fishing_soon": "Pescaria em breve.",
		"tournament_soon": "Torneios de batalha estarão disponíveis em breve.",
		"beginner_cup": "Beginner Cup",
		"forest_cup": "Forest Cup",
		"master_league": "Master League",
	},
}

const WORLD_MAPS = [
	{"key": "forest", "type": "Grass", "icon": "res://assets/maps/map_forest_64.png", "available": true},
	{"key": "fire", "type": "Fire", "icon": "res://assets/maps/map_fire_64.png", "available": false},
	{"key": "water", "type": "Water", "icon": "", "available": false},
	{"key": "cave", "type": "Rock", "icon": "res://assets/maps/map_cave_64.png", "available": false},
	{"key": "ice", "type": "Ice", "icon": "res://assets/maps/map_ice_64.png", "available": false},
	{"key": "mansion", "type": "Mystery", "icon": "res://assets/maps/map_mansion_64.png", "available": false},
	{"key": "factory", "type": "Steel", "icon": "res://assets/maps/map_factory_64.png", "available": false},
	{"key": "electric", "type": "Electric", "icon": "", "available": false},
	{"key": "desert", "type": "Ground", "icon": "", "available": false},
	{"key": "ghost", "type": "Ghost", "icon": "", "available": false},
	{"key": "dragon", "type": "Dragon", "icon": "", "available": false},
	{"key": "safari", "type": "Mixed", "icon": "", "available": false},
]

var settings: Dictionary = {}
var save_data: Dictionary = {}
var items: Array = []
var world_popup: Control
var bag_popup: Control
var shop_popup: Control
var tournament_popup: Control
var stats_label: Label
var selected_bag_category := "pokeballs"
var selected_bag_item: Dictionary = {}
var selected_shop_category := "pokeballs"
var bag_description_label: Label
var bag_use_button: Button


func _ready() -> void:
	UI.setup_screen(self)
	settings = SaveManager.load_settings()
	_refresh_save_data()
	InventoryManager.ensure_default_inventory()
	_refresh_save_data()
	items = _load_items()
	_build_screen()


func _refresh_save_data() -> void:
	save_data = SaveManager.get_current_save()
	if save_data.is_empty() and SaveManager.has_save(1):
		save_data = SaveManager.load_save(1)

	if save_data.is_empty():
		save_data = {
			"player_name": _text("player_default"),
			"money": 3000,
			"level": 0,
			"badges": 0,
		}
	else:
		GameState.apply_save(save_data)


func _build_screen() -> void:
	UI.add_background(self)
	UI.add_topbar(self)
	_add_topbar_icons()

	var player_name := str(save_data.get("player_name", _text("player_default")))
	UI.add_label(self, _text("hello") % player_name, Vector2(20, 54), Vector2(320, 28), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Greeting")
	UI.add_label(self, _text("welcome_to"), Vector2(20, 82), Vector2(320, 24), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Welcome")
	UI.add_texture(self, "res://assets/ui/logo_pokerpg_512x200.png", Vector2(82, 108), Vector2(196, 76), "Logo", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)

	stats_label = UI.add_label(self, _stats_text(), Vector2(16, 188), Vector2(328, 24), 13, Color(0.94, 0.97, 1.0), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Stats")
	UI.add_label(self, _text("tutorial_prompt"), Vector2(20, 220), Vector2(320, 24), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TutorialPrompt")
	UI.add_orange_button(self, _text("tutorial"), Vector2(70, 248), Vector2(220, 48), Callable(self, "_show_tutorial"), "Tutorial")
	_add_home_scroll_buttons()


func _add_topbar_icons() -> void:
	var icon_data := [
		["res://assets/icons/icon_map_32.png", Vector2(12, 6), Callable(self, "_show_world_map"), "TopMap"],
		["res://assets/icons/icon_trophy_32.png", Vector2(66, 6), Callable(self, "_show_tournament"), "TopTournament"],
		["res://assets/icons/icon_ball_32.png", Vector2(120, 6), Callable(self, "_show_my_pokemon"), "TopPokemon"],
		["res://assets/icons/icon_bag_32.png", Vector2(174, 6), Callable(self, "_show_bag"), "TopBag"],
		["res://assets/icons/icon_user_32.png", Vector2(228, 6), Callable(self, "_show_profile"), "TopUser"],
		["res://assets/icons/icon_gear_32.png", Vector2(316, 6), Callable(self, "_show_options"), "TopGear"],
	]

	for data in icon_data:
		var icon_path := str(data[0])
		var icon_pos: Vector2 = data[1]
		var icon_callback: Callable = data[2]
		if not FileAccess.file_exists(icon_path):
			icon_path = "res://assets/icons/icon_info_32.png"
		UI.add_icon_button(self, icon_path, icon_pos, icon_callback, str(data[3]))


func _add_home_scroll_buttons() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "HomeActionsScroll"
	scroll.position = Vector2(42, 312)
	scroll.size = Vector2(276, 306)
	add_child(scroll)

	var content := Control.new()
	content.name = "HomeActions"
	content.custom_minimum_size = Vector2(276, 472)
	scroll.add_child(content)

	var actions := [
		[_text("explore_world"), Callable(self, "_show_world_map"), "ExploreWorld"],
		[_text("my_pokemon"), Callable(self, "_show_my_pokemon"), "MyPokemon"],
		[_text("bag"), Callable(self, "_show_bag"), "Bag"],
		[_text("shop"), Callable(self, "_show_shop"), "Shop"],
		[_text("pokedex"), Callable(self, "_show_pokedex"), "PokeDex"],
		[_text("tournament"), Callable(self, "_show_tournament"), "Tournament"],
		[_text("options"), Callable(self, "_show_options"), "Options"],
		[_text("exit"), Callable(self, "_confirm_exit"), "Exit"],
	]

	for i in range(actions.size()):
		var action_callback: Callable = actions[i][1]
		UI.add_orange_button(content, str(actions[i][0]), Vector2(13, float(i) * 58.0), Vector2(250, 52), action_callback, str(actions[i][2]))


func _stats_text() -> String:
	return "%s: $%d  |  %s %d  |  %s" % [
		_text("money"),
		int(save_data.get("money", 3000)),
		_text("level"),
		int(save_data.get("level", 0)),
		_text("badges_short") % int(save_data.get("badges", 0)),
	]


func _refresh_home_stats() -> void:
	if stats_label != null and is_instance_valid(stats_label):
		stats_label.text = _stats_text()


func _show_tutorial() -> void:
	UI.show_message_popup(self, _text("tutorial"), _text("tutorial_soon"))


func _show_profile() -> void:
	var player_name := str(save_data.get("player_name", _text("player_default")))
	UI.show_message_popup(self, _text("profile"), "%s\n%s" % [player_name, _stats_text()])


func _show_world_map() -> void:
	if bag_popup != null and is_instance_valid(bag_popup):
		bag_popup.queue_free()

	if world_popup != null and is_instance_valid(world_popup):
		world_popup.queue_free()

	world_popup = _create_popup(_text("world_map"), "WorldMapPopup", 34.0, 580.0)
	var scroll := ScrollContainer.new()
	scroll.name = "WorldMapScroll"
	scroll.position = Vector2(28, 104)
	scroll.size = Vector2(304, 468)
	world_popup.add_child(scroll)

	var content := Control.new()
	content.name = "WorldMapContent"
	content.custom_minimum_size = Vector2(304, 12 * 76)
	scroll.add_child(content)

	for i in range(WORLD_MAPS.size()):
		_add_world_map_row(content, WORLD_MAPS[i], i)


func _add_world_map_row(parent: Control, map_data: Dictionary, index: int) -> void:
	var button := Button.new()
	button.name = "Map%s" % str(map_data["key"]).capitalize()
	button.position = Vector2(0, float(index) * 76.0)
	button.size = Vector2(296, 66)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	UI.style_panel_button(button, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
	parent.add_child(button)

	var icon_path := str(map_data.get("icon", ""))
	if icon_path != "" and FileAccess.file_exists(icon_path):
		UI.add_texture(button, icon_path, Vector2(10, 7), Vector2(52, 52), "Icon", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	else:
		_add_placeholder_icon(button, Vector2(12, 9), Vector2(48, 48), "?")

	var status := _text("available") if bool(map_data.get("available", false)) else _text("coming_soon")
	var description := "%s\n%s: %s\n%s" % [
		_text(str(map_data["key"])),
		_text("type"),
		str(map_data["type"]),
		status,
	]
	UI.add_panel_label(button, description, Vector2(72, 7), Vector2(210, 52), 14, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "MapText")

	if bool(map_data.get("available", false)):
		button.pressed.connect(Callable(self, "_open_forest_map"))
	else:
		button.pressed.connect(Callable(self, "_show_map_soon"))


func _open_forest_map() -> void:
	get_tree().change_scene_to_file("res://scenes/ForestMap.tscn")


func _show_map_soon() -> void:
	UI.show_message_popup(self, _text("world_map"), _text("map_soon"))


func _show_bag() -> void:
	InventoryManager.ensure_default_inventory()
	if bag_popup != null and is_instance_valid(bag_popup):
		bag_popup.queue_free()

	selected_bag_item = {}
	bag_popup = _create_popup(_text("bag"), "BagPopup", 42.0, 560.0)
	_add_category_tabs(bag_popup, selected_bag_category, Callable(self, "_select_bag_category"), 102.0)
	_add_bag_items()
	_add_bag_description()


func _select_bag_category(category: String) -> void:
	selected_bag_category = category
	_show_bag()


func _add_bag_items() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "BagItemsScroll"
	scroll.position = Vector2(28, 146)
	scroll.size = Vector2(304, 250)
	bag_popup.add_child(scroll)

	var category_items := _items_for_category(selected_bag_category)
	var content := Control.new()
	content.name = "BagItems"
	content.custom_minimum_size = Vector2(304, max(250, category_items.size() * 60))
	scroll.add_child(content)

	for i in range(category_items.size()):
		var item: Dictionary = category_items[i]
		_add_bag_item_row(content, item, i)


func _add_bag_item_row(parent: Control, item: Dictionary, index: int) -> void:
	var amount := InventoryManager.get_item_amount(str(item.get("id", "")))
	var row := Button.new()
	row.name = "Bag%s" % str(item.get("id", "")).capitalize()
	row.position = Vector2(0, float(index) * 60.0)
	row.size = Vector2(296, 52)
	row.focus_mode = Control.FOCUS_NONE
	row.add_theme_color_override("font_color", UI.PANEL_TEXT)
	row.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	row.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	row.modulate = Color(1, 1, 1, 1) if amount > 0 else Color(0.62, 0.67, 0.72, 1)
	UI.style_panel_button(row, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
	parent.add_child(row)
	_add_item_icon(row, item, Vector2(10, 8), Vector2(36, 36))
	UI.add_panel_label(row, _item_name(item), Vector2(54, 6), Vector2(168, 22), 14, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	UI.add_panel_label(row, "%s: %d" % [_text("quantity"), amount], Vector2(54, 28), Vector2(168, 18), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Qty")
	UI.add_panel_label(row, ">", Vector2(256, 14), Vector2(24, 24), 17, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Arrow")
	row.pressed.connect(Callable(self, "_select_bag_item").bind(item))


func _add_bag_description() -> void:
	var panel := Panel.new()
	panel.name = "BagDescription"
	panel.position = Vector2(28, 410)
	panel.size = Vector2(304, 84)
	bag_popup.add_child(panel)
	UI.style_panel_button(panel, Color(0.88, 0.94, 0.98), Color(0.34, 0.50, 0.62), 2)
	bag_description_label = UI.add_panel_label(panel, _text("select_item"), Vector2(12, 8), Vector2(280, 68), 13, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Description")

	bag_use_button = UI.add_orange_button(bag_popup, _text("use"), Vector2(110, 512), Vector2(140, 44), Callable(self, "_use_selected_bag_item"), "UseItem")
	bag_use_button.disabled = true
	bag_use_button.modulate = Color(0.62, 0.62, 0.62, 0.9)


func _select_bag_item(item: Dictionary) -> void:
	selected_bag_item = item.duplicate(true)
	if bag_description_label != null and is_instance_valid(bag_description_label):
		var amount := InventoryManager.get_item_amount(str(item.get("id", "")))
		bag_description_label.text = "%s\n%s: %d\n%s" % [_item_name(item), _text("quantity"), amount, _item_description(item)]
	if bag_use_button != null and is_instance_valid(bag_use_button):
		bag_use_button.disabled = false
		bag_use_button.modulate = Color.WHITE


func _use_selected_bag_item() -> void:
	if selected_bag_item.is_empty():
		return

	var item_id := str(selected_bag_item.get("id", ""))
	var category := str(selected_bag_item.get("category", ""))
	if item_id == "town_map":
		_show_world_map()
		return

	if item_id.ends_with("_rod"):
		UI.show_message_popup(self, _item_name(selected_bag_item), _text("fishing_soon"))
		return

	match category:
		"pokeballs":
			UI.show_message_popup(self, _item_name(selected_bag_item), _text("pokeball_use"))
		"potions":
			UI.show_message_popup(self, _item_name(selected_bag_item), _text("potion_use"))
		"evolution":
			UI.show_message_popup(self, _item_name(selected_bag_item), _text("evolution_use"))
		_:
			UI.show_message_popup(self, _item_name(selected_bag_item), _text("coming_soon"))


func _show_shop() -> void:
	_refresh_save_data()
	if shop_popup != null and is_instance_valid(shop_popup):
		shop_popup.queue_free()

	shop_popup = _create_popup(_text("shop"), "ShopPopup", 34.0, 580.0)
	UI.add_panel_label(shop_popup, "%s: $%d" % [_text("money"), int(save_data.get("money", 3000))], Vector2(42, 92), Vector2(276, 24), 16, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Money")
	_add_category_tabs(shop_popup, selected_shop_category, Callable(self, "_select_shop_category"), 126.0)
	_add_shop_items()


func _select_shop_category(category: String) -> void:
	selected_shop_category = category
	_show_shop()


func _add_shop_items() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "ShopItemsScroll"
	scroll.position = Vector2(28, 170)
	scroll.size = Vector2(304, 402)
	shop_popup.add_child(scroll)

	var shop_items := []
	for item in _items_for_category(selected_shop_category):
		if int(item.get("price", 0)) > 0:
			shop_items.append(item)

	var content := Control.new()
	content.name = "ShopItems"
	content.custom_minimum_size = Vector2(304, max(402, shop_items.size() * 92))
	scroll.add_child(content)

	for i in range(shop_items.size()):
		var item: Dictionary = shop_items[i]
		_add_shop_item_row(content, item, i)


func _add_shop_item_row(parent: Control, item: Dictionary, index: int) -> void:
	var player_level := int(save_data.get("level", 0))
	var player_badges := int(save_data.get("badges", 0))
	var min_level := int(item.get("min_level", 0))
	var min_badges := int(item.get("min_badges", 0))
	var locked := min_level > player_level or min_badges > player_badges
	var row := Panel.new()
	row.name = "Shop%s" % str(item.get("id", "")).capitalize()
	row.position = Vector2(0, float(index) * 92.0)
	row.size = Vector2(296, 84)
	parent.add_child(row)
	row.modulate = Color(1, 1, 1, 1) if not locked else Color(0.66, 0.70, 0.75, 1)
	UI.style_panel_button(row, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)

	_add_item_icon(row, item, Vector2(10, 10), Vector2(38, 38))
	UI.add_panel_label(row, _item_name(item), Vector2(56, 6), Vector2(158, 20), 14, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	UI.add_panel_label(row, "%s: $%d" % [_text("price"), int(item.get("price", 0))], Vector2(56, 28), Vector2(158, 18), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Price")

	var status := _text("locked") if locked else _text("available_status")
	var requirement := _text("requires") % [min_level, min_badges]
	UI.add_panel_label(row, "%s\n%s" % [status, requirement], Vector2(56, 48), Vector2(166, 30), 11, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Requirement")

	var buy_button := _add_small_button(row, _text("buy"), Vector2(222, 26), Vector2(64, 32), Callable(self, "_buy_item").bind(item), "Buy")
	if locked:
		buy_button.disabled = true
		buy_button.modulate = Color(0.55, 0.55, 0.55, 0.9)


func _buy_item(item: Dictionary) -> void:
	var price := int(item.get("price", 0))
	var money := int(save_data.get("money", 3000))
	if money < price:
		UI.show_message_popup(self, _text("shop"), _text("not_enough_money"))
		return

	var item_id := str(item.get("id", ""))
	SaveManager.update_current_save({"money": money - price})
	InventoryManager.add_item(item_id, 1)
	_refresh_save_data()
	_refresh_home_stats()
	_show_shop()
	UI.show_message_popup(self, _text("shop"), _text("bought") % _item_name(item))


func _show_tournament() -> void:
	if tournament_popup != null and is_instance_valid(tournament_popup):
		tournament_popup.queue_free()

	tournament_popup = _create_popup(_text("tournament"), "TournamentPopup", 92.0, 420.0)
	UI.add_panel_label(tournament_popup, _text("tournament_soon"), Vector2(42, 162), Vector2(276, 52), 15, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Message")
	_add_tournament_card(tournament_popup, _text("beginner_cup"), 230.0)
	_add_tournament_card(tournament_popup, _text("forest_cup"), 296.0)
	_add_tournament_card(tournament_popup, _text("master_league"), 362.0)


func _add_tournament_card(parent: Control, title: String, y: float) -> void:
	var panel := Panel.new()
	panel.name = title.replace(" ", "")
	panel.position = Vector2(42, y)
	panel.size = Vector2(276, 54)
	parent.add_child(panel)
	UI.style_panel_button(panel, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
	UI.add_panel_label(panel, title, Vector2(12, 6), Vector2(170, 20), 15, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Title")
	UI.add_panel_label(panel, _text("coming_soon"), Vector2(12, 28), Vector2(170, 18), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Status")
	UI.add_texture(panel, "res://assets/icons/icon_trophy_32.png", Vector2(226, 11), Vector2(32, 32), "Icon", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)


func _show_my_pokemon() -> void:
	UI.show_message_popup(self, _text("my_pokemon"), _text("my_pokemon_soon"))


func _show_pokedex() -> void:
	UI.show_message_popup(self, _text("pokedex"), _text("pokedex_soon"))


func _show_options() -> void:
	UI.show_options_popup(self, _text("options"), _options_labels(), Callable(self, "_on_options_applied"))


func _on_options_applied(new_settings: Dictionary) -> void:
	settings = new_settings
	call_deferred("_rebuild_screen")


func _rebuild_screen() -> void:
	for child in get_children():
		child.queue_free()
	_refresh_save_data()
	_build_screen()


func _confirm_exit() -> void:
	var on_yes = func():
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	UI.show_confirm_popup(self, _text("exit"), _text("return_menu"), _text("yes"), _text("no"), on_yes)


func _create_popup(title: String, popup_name: String, panel_y: float, panel_height: float) -> Control:
	var overlay := Control.new()
	overlay.name = popup_name
	overlay.position = Vector2.ZERO
	overlay.size = UI.SCREEN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = UI.SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.42)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)

	UI.add_texture(overlay, UI.POPUP_PANEL, Vector2(15, panel_y), Vector2(330, panel_height), "Panel", TextureRect.STRETCH_SCALE)
	UI.add_panel_label(overlay, title, Vector2(50, panel_y + 26.0), Vector2(260, 34), 23, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Title")
	var close := UI.add_icon_button(overlay, "res://assets/icons/icon_close_32.png", Vector2(298, panel_y + 20.0), Callable(), "Close")
	close.pressed.connect(func():
		overlay.queue_free()
	)
	return overlay


func _add_category_tabs(parent: Control, selected_category: String, callback: Callable, y: float) -> void:
	for i in range(CATEGORIES.size()):
		var category := str(CATEGORIES[i])
		var tab := _add_small_button(parent, _text(category), Vector2(20.0 + float(i) * 80.0, y), Vector2(76, 32), callback.bind(category), "Tab%s" % category.capitalize())
		var selected := selected_category == category
		UI.style_panel_button(tab, Color(0.95, 0.78, 0.32) if selected else Color(0.82, 0.88, 0.94), Color(0.92, 0.46, 0.08) if selected else Color(0.36, 0.50, 0.62), 2)


func _add_small_button(parent: Node, text: String, pos: Vector2, node_size: Vector2, callback: Callable, node_name: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.position = pos
	button.size = node_size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	UI.style_panel_button(button, Color(0.95, 0.78, 0.32), Color(0.92, 0.46, 0.08), 2)
	parent.add_child(button)
	if callback.is_valid():
		button.pressed.connect(callback)
	return button


func _add_item_icon(parent: Node, item: Dictionary, pos: Vector2, node_size: Vector2) -> void:
	for icon_path in _icon_candidates(item):
		if FileAccess.file_exists(str(icon_path)):
			UI.add_texture(parent, str(icon_path), pos, node_size, "ItemIcon", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
			return

	var item_name := _item_name(item)
	var letter := item_name.substr(0, 1) if item_name.length() > 0 else "?"
	_add_placeholder_icon(parent, pos, node_size, letter)


func _add_placeholder_icon(parent: Node, pos: Vector2, node_size: Vector2, text: String) -> void:
	var placeholder := ColorRect.new()
	placeholder.name = "PlaceholderIcon"
	placeholder.position = pos
	placeholder.size = node_size
	placeholder.color = Color(0.36, 0.50, 0.62)
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(placeholder)
	UI.add_panel_label(parent, text, pos, node_size, 18, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "PlaceholderText")


func _load_items() -> Array:
	var file := FileAccess.open(ITEMS_PATH, FileAccess.READ)
	if file == null:
		return []

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_ARRAY:
		return parsed
	return []


func _items_for_category(category: String) -> Array:
	var filtered := []
	for item in items:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("category", "")) == category:
			filtered.append(item)
	return filtered


func _item_name(item: Dictionary) -> String:
	var language := _language()
	return str(item.get("name_pt" if language == "pt" else "name_en", item.get("id", "")))


func _item_description(item: Dictionary) -> String:
	var language := _language()
	return str(item.get("description_pt" if language == "pt" else "description_en", ""))


func _icon_candidates(item: Dictionary) -> Array:
	var item_id := str(item.get("id", ""))
	var dash_id := item_id.replace("_", "-")
	return [
		str(item.get("icon_path", "")),
		"res://assets/items/%s.png" % item_id,
		"res://assets/items/%s.png" % dash_id,
		"res://assets/pokemon/items/%s.png" % item_id,
		"res://assets/pokemon/items/%s.png" % dash_id,
	]


func _options_labels() -> Dictionary:
	return {
		"music": _text("music"),
		"sfx": _text("sfx"),
		"language": _text("language"),
		"apply": _text("apply"),
		"cancel": _text("cancel"),
	}


func _language() -> String:
	var language := str(settings.get("language", "en"))
	return language if TEXT.has(language) else "en"


func _text(key: String) -> String:
	var language_text: Dictionary = TEXT[_language()]
	var english_text: Dictionary = TEXT["en"]
	return str(language_text.get(key, english_text.get(key, key)))
