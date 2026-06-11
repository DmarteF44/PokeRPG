extends Control

const UI = preload("res://scripts/ui_factory.gd")
const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")
const WorldMapData = preload("res://scripts/world_map_data.gd")

const ITEMS_PATH = "res://data/items.json"
const CATEGORIES = ["pokeballs", "potions", "evolution", "key_items"]
const TEAM_LIMIT = 5
const POKEMON_CENTER_COST = 250
const POKEMON_CENTER_SECONDS = 3
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
		"energy": "Energy",
		"badges_short": "%d badges",
		"explore_world": "Explore World",
		"my_pokemon": "My Pokemon",
		"bag": "Bag",
		"shop": "Shop",
		"pokedex": "PokeDex",
		"tournament": "Tournament",
		"pokemon_menu": "Pokemon",
		"my_team_pokemon": "My Team Pokemon",
		"pokemon_center": "Pokemon Center",
		"heal_team": "Heal Team",
		"healed_team": "Your Pokemon were healed!",
		"center_cost_time": "Cost: $%d | Time: %ds",
		"healing_started": "Healing... %ds",
		"not_enough_money_center": "Not enough money to heal.",
		"empty_slot": "Empty Slot",
		"hp": "HP",
		"xp": "XP",
			"status": "Status",
			"seen_owned": "Seen / Owned",
			"owned": "Owned",
			"seen": "Seen",
			"unknown": "Unknown",
			"starter_tag": "Starter",
			"close": "Close",
		"debug_menu": "Debug Menu",
		"debug_money": "+ $10,000",
		"debug_level": "+ 1 Level",
		"debug_xp": "+ 100 XP",
		"debug_badge": "+ 1 Badge",
		"debug_items": "Add Basic Items",
		"no_active_save": "No active save.",
		"options": "Options",
		"exit": "Exit",
		"exit_to_main_menu": "Exit to Main Menu",
		"profile": "Profile",
		"starter": "Starter",
		"my_pokemon_soon": "My Pokemon coming soon",
		"my_team_pokemon_soon": "My Team Pokemon coming soon",
		"pokedex_soon": "PokeDex coming soon",
		"pokemon_center_soon": "Pokemon Center coming soon",
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
		"type_grass": "Grass",
			"type_fire": "Fire",
			"type_water": "Water",
			"type_poison": "Poison",
			"type_normal": "Normal",
			"type_rock": "Rock",
		"type_ice": "Ice",
		"type_mystery": "Mystery",
		"type_steel": "Steel",
		"type_electric": "Electric",
		"type_ground": "Ground",
		"type_ghost": "Ghost",
		"type_dragon": "Dragon",
		"type_mixed": "Mixed",
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
		"quantity": "Quantity",
		"use": "Use",
		"details": "Details",
		"buy": "Buy",
		"price": "Price",
		"requires": "Requires Lv. %d and %d badges.",
		"available_status": "Available",
		"locked": "Locked",
		"not_enough_money": "Not enough money.",
		"bought": "Bought %s!",
		"select_item": "Select an item to see details.",
		"items_use_hint": "Items can be used during battles, events, or specific menus.",
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
		"tutorial_prompt": "Novo por aqui? Veja o tutorial:",
		"tutorial": "Tutorial / Página Web",
		"tutorial_soon": "Página de tutorial em breve.",
		"money": "Dinheiro",
		"level": "Nv.",
		"energy": "Energia",
		"badges_short": "%d insígnias",
		"explore_world": "Explorar Mundo",
		"my_pokemon": "Meus Pokémon",
		"bag": "Mochila",
		"shop": "Loja",
		"pokedex": "PokéDex",
		"tournament": "Torneio",
		"pokemon_menu": "Pokémon",
		"my_team_pokemon": "Meu Time Pokémon",
		"pokemon_center": "Centro Pokémon",
		"heal_team": "Curar Time",
		"healed_team": "Seus Pokémon foram curados!",
		"center_cost_time": "Custo: $%d | Tempo: %ds",
		"healing_started": "Curando... %ds",
		"not_enough_money_center": "Dinheiro insuficiente para curar.",
		"empty_slot": "Slot Vazio",
		"hp": "HP",
		"xp": "XP",
			"status": "Status",
			"seen_owned": "Visto / Obtido",
			"owned": "Obtido",
			"seen": "Visto",
			"unknown": "Desconhecido",
			"starter_tag": "Inicial",
			"close": "Fechar",
		"debug_menu": "Menu Debug",
		"debug_money": "+ $10.000",
		"debug_level": "+ 1 Nível",
		"debug_xp": "+ 100 XP",
		"debug_badge": "+ 1 Insígnia",
		"debug_items": "Adicionar Itens Básicos",
		"no_active_save": "Nenhum save ativo.",
		"options": "Opções",
		"exit": "Sair",
		"exit_to_main_menu": "Sair para o Menu",
		"profile": "Perfil",
		"starter": "Inicial",
		"my_pokemon_soon": "Meus Pokémon em breve",
		"my_team_pokemon_soon": "Meu Time Pokémon em breve",
		"pokedex_soon": "PokéDex em breve",
		"pokemon_center_soon": "Centro Pokémon em breve",
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
		"type_grass": "Grama",
			"type_fire": "Fogo",
			"type_water": "Água",
			"type_poison": "Veneno",
			"type_normal": "Normal",
			"type_rock": "Pedra",
		"type_ice": "Gelo",
		"type_mystery": "Mistério",
		"type_steel": "Aço",
		"type_electric": "Elétrico",
		"type_ground": "Terra",
		"type_ghost": "Fantasma",
		"type_dragon": "Dragão",
		"type_mixed": "Misto",
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
		"quantity": "Quantidade",
		"use": "Usar",
		"details": "Detalhes",
		"buy": "Comprar",
		"price": "Preço",
		"requires": "Requer Nv. %d e %d insígnias.",
		"available_status": "Disponível",
		"locked": "Bloqueado",
		"not_enough_money": "Dinheiro insuficiente.",
		"bought": "%s comprado!",
		"select_item": "Selecione um item para ver detalhes.",
		"items_use_hint": "Itens poderão ser usados em batalhas, eventos ou menus específicos.",
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

var settings: Dictionary = {}
var save_data: Dictionary = {}
var items: Array = []
var world_popup: Control
var bag_popup: Control
var shop_popup: Control
var tournament_popup: Control
var pokemon_popup: Control
var pokemon_center_popup: Control
var pokemon_center_status_label: Label
var pokemon_center_heal_button: TextureButton
var stats_label: Label
var selected_bag_category := "pokeballs"
var selected_bag_item: Dictionary = {}
var selected_shop_category := "pokeballs"
var bag_description_label: Label
var bag_use_button: TextureButton
var debug_click_count := 0
var debug_click_deadline_msec := 0
var debug_popup: Control
var healing_in_progress := false


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
			"energy_current": 30,
			"energy_max": 30,
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

	stats_label = UI.add_label(self, _stats_text(), Vector2(16, 188), Vector2(328, 24), 12, Color(0.94, 0.97, 1.0), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Stats")
	UI.add_label(self, _text("tutorial_prompt"), Vector2(20, 220), Vector2(320, 24), 14, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TutorialPrompt")
	UI.add_orange_button(self, _text("tutorial"), Vector2(70, 248), Vector2(220, 48), Callable(self, "_show_tutorial"), "Tutorial")
	_add_secret_debug_emoji()


func _add_topbar_icons() -> void:
	var icon_data := [
		["res://assets/ui/icons/icon_world_32.png", Vector2(8, 6), Callable(self, "_show_world_map"), "TopMap", "M"],
		["res://assets/ui/icons/icon_tournament_32.png", Vector2(58, 6), Callable(self, "_show_tournament"), "TopTournament", "T"],
		["res://assets/ui/icons/icon_pokemon.png", Vector2(108, 6), Callable(self, "_show_pokemon_menu"), "TopPokemon", "P"],
		["res://assets/ui/icons/icon_bag_32.png", Vector2(158, 6), Callable(self, "_show_bag"), "TopBag", "B"],
		["res://assets/ui/icons/icon_shop_32.png", Vector2(208, 6), Callable(self, "_show_shop"), "TopShop", "S"],
		["res://assets/ui/icons/icon_profile_32.png", Vector2(258, 6), Callable(self, "_show_profile"), "TopUser", "U"],
		["res://assets/ui/icons/icon_options_32.png", Vector2(318, 6), Callable(self, "_show_options"), "TopGear", "O"],
	]

	for data in icon_data:
		var icon_pos: Vector2 = data[1]
		var icon_callback: Callable = data[2]
		_add_topbar_icon(str(data[0]), icon_pos, icon_callback, str(data[3]), str(data[4]))


func _add_topbar_icon(icon_path: String, pos: Vector2, callback: Callable, node_name: String, fallback_text: String) -> void:
	if FileAccess.file_exists(icon_path):
		UI.add_icon_button(self, icon_path, pos, callback, node_name)
		return

	var button := Button.new()
	button.name = node_name
	button.text = fallback_text
	button.position = pos
	button.size = Vector2(32, 32)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	UI.style_panel_button(button, Color(0.24, 0.52, 0.66), Color(0.08, 0.24, 0.34), 1)
	add_child(button)
	if callback.is_valid():
		button.pressed.connect(callback)


func _stats_text() -> String:
	return "%s: $%d  |  %s %d  |  %s  |  %s %d/%d" % [
		_text("money"),
		int(save_data.get("money", 3000)),
		_text("level"),
		int(save_data.get("level", 0)),
		_text("badges_short") % int(save_data.get("badges", 0)),
		_text("energy"),
		int(save_data.get("energy_current", 30)),
		int(save_data.get("energy_max", 30)),
	]


func _refresh_home_stats() -> void:
	if stats_label != null and is_instance_valid(stats_label):
		stats_label.text = _stats_text()


func _show_tutorial() -> void:
	UI.show_message_popup(self, _text("tutorial"), _text("tutorial_soon"))


func _show_profile() -> void:
	_refresh_save_data()
	var player_name := str(save_data.get("player_name", _text("player_default")))
	var profile_text := "%s\n%s: %s\n%s: $%d\n%s %d\n%s" % [
		player_name,
		_text("starter"),
		str(save_data.get("starter_name", "Charmander")),
		_text("money"),
		int(save_data.get("money", 3000)),
		_text("level"),
		int(save_data.get("level", 0)),
		_text("badges_short") % int(save_data.get("badges", 0)),
	]
	UI.show_message_popup(self, _text("profile"), profile_text)


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
	var world_maps := WorldMapData.maps()
	content.custom_minimum_size = Vector2(304, world_maps.size() * 76)
	scroll.add_child(content)

	for i in range(world_maps.size()):
		_add_world_map_row(content, world_maps[i], i)


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

	var icon_path := _map_thumbnail_path(map_data)
	if icon_path != "" and FileAccess.file_exists(icon_path):
		UI.add_texture(button, icon_path, Vector2(10, 7), Vector2(52, 52), "Icon", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	else:
		_add_map_thumbnail_placeholder(button, str(map_data["key"]), Vector2(10, 7), Vector2(52, 52))

	var unlocked := WorldMapData.meets_requirements(save_data, map_data)
	var status := _text("available_status") if unlocked else _text("requires") % [int(map_data.get("min_level", 1)), int(map_data.get("min_badges", 0))]
	var description := "%s\n%s: %s\n%s" % [
		_text(str(map_data["key"])),
		_text("type"),
		_text(str(map_data.get("type_key", ""))),
		status,
	]
	var label := UI.add_panel_label(button, description, Vector2(72, 7), Vector2(210, 52), 12 if not unlocked else 14, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "MapText")
	label.clip_text = true

	if unlocked:
		button.pressed.connect(Callable(self, "_open_world_map").bind(str(map_data.get("key", "forest"))))
	else:
		button.disabled = true
		button.modulate = Color(0.62, 0.67, 0.72, 1)


func _open_world_map(map_key: String) -> void:
	SaveManager.update_current_save({"current_map": map_key, "current_scene": "ForestMap"})
	get_tree().change_scene_to_file("res://scenes/ForestMap.tscn")


func _show_map_soon() -> void:
	UI.show_message_popup(self, _text("world_map"), _text("map_soon"))


func _show_bag() -> void:
	InventoryManager.ensure_default_inventory()
	_refresh_save_data()
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
	scroll.size = Vector2(304, 242)
	bag_popup.add_child(scroll)

	var category_items := _items_for_category(selected_bag_category)
	var content := Control.new()
	content.name = "BagItems"
	content.custom_minimum_size = Vector2(304, max(242, category_items.size() * 70))
	scroll.add_child(content)

	for i in range(category_items.size()):
		var item: Dictionary = category_items[i]
		_add_bag_item_row(content, item, i)


func _add_bag_item_row(parent: Control, item: Dictionary, index: int) -> void:
	var amount := InventoryManager.get_item_amount(str(item.get("id", "")))
	var row := Button.new()
	row.name = "Bag%s" % str(item.get("id", "")).capitalize()
	row.position = Vector2(0, float(index) * 70.0)
	row.size = Vector2(296, 62)
	row.focus_mode = Control.FOCUS_NONE
	row.add_theme_color_override("font_color", UI.PANEL_TEXT)
	row.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	row.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	row.modulate = Color(1, 1, 1, 1) if amount > 0 else Color(0.62, 0.67, 0.72, 1)
	UI.style_panel_button(row, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
	parent.add_child(row)
	_add_item_icon(row, item, Vector2(10, 11), Vector2(40, 40))
	UI.add_panel_label(row, _item_name(item), Vector2(58, 6), Vector2(160, 20), 14, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	UI.add_panel_label(row, "%s: %d" % [_text("quantity"), amount], Vector2(58, 26), Vector2(160, 16), 11, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Qty")
	UI.add_panel_label(row, _text(str(item.get("category", ""))), Vector2(58, 42), Vector2(160, 16), 10, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Category")
	UI.add_panel_label(row, ">", Vector2(256, 19), Vector2(24, 24), 17, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Arrow")
	row.pressed.connect(Callable(self, "_select_bag_item").bind(item))


func _add_bag_description() -> void:
	var panel := Panel.new()
	panel.name = "BagDescription"
	panel.position = Vector2(28, 398)
	panel.size = Vector2(304, 102)
	bag_popup.add_child(panel)
	UI.style_panel_button(panel, Color(0.88, 0.94, 0.98), Color(0.34, 0.50, 0.62), 2)
	bag_description_label = UI.add_panel_label(panel, "%s\n%s" % [_text("select_item"), _text("items_use_hint")], Vector2(12, 8), Vector2(280, 86), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Description")

	bag_use_button = UI.add_orange_button(bag_popup, _text("details"), Vector2(110, 512), Vector2(140, 44), Callable(self, "_show_selected_bag_item_details"), "DetailsItem")
	bag_use_button.disabled = true
	bag_use_button.modulate = Color(0.62, 0.62, 0.62, 0.9)


func _select_bag_item(item: Dictionary) -> void:
	selected_bag_item = item.duplicate(true)
	if bag_description_label != null and is_instance_valid(bag_description_label):
		var amount := InventoryManager.get_item_amount(str(item.get("id", "")))
		bag_description_label.text = "%s\n%s: %d | %s: %s\n%s\n%s" % [
			_item_name(item),
			_text("quantity"),
			amount,
			_text("type"),
			_text(str(item.get("category", ""))),
			_item_description(item),
			_text("items_use_hint"),
		]
	if bag_use_button != null and is_instance_valid(bag_use_button):
		bag_use_button.disabled = false
		bag_use_button.modulate = Color.WHITE


func _show_selected_bag_item_details() -> void:
	if selected_bag_item.is_empty():
		return

	var amount := InventoryManager.get_item_amount(str(selected_bag_item.get("id", "")))
	UI.show_message_popup(self, _item_name(selected_bag_item), "%s: %d\n%s\n%s" % [
		_text("quantity"),
		amount,
		_item_description(selected_bag_item),
		_text("items_use_hint"),
	])


func _show_shop() -> void:
	_refresh_save_data()
	if shop_popup != null and is_instance_valid(shop_popup):
		shop_popup.queue_free()

	shop_popup = _create_popup(_text("shop"), "ShopPopup", 34.0, 580.0)
	_add_texture_if_exists(shop_popup, "res://assets/shop/shop_sign_220x80.png", Vector2(36, 78), Vector2(110, 40), "ShopSign")
	_add_texture_if_exists(shop_popup, "res://assets/shop/shop_clerk_128.png", Vector2(284, 78), Vector2(40, 40), "ShopClerk")
	UI.add_panel_label(shop_popup, "%s: $%d" % [_text("money"), int(save_data.get("money", 3000))], Vector2(142, 92), Vector2(140, 24), 15, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Money")
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
	content.custom_minimum_size = Vector2(304, max(402, shop_items.size() * 112))
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
	row.position = Vector2(0, float(index) * 112.0)
	row.size = Vector2(296, 104)
	parent.add_child(row)
	row.modulate = Color(1, 1, 1, 1) if not locked else Color(0.66, 0.70, 0.75, 1)
	UI.style_panel_button(row, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)

	_add_item_icon(row, item, Vector2(10, 10), Vector2(42, 42))
	UI.add_panel_label(row, _item_name(item), Vector2(58, 6), Vector2(154, 20), 14, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	UI.add_panel_label(row, _item_description(item), Vector2(58, 26), Vector2(156, 30), 10, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Description")
	UI.add_panel_label(row, "%s: $%d" % [_text("price"), int(item.get("price", 0))], Vector2(58, 56), Vector2(154, 18), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Price")

	var status := _text("locked") if locked else _text("available_status")
	var requirement := _text("requires") % [min_level, min_badges]
	UI.add_panel_label(row, "%s\n%s" % [status, requirement], Vector2(58, 74), Vector2(166, 26), 10, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Requirement")

	var buy_button := _add_small_button(row, _text("buy"), Vector2(222, 34), Vector2(64, 32), Callable(self, "_buy_item").bind(item), "Buy")
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


func _show_pokemon_menu() -> void:
	if pokemon_popup != null and is_instance_valid(pokemon_popup):
		pokemon_popup.queue_free()

	pokemon_popup = _create_popup(_text("pokemon_menu"), "PokemonMenuPopup", 92.0, 420.0)
	UI.add_orange_button(pokemon_popup, _text("my_pokemon"), Vector2(70, 168), Vector2(220, 48), Callable(self, "_show_my_pokemon"), "MyPokemon")
	UI.add_orange_button(pokemon_popup, _text("my_team_pokemon"), Vector2(70, 228), Vector2(220, 48), Callable(self, "_show_my_team_pokemon"), "MyTeamPokemon")
	UI.add_orange_button(pokemon_popup, _text("pokedex"), Vector2(70, 288), Vector2(220, 48), Callable(self, "_show_pokedex"), "PokeDex")
	UI.add_orange_button(pokemon_popup, _text("pokemon_center"), Vector2(70, 348), Vector2(220, 48), Callable(self, "_show_pokemon_center"), "PokemonCenter")


func _show_my_pokemon() -> void:
	_close_pokemon_popup()
	var popup := _create_popup(_text("my_pokemon"), "MyPokemonPopup", 72.0, 480.0)
	var pokemon := _first_owned_pokemon()
	if pokemon.is_empty():
		UI.add_panel_label(popup, _text("empty_slot"), Vector2(42, 180), Vector2(276, 40), 16, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Empty")
		return

	_add_pokemon_card(popup, pokemon, Vector2(42, 150), Vector2(276, 148), true, true)


func _show_my_team_pokemon() -> void:
	_close_pokemon_popup()
	var popup := _create_popup(_text("my_team_pokemon"), "MyTeamPokemonPopup", 34.0, 580.0)
	var team := _team()
	for slot in range(TEAM_LIMIT):
		var y := 112.0 + float(slot) * 82.0
		if slot < team.size():
			_add_pokemon_card(popup, team[slot], Vector2(42, y), Vector2(276, 74), false, false)
		else:
			_add_empty_team_slot(popup, slot + 1, y, 74.0)


func _show_pokedex() -> void:
	_close_pokemon_popup()
	var popup := _create_popup(_text("pokedex"), "PokeDexPopup", 34.0, 580.0)
	var scroll := ScrollContainer.new()
	scroll.name = "PokeDexScroll"
	scroll.position = Vector2(28, 104)
	scroll.size = Vector2(304, 468)
	popup.add_child(scroll)

	var starter_ids := PokemonHelpers.starter_ids()
	var content := Control.new()
	content.name = "PokeDexContent"
	content.custom_minimum_size = Vector2(304, starter_ids.size() * 168)
	scroll.add_child(content)

	for i in range(starter_ids.size()):
		_add_pokedex_entry(content, str(starter_ids[i]), i)


func _show_pokemon_center() -> void:
	_close_pokemon_popup()
	pokemon_center_popup = _create_popup(_text("pokemon_center"), "PokemonCenterPopup", 34.0, 580.0)
	var team := _team()
	for slot in range(TEAM_LIMIT):
		var y := 112.0 + float(slot) * 78.0
		if slot < team.size():
			_add_pokemon_card(pokemon_center_popup, team[slot], Vector2(42, y), Vector2(276, 70), false, false)
		else:
			_add_empty_team_slot(pokemon_center_popup, slot + 1, y, 70.0)
	pokemon_center_status_label = UI.add_panel_label(
		pokemon_center_popup,
		_text("center_cost_time") % [POKEMON_CENTER_COST, POKEMON_CENTER_SECONDS],
		Vector2(42, 500),
		Vector2(276, 36),
		11,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		"CenterStatus"
	)
	pokemon_center_status_label.clip_text = true
	pokemon_center_heal_button = UI.add_orange_button(pokemon_center_popup, _text("heal_team"), Vector2(70, 552), Vector2(220, 48), Callable(self, "_heal_team"), "HealTeam")
	_set_center_heal_enabled(not healing_in_progress)


func _team() -> Array:
	_refresh_save_data()
	var team_value = save_data.get("team", [])
	if typeof(team_value) == TYPE_ARRAY:
		return team_value
	return []


func _first_owned_pokemon() -> Dictionary:
	var team := _team()
	if not team.is_empty() and typeof(team[0]) == TYPE_DICTIONARY:
		return team[0]
	var starter_id := str(save_data.get("starter_id", PokemonHelpers.id_from_name(str(save_data.get("starter_name", "Charmander")))))
	return PokemonHelpers.starter_save_data(starter_id)


func _add_pokemon_card(parent: Control, pokemon: Dictionary, pos: Vector2, node_size: Vector2, show_starter: bool, show_dex: bool) -> void:
	var panel := Panel.new()
	panel.name = str(pokemon.get("name", "Charmander")).replace(" ", "")
	panel.position = pos
	panel.size = node_size
	parent.add_child(panel)
	UI.style_panel_button(panel, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)

	var compact := node_size.y < 90.0
	var sprite_size := Vector2(64, 64) if not compact else Vector2(48, 48)
	PokemonHelpers.add_animated_sprite(panel, pokemon, Vector2(12, 10), sprite_size, false, "PokemonSprite")
	var types := _pokemon_types_text(pokemon)
	var name := str(pokemon.get("name", "Charmander"))
	var dex_number := int(pokemon.get("dex_number", 4))
	var level := int(pokemon.get("level", 5))
	var hp := int(pokemon.get("hp", 39))
	var max_hp := int(pokemon.get("max_hp", 39))
	var xp := int(pokemon.get("xp", 0))
	var title := "#%03d %s  %s %d" % [dex_number, name, _text("level"), level] if show_dex else "%s  %s %d" % [name, _text("level"), level]
	var title_font := 13 if compact else 16
	var title_label := UI.add_panel_label(panel, title, Vector2(76, 7), Vector2(188, 22), title_font, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	_fit_label(title_label, false)
	var info_text := ""
	var info_pos := Vector2(76, 31)
	var info_size := Vector2(188, node_size.y - 35.0)
	var info_font := 10 if compact else 11
	if compact:
		info_text = "%s: %d/%d   %s: %d\n%s" % [_text("hp"), hp, max_hp, _text("xp"), xp, types]
	else:
		info_text = "%s: %s\n%s: %d/%d   %s: %d" % [_text("type"), types, _text("hp"), hp, max_hp, _text("xp"), xp]
		info_pos = Vector2(76, 34)
		info_size = Vector2(188, node_size.y - 44.0)
	var info_label := UI.add_panel_label(panel, info_text, info_pos, info_size, info_font, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Info")
	_fit_label(info_label, true)
	if not compact and (show_starter or bool(pokemon.get("starter", false))):
		UI.add_panel_label(panel, _text("starter_tag"), Vector2(180, node_size.y - 24.0), Vector2(80, 18), 10, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Starter")


func _add_empty_team_slot(parent: Control, slot: int, y: float, slot_height: float) -> void:
	var panel := Panel.new()
	panel.name = "EmptySlot%d" % slot
	panel.position = Vector2(42, y)
	panel.size = Vector2(276, slot_height)
	parent.add_child(panel)
	UI.style_panel_button(panel, Color(0.72, 0.78, 0.84), Color(0.34, 0.50, 0.62), 2)
	UI.add_panel_label(panel, "%s %d" % [_text("empty_slot"), slot], Vector2(12, 0), Vector2(252, slot_height), 15, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Empty")


func _add_pokedex_entry(parent: Control, pokemon_id: String, index: int) -> void:
	var definition := PokemonHelpers.get_definition(pokemon_id)
	var panel := Panel.new()
	panel.name = "%sDex" % str(definition.get("name", "Pokemon"))
	panel.position = Vector2(0, float(index) * 168.0)
	panel.size = Vector2(296, 158)
	parent.add_child(panel)
	UI.style_panel_button(panel, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)

	PokemonHelpers.add_animated_sprite(panel, definition, Vector2(12, 18), Vector2(58, 58), false, "DexSprite")
	var dex_number := int(definition.get("dex_number", 0))
	var pokemon_name := str(definition.get("name", "Pokemon"))
	var name_label := UI.add_panel_label(panel, "#%03d %s" % [dex_number, pokemon_name], Vector2(84, 12), Vector2(190, 22), 16, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	_fit_label(name_label, false)
	var info_label := UI.add_panel_label(panel, "%s: %s\n%s: %s" % [_text("type"), _pokemon_types_text(definition), _text("status"), _pokedex_status(pokemon_id)], Vector2(84, 38), Vector2(190, 42), 11, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Info")
	_fit_label(info_label, true)
	var description_label := UI.add_panel_label(panel, _pokemon_description(definition), Vector2(12, 84), Vector2(272, 62), 10, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Description")
	_fit_label(description_label, true)


func _fit_label(label: Label, wrap: bool) -> void:
	label.clip_text = true
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


func _pokemon_types_text(pokemon: Dictionary) -> String:
	var types_value = pokemon.get("types", ["Fire"])
	if typeof(types_value) != TYPE_ARRAY:
		return _text("type_fire")

	var translated := []
	for type_name in types_value:
		var type_key := "type_%s" % str(type_name).to_lower()
		translated.append(_text(type_key))
	return ", ".join(translated)


func _pokedex_status(pokemon_id: String) -> String:
	if _owned_pokemon_ids().has(pokemon_id):
		return _text("owned")
	if _seen_pokemon_ids().has(pokemon_id):
		return _text("seen")
	return _text("unknown")


func _pokemon_description(pokemon: Dictionary) -> String:
	var key := "description_pt" if _language() == "pt" else "description_en"
	return str(pokemon.get(key, ""))


func _owned_pokemon_ids() -> Array:
	_refresh_save_data()
	var owned_value = save_data.get("owned_pokemon", [])
	if typeof(owned_value) == TYPE_ARRAY:
		return owned_value
	return [str(save_data.get("starter_id", "charmander"))]


func _seen_pokemon_ids() -> Array:
	_refresh_save_data()
	var seen_value = save_data.get("seen_pokemon", [])
	if typeof(seen_value) == TYPE_ARRAY:
		return seen_value
	return PokemonHelpers.starter_ids()


func _heal_team() -> void:
	if healing_in_progress:
		return

	if not _has_active_save():
		UI.show_message_popup(self, _text("debug_menu"), _text("no_active_save"))
		return

	_refresh_save_data()
	var money := int(save_data.get("money", 3000))
	if money < POKEMON_CENTER_COST:
		_set_center_status(_text("not_enough_money_center"))
		return

	healing_in_progress = true
	_set_center_heal_enabled(false)
	SaveManager.update_current_save({"money": money - POKEMON_CENTER_COST})
	_refresh_save_data()
	_refresh_home_stats()

	for remaining in range(POKEMON_CENTER_SECONDS, 0, -1):
		_set_center_status(_text("healing_started") % remaining)
		await get_tree().create_timer(1.0).timeout

	var team := _team()
	for i in range(team.size()):
		if typeof(team[i]) == TYPE_DICTIONARY:
			var pokemon: Dictionary = team[i]
			pokemon["hp"] = int(pokemon.get("max_hp", 39))
			team[i] = pokemon
	SaveManager.update_current_save({"team": team})
	healing_in_progress = false
	_refresh_save_data()
	_refresh_home_stats()
	if pokemon_center_popup != null and is_instance_valid(pokemon_center_popup):
		_show_pokemon_center()
		_set_center_status(_text("healed_team"))
	else:
		UI.show_message_popup(self, _text("pokemon_center"), _text("healed_team"))


func _set_center_status(text: String) -> void:
	if pokemon_center_status_label != null and is_instance_valid(pokemon_center_status_label):
		pokemon_center_status_label.text = text


func _set_center_heal_enabled(enabled: bool) -> void:
	if pokemon_center_heal_button == null or not is_instance_valid(pokemon_center_heal_button):
		return
	pokemon_center_heal_button.disabled = not enabled
	pokemon_center_heal_button.modulate = Color(1, 1, 1, 1) if enabled else Color(0.62, 0.62, 0.62, 0.9)


func _close_pokemon_popup() -> void:
	if pokemon_popup != null and is_instance_valid(pokemon_popup):
		pokemon_popup.queue_free()
	if pokemon_center_popup != null and is_instance_valid(pokemon_center_popup):
		pokemon_center_popup.queue_free()
	pokemon_center_popup = null
	pokemon_center_status_label = null
	pokemon_center_heal_button = null


func _add_secret_debug_emoji() -> void:
	var button := Button.new()
	button.name = "SecretDebug"
	button.text = "✨"
	button.position = Vector2(332, 606)
	button.size = Vector2(22, 22)
	button.focus_mode = Control.FOCUS_NONE
	button.flat = true
	button.modulate = Color(1, 1, 1, 0.48)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	add_child(button)
	button.pressed.connect(Callable(self, "_on_secret_debug_pressed"))


func _on_secret_debug_pressed() -> void:
	var now := Time.get_ticks_msec()
	if now > debug_click_deadline_msec:
		debug_click_count = 0
	debug_click_count += 1
	debug_click_deadline_msec = now + 5000
	if debug_click_count >= 4:
		debug_click_count = 0
		debug_click_deadline_msec = 0
		_show_debug_menu()


func _show_debug_menu() -> void:
	if not _has_active_save():
		UI.show_message_popup(self, _text("debug_menu"), _text("no_active_save"))
		return

	if debug_popup != null and is_instance_valid(debug_popup):
		debug_popup.queue_free()

	debug_popup = _create_popup(_text("debug_menu"), "DebugPopup", 72.0, 480.0)
	UI.add_orange_button(debug_popup, _text("debug_money"), Vector2(70, 148), Vector2(220, 48), Callable(self, "_debug_add_money"), "DebugMoney")
	UI.add_orange_button(debug_popup, _text("debug_level"), Vector2(70, 204), Vector2(220, 48), Callable(self, "_debug_add_level"), "DebugLevel")
	UI.add_orange_button(debug_popup, _text("debug_xp"), Vector2(70, 260), Vector2(220, 48), Callable(self, "_debug_add_xp"), "DebugXP")
	UI.add_orange_button(debug_popup, _text("debug_badge"), Vector2(70, 316), Vector2(220, 48), Callable(self, "_debug_add_badge"), "DebugBadge")
	UI.add_orange_button(debug_popup, _text("heal_team"), Vector2(70, 372), Vector2(220, 48), Callable(self, "_debug_heal_team"), "DebugHeal")
	_add_small_button(debug_popup, _text("debug_items"), Vector2(42, 430), Vector2(132, 34), Callable(self, "_debug_add_basic_items"), "DebugItems")
	_add_small_button(debug_popup, _text("close"), Vector2(186, 430), Vector2(132, 34), Callable(self, "_close_debug_popup"), "DebugClose")


func _debug_add_money() -> void:
	_update_debug_save({"money": int(save_data.get("money", 3000)) + 10000})


func _debug_add_level() -> void:
	var team := _team()
	for i in range(team.size()):
		if typeof(team[i]) == TYPE_DICTIONARY:
			var pokemon: Dictionary = team[i]
			pokemon["level"] = int(pokemon.get("level", 5)) + 1
			team[i] = pokemon
	_update_debug_save({"level": int(save_data.get("level", 0)) + 1, "team": team})


func _debug_add_xp() -> void:
	var team := _team()
	for i in range(team.size()):
		if typeof(team[i]) == TYPE_DICTIONARY:
			var pokemon: Dictionary = team[i]
			pokemon["xp"] = int(pokemon.get("xp", 0)) + 100
			team[i] = pokemon
	_update_debug_save({"xp": int(save_data.get("xp", 0)) + 100, "team": team})


func _debug_add_badge() -> void:
	_update_debug_save({"badges": min(8, int(save_data.get("badges", 0)) + 1)})


func _debug_heal_team() -> void:
	var team := _team()
	for i in range(team.size()):
		if typeof(team[i]) == TYPE_DICTIONARY:
			var pokemon: Dictionary = team[i]
			pokemon["hp"] = int(pokemon.get("max_hp", 39))
			team[i] = pokemon
	_update_debug_save({"team": team})


func _debug_add_basic_items() -> void:
	var inventory := {}
	var inventory_value = save_data.get("inventory", {})
	if typeof(inventory_value) == TYPE_DICTIONARY:
		inventory = inventory_value.duplicate(true)
	inventory["poke_ball"] = int(inventory.get("poke_ball", 0)) + 10
	inventory["potion"] = int(inventory.get("potion", 0)) + 10
	inventory["great_ball"] = int(inventory.get("great_ball", 0)) + 5
	_update_debug_save({"inventory": inventory})


func _update_debug_save(changes: Dictionary) -> void:
	if not _has_active_save():
		UI.show_message_popup(self, _text("debug_menu"), _text("no_active_save"))
		return

	SaveManager.update_current_save(changes)
	_refresh_save_data()
	_refresh_home_stats()


func _close_debug_popup() -> void:
	if debug_popup != null and is_instance_valid(debug_popup):
		debug_popup.queue_free()


func _has_active_save() -> bool:
	return not SaveManager.get_current_save().is_empty()


func _show_options() -> void:
	var options_popup := UI.show_options_popup(self, _text("options"), _options_labels(), Callable(self, "_on_options_applied"))
	UI.add_orange_button(options_popup, _text("exit_to_main_menu"), Vector2(70, 454), Vector2(220, 48), Callable(self, "_confirm_exit"), "ExitToMainMenu")


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


func _map_thumbnail_path(map_data: Dictionary) -> String:
	var key := str(map_data.get("key", ""))
	var stem := _map_file_stem(key)
	var candidates := [
		str(map_data.get("thumbnail", "")),
		"res://assets/maps/thumbnails/%s_96x64.png" % stem,
		"res://assets/maps/thumbnails/%s.png" % stem,
		"res://assets/maps/%s_96x64.png" % stem,
		"res://assets/maps/%s.png" % stem,
		"res://assets/map/%s_96x64.png" % stem,
		"res://assets/map/%s.png" % stem,
		"res://assets_raw/%s_96x64.png" % stem,
		"res://assets_raw/%s.png" % stem,
		str(map_data.get("icon", "")),
	]

	for candidate in candidates:
		if str(candidate) != "" and FileAccess.file_exists(str(candidate)):
			return str(candidate)
	return ""


func _map_file_stem(key: String) -> String:
	match key:
		"ghost":
			return "map_ghost_tower"
		"dragon":
			return "map_dragon_valley"
		"safari":
			return "map_safari_zone"
		_:
			return "map_%s" % key


func _add_map_thumbnail_placeholder(parent: Node, key: String, pos: Vector2, node_size: Vector2) -> void:
	var placeholder := ColorRect.new()
	placeholder.name = "MapThumbnail"
	placeholder.position = pos
	placeholder.size = node_size
	placeholder.color = _map_placeholder_color(key)
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(placeholder)

	var band := ColorRect.new()
	band.name = "MapThumbnailBand"
	band.position = pos + Vector2(0, node_size.y - 14.0)
	band.size = Vector2(node_size.x, 14.0)
	band.color = Color(0, 0, 0, 0.28)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(band)

	UI.add_label(parent, _map_placeholder_code(key), pos, node_size, 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "MapThumbnailText")


func _map_placeholder_color(key: String) -> Color:
	match key:
		"water":
			return Color(0.16, 0.48, 0.78)
		"electric":
			return Color(0.95, 0.78, 0.20)
		"desert":
			return Color(0.75, 0.60, 0.34)
		"ghost":
			return Color(0.44, 0.28, 0.62)
		"dragon":
			return Color(0.30, 0.34, 0.78)
		"safari":
			return Color(0.28, 0.62, 0.34)
		_:
			return Color(0.36, 0.50, 0.62)


func _map_placeholder_code(key: String) -> String:
	match key:
		"water":
			return "WA"
		"electric":
			return "EL"
		"desert":
			return "DS"
		"ghost":
			return "GT"
		"dragon":
			return "DR"
		"safari":
			return "SZ"
		_:
			return "MAP"


func _add_placeholder_icon(parent: Node, pos: Vector2, node_size: Vector2, text: String) -> void:
	var placeholder := ColorRect.new()
	placeholder.name = "PlaceholderIcon"
	placeholder.position = pos
	placeholder.size = node_size
	placeholder.color = Color(0.36, 0.50, 0.62)
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(placeholder)
	UI.add_panel_label(parent, text, pos, node_size, 18, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "PlaceholderText")


func _add_texture_if_exists(parent: Node, path: String, pos: Vector2, node_size: Vector2, node_name: String) -> void:
	if FileAccess.file_exists(path):
		UI.add_texture(parent, path, pos, node_size, node_name, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)


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
	var category := str(item.get("category", ""))
	return [
		str(item.get("icon_path", "")),
		"res://assets/items/%s/%s.png" % [category, item_id],
		"res://assets/items/%s/%s.png" % [category, dash_id],
		"res://assets/items/%s/%s_48.png" % [category, item_id],
		"res://assets/items/%s/%s_32.png" % [category, item_id],
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
