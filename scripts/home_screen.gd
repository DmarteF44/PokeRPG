extends Control

const UI = preload("res://scripts/ui_factory.gd")
const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")
const WorldMapData = preload("res://scripts/world_map_data.gd")
const GymData = preload("res://scripts/gym_data.gd")

const ITEMS_PATH = "res://data/items.json"
const CATEGORIES = ["pokeballs", "potions", "evolution", "key_items"]
const TEAM_LIMIT = 5
const POKEMON_CENTER_COST = 250
const POKEMON_CENTER_SECONDS = 3
const DEBUG_CLICK_WINDOW_MSEC = 3000
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
		"my_pokemon": "Storage",
		"bag": "Bag",
		"shop": "Shop",
		"pokedex": "PokeDex",
		"tournament": "Gyms",
		"pokemon_menu": "Pokemon",
		"my_team_pokemon": "My Team Pokemon",
		"pokemon_center": "Pokemon Center",
		"heal_team": "Heal Team",
		"healed_team": "Your Pokemon were healed!",
		"center_cost_time": "Cost: $%d | Recovery: 15/30/60 min",
		"healing_started": "Recovery started.",
		"healing_remaining": "Recovering: %s",
		"pokemon_recovering": "This Pokemon is recovering.",
		"not_enough_money_center": "Not enough money to heal.",
		"storage": "Storage",
		"pokemon_collection": "Pokemon Collection",
		"team_current": "Current Team",
		"selected_pokemon": "Selected Pokemon",
		"nickname": "Nickname",
		"rename": "Rename",
		"clear_nickname": "Clear Nickname",
		"send_to_team": "To Team",
		"send_to_storage": "To Storage",
		"change_move": "Change",
		"available_moves": "Available Moves",
		"ability": "Ability",
		"nature": "Nature",
		"gender": "Gender",
		"held_item": "Held Item",
		"capture_date": "Capture Date",
		"moves": "Moves",
		"description": "Description",
		"none": "None",
		"saved": "Saved.",
		"active": "Active",
		"set_active": "Active",
		"move_up": "Up",
		"move_down": "Down",
		"deposit": "Deposit",
		"withdraw": "Withdraw",
		"search": "Search",
		"sort_level": "Level",
		"sort_name": "Name",
		"sort_dex": "Dex",
		"sort_date": "Date",
		"sort_generation": "Gen",
		"team_full": "Your team is full.",
		"last_pokemon": "You must keep at least one Pokemon in your team.",
		"storage_full": "Storage is full.",
		"storage_empty": "Storage is empty.",
		"empty_slot": "Empty Slot",
		"hp": "HP",
		"xp": "XP",
		"xp_needed": "Need",
			"status": "Status",
			"seen_owned": "Seen / Owned",
			"seen_count": "Seen %d/%d",
			"captured_count": "Captured %d/%d",
			"owned": "Owned",
			"seen": "Seen",
			"unknown": "Unknown",
			"starter_tag": "Starter",
			"close": "Close",
		"debug_menu": "Debug Menu",
		"debug_gold": "Gold",
		"debug_account_xp": "Account XP",
		"debug_badges": "Badges",
		"debug_energy": "Energy",
		"debug_pokemon": "Pokemon",
		"debug_team": "Team",
		"debug_storage": "Storage",
		"debug_add": "+%s",
		"debug_all_badges": "All",
		"debug_remove_badges": "Remove all",
		"debug_restore_energy": "Restore energy",
		"debug_heal_team": "Heal team",
		"debug_clear_status": "Clear status",
		"debug_restore_pp": "Restore PP",
		"debug_add_bulbasaur": "Add Bulbasaur",
		"debug_add_charmander": "Add Charmander",
		"debug_add_squirtle": "Add Squirtle",
		"debug_fill_team": "Fill team",
		"debug_clear_team": "Clear team",
		"debug_clear_storage": "Clear Storage",
		"debug_starters_storage": "Starters to Storage",
		"debug_saved": "Saved.",
		"no_active_save": "No active save.",
		"options": "Options",
		"exit": "Exit",
		"exit_to_main_menu": "Exit to Main Menu",
		"profile": "Profile",
		"starter": "Starter",
		"my_pokemon_soon": "Storage coming soon",
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
		"not_enough_money": "Not enough Gold.",
		"bought": "Bought %s!",
		"energy_full": "Your energy is already full.",
		"energy_restored": "Energy restored by %d.",
		"choose_pokemon": "Choose Pokemon",
		"stat_boosted": "%s gained +%d %s!",
		"stat_at_cap": "%s cannot raise %s anymore.",
		"stat_max_hp": "HP",
		"stat_attack": "Attack",
		"stat_defense": "Defense",
		"stat_sp_attack": "Sp. Attack",
		"stat_sp_defense": "Sp. Defense",
		"stat_speed": "Speed",
		"select_item": "Select an item to see details.",
		"items_use_hint": "Items can be used during battles, events, or specific menus.",
		"pokeball_use": "Pokeballs are used during wild battles.",
		"potion_use": "Healing items will be usable in battle soon.",
		"evolution_use": "Evolution system coming soon.",
		"fishing_soon": "Fishing coming soon.",
		"tournament_soon": "Choose a gym challenge.",
		"beginner_cup": "Pewter City",
		"forest_cup": "Cerulean City",
		"master_league": "Viridian City",
		"gym_leader": "Leader",
		"gym_type": "Type",
		"gym_badge": "Badge",
		"gym_reward": "Reward",
		"gym_trainers": "Battles",
		"gym_completed": "Completed",
		"gym_challenge": "Challenge",
		"gym_locked": "Requires %d badges / Lv. %d",
		"gym_intro": "%s Gym\nLeader: %s\nType: %s",
		"gym_no_ready": "No Pokemon is ready for this gym.",
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
		"my_pokemon": "Storage",
		"bag": "Mochila",
		"shop": "Loja",
		"pokedex": "PokéDex",
		"tournament": "Ginásios",
		"pokemon_menu": "Pokémon",
		"my_team_pokemon": "Meu Time Pokémon",
		"pokemon_center": "Centro Pokémon",
		"heal_team": "Curar Time",
		"healed_team": "Seus Pokémon foram curados!",
		"center_cost_time": "Custo: $%d | Recuperação: 15/30/60 min",
		"healing_started": "Recuperação iniciada.",
		"healing_remaining": "Recuperando: %s",
		"pokemon_recovering": "Este Pokémon está em recuperação.",
		"not_enough_money_center": "Dinheiro insuficiente para curar.",
		"storage": "Storage",
		"pokemon_collection": "Coleção Pokémon",
		"team_current": "Time atual",
		"selected_pokemon": "Pokémon selecionado",
		"nickname": "Apelido",
		"rename": "Renomear",
		"clear_nickname": "Limpar apelido",
		"send_to_team": "Para o time",
		"send_to_storage": "Para Storage",
		"change_move": "Alterar",
		"available_moves": "Golpes disponíveis",
		"ability": "Habilidade",
		"nature": "Nature",
		"gender": "Gênero",
		"held_item": "Held Item",
		"capture_date": "Data de captura",
		"moves": "Golpes",
		"description": "Descrição",
		"none": "Nenhum",
		"saved": "Salvo.",
		"active": "Ativo",
		"set_active": "Ativo",
		"move_up": "Subir",
		"move_down": "Descer",
		"deposit": "Depositar",
		"withdraw": "Retirar",
		"search": "Buscar",
		"sort_level": "Nível",
		"sort_name": "Nome",
		"sort_dex": "Dex",
		"sort_date": "Data",
		"sort_generation": "Gen",
		"team_full": "Seu time está cheio.",
		"last_pokemon": "Você deve manter pelo menos um Pokémon no time.",
		"storage_full": "Storage cheio.",
		"storage_empty": "Storage vazio.",
		"empty_slot": "Slot Vazio",
		"hp": "HP",
		"xp": "XP",
		"xp_needed": "Falta",
			"status": "Status",
			"seen_owned": "Visto / Obtido",
			"seen_count": "Vistos %d/%d",
			"captured_count": "Capturados %d/%d",
			"owned": "Obtido",
			"seen": "Visto",
			"unknown": "Desconhecido",
			"starter_tag": "Inicial",
			"close": "Fechar",
		"debug_menu": "Menu Debug",
		"debug_gold": "Gold",
		"debug_account_xp": "XP da conta",
		"debug_badges": "Insígnias",
		"debug_energy": "Energia",
		"debug_pokemon": "Pokemon",
		"debug_team": "Time",
		"debug_storage": "Storage",
		"debug_add": "+%s",
		"debug_all_badges": "Todas",
		"debug_remove_badges": "Remover todas",
		"debug_restore_energy": "Restaurar energia",
		"debug_heal_team": "Curar time",
		"debug_clear_status": "Remover status",
		"debug_restore_pp": "Restaurar PP",
		"debug_add_bulbasaur": "Adicionar Bulbasaur",
		"debug_add_charmander": "Adicionar Charmander",
		"debug_add_squirtle": "Adicionar Squirtle",
		"debug_fill_team": "Preencher time",
		"debug_clear_team": "Limpar time",
		"debug_clear_storage": "Limpar Storage",
		"debug_starters_storage": "Iniciais no Storage",
		"debug_saved": "Salvo.",
		"no_active_save": "Nenhum save ativo.",
		"options": "Opções",
		"exit": "Sair",
		"exit_to_main_menu": "Sair para o Menu",
		"profile": "Perfil",
		"starter": "Inicial",
		"my_pokemon_soon": "Storage em breve",
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
		"not_enough_money": "Gold insuficiente.",
		"bought": "%s comprado!",
		"energy_full": "Sua energia já está completa.",
		"energy_restored": "Energia restaurada em %d.",
		"choose_pokemon": "Escolha o Pokemon",
		"stat_boosted": "%s ganhou +%d em %s!",
		"stat_at_cap": "%s nao pode aumentar mais %s.",
		"stat_max_hp": "HP",
		"stat_attack": "Ataque",
		"stat_defense": "Defesa",
		"stat_sp_attack": "Ataque Esp.",
		"stat_sp_defense": "Defesa Esp.",
		"stat_speed": "Velocidade",
		"select_item": "Selecione um item para ver detalhes.",
		"items_use_hint": "Itens poderão ser usados em batalhas, eventos ou menus específicos.",
		"pokeball_use": "Pokébolas são usadas em batalhas selvagens.",
		"potion_use": "Itens de cura poderão ser usados em batalha em breve.",
		"evolution_use": "Sistema de evolução em breve.",
		"fishing_soon": "Pescaria em breve.",
		"tournament_soon": "Escolha um desafio de ginásio.",
		"beginner_cup": "Pewter City",
		"forest_cup": "Cerulean City",
		"master_league": "Viridian City",
		"gym_leader": "Líder",
		"gym_type": "Tipo",
		"gym_badge": "Insígnia",
		"gym_reward": "Recompensa",
		"gym_trainers": "Batalhas",
		"gym_completed": "Concluído",
		"gym_challenge": "Desafiar",
		"gym_locked": "Requer %d insígnias / Nv. %d",
		"gym_intro": "Ginásio de %s\nLíder: %s\nTipo: %s",
		"gym_no_ready": "Nenhum Pokémon está pronto para este ginásio.",
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
var storage_popup: Control
var pokemon_center_status_label: Label
var pokemon_center_heal_button: TextureButton
var stats_label: Label
var selected_bag_category := "pokeballs"
var selected_bag_item: Dictionary = {}
var selected_shop_category := "pokeballs"
var bag_description_label: Label
var bag_use_button: TextureButton
var storage_search_text := ""
var storage_sort_mode := "level"
var selected_collection_tab := "team"
var selected_collection_source := "team"
var selected_collection_index := 0
var debug_click_count := 0
var debug_click_deadline_msec := 0
var debug_enabled := true
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
			"level": 1,
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
		max(1, int(save_data.get("level", 1))),
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
		max(1, int(save_data.get("level", 1))),
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
	var amount := InventoryManager.get_item_amount(str(item.get("id", "")))
	if bag_description_label != null and is_instance_valid(bag_description_label):
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
		var effect_type := str(item.get("effect_type", ""))
		var is_usable_item := effect_type == "restore_energy" or effect_type == "stat_boost"
		var text_label := bag_use_button.get_node_or_null("Text") as Label
		if text_label != null:
			text_label.text = _text("use") if is_usable_item else _text("details")
		bag_use_button.disabled = is_usable_item and amount <= 0
		bag_use_button.modulate = Color(0.62, 0.62, 0.62, 0.9) if bag_use_button.disabled else Color.WHITE


func _show_selected_bag_item_details() -> void:
	if selected_bag_item.is_empty():
		return

	var effect_type := str(selected_bag_item.get("effect_type", ""))
	if effect_type == "restore_energy":
		_use_energy_item(selected_bag_item)
		return
	if effect_type == "stat_boost":
		_show_stat_boost_targets(selected_bag_item)
		return

	var amount := InventoryManager.get_item_amount(str(selected_bag_item.get("id", "")))
	UI.show_message_popup(self, _item_name(selected_bag_item), "%s: %d\n%s\n%s" % [
		_text("quantity"),
		amount,
		_item_description(selected_bag_item),
		_text("items_use_hint"),
	])


func _use_energy_item(item: Dictionary) -> void:
	if not _has_active_save():
		UI.show_message_popup(self, _item_name(item), _text("no_active_save"))
		return

	_refresh_save_data()
	var item_id := str(item.get("id", ""))
	if InventoryManager.get_item_amount(item_id) <= 0:
		return

	var energy_max: int = maxi(1, int(save_data.get("energy_max", 30)))
	var energy_current: int = clampi(int(save_data.get("energy_current", energy_max)), 0, energy_max)
	if energy_current >= energy_max:
		UI.show_message_popup(self, _item_name(item), _text("energy_full"))
		return

	var restore_amount: int = maxi(0, int(item.get("effect_value", 0)))
	var next_energy: int = mini(energy_max, energy_current + restore_amount)
	var restored: int = next_energy - energy_current
	if restored <= 0:
		UI.show_message_popup(self, _item_name(item), _text("energy_full"))
		return

	if not InventoryManager.remove_item(item_id, 1):
		return

	SaveManager.update_current_save({"energy_current": next_energy})
	_refresh_save_data()
	_refresh_home_stats()
	_show_bag()
	UI.show_message_popup(self, _item_name(item), _text("energy_restored") % restored)


func _show_stat_boost_targets(item: Dictionary) -> void:
	if not _has_active_save():
		UI.show_message_popup(self, _item_name(item), _text("no_active_save"))
		return

	var item_id := str(item.get("id", ""))
	if InventoryManager.get_item_amount(item_id) <= 0:
		return

	var existing := get_node_or_null("StatBoostTargetPopup")
	if existing != null:
		existing.queue_free()

	var popup := _create_popup(_text("choose_pokemon"), "StatBoostTargetPopup", 92.0, 420.0)
	var stat_key := PokemonHelpers.normalized_stat_key(str(item.get("effect_stat", "")))
	UI.add_panel_label(
		popup,
		"%s\n%s +%d" % [_item_name(item), _stat_name(stat_key), int(item.get("effect_value", PokemonHelpers.STAT_BOOST_AMOUNT))],
		Vector2(42, 154),
		Vector2(276, 44),
		13,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		"BoostInfo"
	)

	var team := _team()
	for i in range(team.size()):
		if typeof(team[i]) != TYPE_DICTIONARY:
			continue
		_add_stat_boost_target_row(popup, team[i], i, 214.0 + float(i) * 56.0, item, stat_key)


func _add_stat_boost_target_row(parent: Control, pokemon: Dictionary, team_index: int, y: float, item: Dictionary, stat_key: String) -> void:
	var row := Panel.new()
	row.name = "BoostTarget%d" % team_index
	row.position = Vector2(42, y)
	row.size = Vector2(276, 48)
	parent.add_child(row)
	UI.style_panel_button(row, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)

	PokemonHelpers.add_animated_sprite(row, pokemon, Vector2(8, 3), Vector2(42, 42), false, "PokemonSprite")
	var value := int(pokemon.get(stat_key, 0))
	var limit := PokemonHelpers.stat_limit(stat_key)
	var name := str(pokemon.get("name", "Pokemon"))
	var name_label := UI.add_panel_label(row, name, Vector2(56, 5), Vector2(110, 18), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	_fit_label(name_label, false)
	UI.add_panel_label(row, "%s: %d/%d" % [_stat_name(stat_key), value, limit], Vector2(56, 25), Vector2(116, 16), 10, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Stat")
	_add_small_button(row, _text("use"), Vector2(198, 9), Vector2(62, 30), Callable(self, "_use_stat_boost_item").bind(item, team_index), "UseBoost")


func _use_stat_boost_item(item: Dictionary, team_index: int) -> void:
	_refresh_save_data()
	var team := _team()
	if team_index < 0 or team_index >= team.size() or typeof(team[team_index]) != TYPE_DICTIONARY:
		return

	var item_id := str(item.get("id", ""))
	if InventoryManager.get_item_amount(item_id) <= 0:
		return

	var stat_key := PokemonHelpers.normalized_stat_key(str(item.get("effect_stat", "")))
	var boost_amount := maxi(1, int(item.get("effect_value", PokemonHelpers.STAT_BOOST_AMOUNT)))
	var result := PokemonHelpers.boost_stat(team[team_index], stat_key, boost_amount)
	var applied := int(result.get("applied", 0))
	var updated_pokemon: Dictionary = result.get("pokemon", team[team_index])
	var pokemon_name := str(updated_pokemon.get("name", "Pokemon"))
	if applied <= 0:
		UI.show_message_popup(self, _item_name(item), _text("stat_at_cap") % [pokemon_name, _stat_name(stat_key)])
		return

	if not InventoryManager.remove_item(item_id, 1):
		return

	team[team_index] = updated_pokemon
	SaveManager.update_current_save({"team": team})
	_refresh_save_data()
	_refresh_home_stats()
	_show_bag()
	UI.show_message_popup(self, _item_name(item), _text("stat_boosted") % [pokemon_name, applied, _stat_name(stat_key)])


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
	content.custom_minimum_size = Vector2(304, max(402, shop_items.size() * 126))
	scroll.add_child(content)

	for i in range(shop_items.size()):
		var item: Dictionary = shop_items[i]
		_add_shop_item_row(content, item, i)


func _add_shop_item_row(parent: Control, item: Dictionary, index: int) -> void:
	var player_level: int = maxi(1, int(save_data.get("level", 1)))
	var player_badges: int = int(save_data.get("badges", 0))
	var min_level: int = int(item.get("min_level", 0))
	var min_badges: int = int(item.get("min_badges", 0))
	var locked: bool = min_level > player_level or min_badges > player_badges
	var row := Panel.new()
	row.name = "Shop%s" % str(item.get("id", "")).capitalize()
	row.position = Vector2(0, float(index) * 126.0)
	row.size = Vector2(296, 118)
	parent.add_child(row)
	row.modulate = Color(1, 1, 1, 1) if not locked else Color(0.66, 0.70, 0.75, 1)
	UI.style_panel_button(row, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)

	_add_item_icon(row, item, Vector2(10, 10), Vector2(42, 42))
	var name_label := UI.add_panel_label(row, _item_name(item), Vector2(58, 6), Vector2(154, 20), 13, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	_fit_label(name_label, false)
	var description_label := UI.add_panel_label(row, _item_description(item), Vector2(58, 27), Vector2(156, 38), 9, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Description")
	_fit_label(description_label, true)
	var price_label := UI.add_panel_label(row, "%s: $%d" % [_text("price"), int(item.get("price", 0))], Vector2(58, 66), Vector2(154, 16), 11, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Price")
	_fit_label(price_label, false)

	var status := _text("locked") if locked else _text("available_status")
	var requirement := _text("requires") % [min_level, min_badges]
	var requirement_label := UI.add_panel_label(row, "%s\n%s" % [status, requirement], Vector2(58, 84), Vector2(166, 28), 9, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Requirement")
	_fit_label(requirement_label, true)

	var buy_button := _add_small_button(row, _text("buy"), Vector2(222, 43), Vector2(64, 32), Callable(self, "_buy_item").bind(item), "Buy")
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
	_refresh_save_data()

	tournament_popup = _create_popup(_text("tournament"), "TournamentPopup", 34.0, 580.0)
	UI.add_panel_label(tournament_popup, _text("tournament_soon"), Vector2(42, 92), Vector2(276, 26), 14, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Message")
	var scroll := ScrollContainer.new()
	scroll.name = "GymScroll"
	scroll.position = Vector2(28, 126)
	scroll.size = Vector2(304, 446)
	tournament_popup.add_child(scroll)

	var gyms := GymData.gyms()
	var content := Control.new()
	content.name = "GymContent"
	content.custom_minimum_size = Vector2(304, gyms.size() * 120)
	scroll.add_child(content)
	for i in range(gyms.size()):
		if typeof(gyms[i]) == TYPE_DICTIONARY:
			_add_tournament_card(content, gyms[i], float(i) * 120.0)


func _add_tournament_card(parent: Control, gym: Dictionary, y: float) -> void:
	var panel := Panel.new()
	panel.name = str(gym.get("id", "gym")).capitalize()
	panel.position = Vector2(0, y)
	panel.size = Vector2(296, 110)
	parent.add_child(panel)
	UI.style_panel_button(panel, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
	var gym_id := str(gym.get("id", ""))
	var completed := GymData.is_completed(save_data, gym_id)
	var unlocked := GymData.is_unlocked(save_data, gym)
	var title := "%d. %s" % [int(gym.get("badge_number", 0)), str(gym.get("city", "Gym"))]
	var title_label := UI.add_panel_label(panel, title, Vector2(10, 6), Vector2(190, 20), 14, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Title")
	_fit_label(title_label, false)
	var info := "%s: %s\n%s: %s | %s: %s\n%s: %d | %s: $%d" % [
		_text("gym_leader"), str(gym.get("leader", "Leader")),
		_text("gym_type"), str(gym.get("type", "Normal")), _text("gym_badge"), str(gym.get("badge", "Badge")),
		_text("gym_trainers"), GymData.opponent_count(gym_id), _text("gym_reward"), int(gym.get("reward_money", 0)),
	]
	var info_label := UI.add_panel_label(panel, info, Vector2(10, 28), Vector2(206, 58), 10, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Info")
	_fit_label(info_label, true)
	var button_text := _text("gym_completed") if completed else _text("gym_challenge") if unlocked else _text("locked")
	var button := _add_small_button(panel, button_text, Vector2(218, 34), Vector2(68, 34), Callable(self, "_start_gym_challenge").bind(gym_id), "Challenge")
	if completed or not unlocked:
		button.disabled = true
		button.modulate = Color(0.58, 0.62, 0.66, 0.9)
	var status := _text("gym_completed") if completed else _text("available_status") if unlocked else _text("gym_locked") % [int(gym.get("min_badges", 0)), int(gym.get("min_level", 1))]
	var status_label := UI.add_panel_label(panel, status, Vector2(10, 84), Vector2(276, 18), 9, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Status")
	_fit_label(status_label, false)


func _start_gym_challenge(gym_id: String) -> void:
	_refresh_save_data()
	var gym := GymData.gym_for_id(gym_id)
	if gym.is_empty():
		return
	if GymData.is_completed(save_data, gym_id):
		UI.show_message_popup(self, _text("tournament"), _text("gym_completed"))
		return
	if not GymData.is_unlocked(save_data, gym):
		UI.show_message_popup(self, _text("tournament"), _text("gym_locked") % [int(gym.get("min_badges", 0)), int(gym.get("min_level", 1))])
		return
	if not _has_ready_team_pokemon():
		UI.show_message_popup(self, _text("tournament"), _text("gym_no_ready"))
		return

	var intro := _create_popup(_text("tournament"), "GymIntroPopup", 126.0, 324.0)
	UI.add_panel_label(
		intro,
		_text("gym_intro") % [str(gym.get("city", "Gym")), str(gym.get("leader", "Leader")), str(gym.get("type", "Normal"))],
		Vector2(42, 182),
		Vector2(276, 96),
		16,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		"IntroText"
	)
	UI.add_orange_button(intro, _text("gym_challenge"), Vector2(70, 338), Vector2(220, 48), Callable(self, "_begin_gym_challenge").bind(gym_id), "BeginGym")
	_add_small_button(intro, _text("close"), Vector2(110, 396), Vector2(140, 28), Callable(intro, "queue_free"), "CloseGymIntro")


func _begin_gym_challenge(gym_id: String) -> void:
	var gym := GymData.gym_for_id(gym_id)
	if gym.is_empty():
		return
	var encounter := GymData.opponent_encounter(gym_id, 0)
	if encounter.is_empty():
		return
	SaveManager.update_current_save({
		"gym_challenge": GymData.challenge_for(gym_id, 0),
		"pending_encounter": encounter,
		"current_scene": "BattleScene",
	})
	get_tree().change_scene_to_file("res://scenes/BattleScene.tscn")


func _show_pokemon_menu() -> void:
	_show_pokemon_collection()


func _show_my_pokemon() -> void:
	selected_collection_tab = "storage"
	selected_collection_source = "storage"
	_show_pokemon_collection()


func _show_my_team_pokemon() -> void:
	selected_collection_tab = "team"
	selected_collection_source = "team"
	_show_pokemon_collection()


func _show_pokemon_collection() -> void:
	_close_pokemon_popup()
	_refresh_save_data()
	_sanitize_collection_selection()
	pokemon_popup = _create_popup(_text("pokemon_collection"), "PokemonCollectionPopup", 34.0, 580.0)
	_add_small_button(pokemon_popup, _text("pokedex"), Vector2(42, 92), Vector2(86, 28), Callable(self, "_show_pokedex"), "CollectionDex")
	_add_small_button(pokemon_popup, _text("pokemon_center"), Vector2(136, 92), Vector2(104, 28), Callable(self, "_show_pokemon_center"), "CollectionCenter")
	_add_small_button(pokemon_popup, _text("close"), Vector2(248, 92), Vector2(70, 28), Callable(self, "_close_pokemon_popup"), "CollectionClose")
	_add_collection_tab_button(pokemon_popup, "team", Vector2(42, 128), Vector2(132, 28), "CollectionTeamTab")
	_add_collection_tab_button(pokemon_popup, "storage", Vector2(186, 128), Vector2(132, 28), "CollectionStorageTab")

	var scroll := ScrollContainer.new()
	scroll.name = "CollectionScroll"
	scroll.position = Vector2(28, 164)
	scroll.size = Vector2(304, 408)
	pokemon_popup.add_child(scroll)

	var content := Control.new()
	content.name = "CollectionContent"
	scroll.add_child(content)

	if selected_collection_tab == "storage":
		var rows := _filtered_storage_rows()
		var storage_height: float = max(170.0, float(rows.size()) * 62.0 + 116.0)
		var details_y := storage_height + 16.0
		content.custom_minimum_size = Vector2(304, details_y + 520.0)
		_add_collection_storage(content, 0.0, rows)
		_add_collection_details(content, details_y)
	else:
		var details_y := 376.0
		content.custom_minimum_size = Vector2(304, details_y + 520.0)
		_add_collection_team(content, 0.0)
		_add_collection_details(content, details_y)


func _add_collection_tab_button(parent: Control, tab: String, pos: Vector2, node_size: Vector2, node_name: String) -> void:
	var label_key := "team_current" if tab == "team" else "storage"
	var button := _add_small_button(parent, _text(label_key), pos, node_size, Callable(self, "_set_collection_tab").bind(tab), node_name)
	var selected := selected_collection_tab == tab
	UI.style_panel_button(button, Color(0.95, 0.78, 0.32) if selected else Color(0.82, 0.88, 0.94), Color(0.92, 0.46, 0.08) if selected else Color(0.36, 0.50, 0.62), 2)


func _set_collection_tab(tab: String) -> void:
	selected_collection_tab = "storage" if tab == "storage" else "team"
	selected_collection_source = selected_collection_tab
	selected_collection_index = 0
	_show_pokemon_collection()


func _add_collection_team(parent: Control, y: float) -> void:
	UI.add_panel_label(parent, _text("team_current"), Vector2(0, y), Vector2(296, 24), 15, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "TeamTitle")
	var team := _team()
	var active_index := _active_pokemon_index(team)
	for slot in range(TEAM_LIMIT):
		var row_y := y + 30.0 + float(slot) * 62.0
		if slot < team.size() and typeof(team[slot]) == TYPE_DICTIONARY:
			_add_collection_row(parent, PokemonHelpers.normalize_pokemon(team[slot]), "team", slot, Vector2(0, row_y), slot == active_index)
		else:
			var panel := Panel.new()
			panel.name = "CollectionEmptySlot%d" % slot
			panel.position = Vector2(0, row_y)
			panel.size = Vector2(296, 54)
			parent.add_child(panel)
			UI.style_panel_button(panel, Color(0.72, 0.78, 0.84), Color(0.34, 0.50, 0.62), 2)
			UI.add_panel_label(panel, "%s %d" % [_text("empty_slot"), slot + 1], Vector2(12, 0), Vector2(272, 54), 14, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Empty")


func _add_collection_row(parent: Control, pokemon: Dictionary, source: String, index: int, pos: Vector2, active: bool = false) -> void:
	var selected := selected_collection_source == source and selected_collection_index == index
	var row := Button.new()
	row.name = "%sCollection%d" % [source.capitalize(), index]
	row.position = pos
	row.size = Vector2(296, 54)
	row.focus_mode = Control.FOCUS_NONE
	row.add_theme_color_override("font_color", UI.PANEL_TEXT)
	row.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	row.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	UI.style_panel_button(row, Color(0.95, 0.78, 0.32) if selected else Color(0.86, 0.92, 0.96), Color(0.92, 0.46, 0.08) if selected else Color(0.34, 0.50, 0.62), 2)
	parent.add_child(row)
	row.pressed.connect(Callable(self, "_select_collection_pokemon").bind(source, index))
	PokemonHelpers.add_animated_sprite(row, pokemon, Vector2(8, 7), Vector2(40, 40), false, "Sprite")
	var name := str(pokemon.get("name", pokemon.get("species", "Pokemon")))
	var title := "%s%s  %s %d" % ["★ " if active else "", name, _text("level"), int(pokemon.get("level", 1))]
	var title_label := UI.add_panel_label(row, title, Vector2(56, 5), Vector2(180, 18), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	_fit_label(title_label, false)
	var sub := "%s %d/%d | %s" % [_text("hp"), int(pokemon.get("hp", 0)), int(pokemon.get("max_hp", 1)), _pokemon_types_text(pokemon)]
	var sub_label := UI.add_panel_label(row, sub, Vector2(56, 25), Vector2(180, 16), 9, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Info")
	_fit_label(sub_label, false)
	UI.add_panel_label(row, source.capitalize(), Vector2(240, 14), Vector2(48, 24), 9, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Source")


func _add_collection_owned(parent: Control, y: float, rows: Array) -> float:
	UI.add_panel_label(parent, "%s (%d)" % [_text("my_pokemon"), _collection_total_count()], Vector2(0, y), Vector2(296, 24), 15, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "OwnedTitle")
	var search := LineEdit.new()
	search.name = "CollectionAllSearch"
	search.placeholder_text = _text("search")
	search.text = storage_search_text
	search.position = Vector2(0, y + 30.0)
	search.size = Vector2(296, 30)
	search.add_theme_font_size_override("font_size", 12)
	search.add_theme_color_override("font_color", UI.PANEL_TEXT)
	parent.add_child(search)
	search.text_changed.connect(func(value: String):
		storage_search_text = value
		call_deferred("_show_pokemon_collection")
	)
	_add_small_button(parent, _text("sort_level"), Vector2(0, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("level"), "CollectionOwnedSortLevel")
	_add_small_button(parent, _text("sort_name"), Vector2(58, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("name"), "CollectionOwnedSortName")
	_add_small_button(parent, _text("sort_dex"), Vector2(116, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("dex"), "CollectionOwnedSortDex")
	_add_small_button(parent, _text("sort_date"), Vector2(174, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("date"), "CollectionOwnedSortDate")
	_add_small_button(parent, _text("sort_generation"), Vector2(232, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("generation"), "CollectionOwnedSortGen")
	if rows.is_empty():
		UI.add_panel_label(parent, _text("storage_empty"), Vector2(0, y + 116.0), Vector2(296, 44), 14, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "EmptyOwned")
		return y + 170.0
	for i in range(rows.size()):
		var row: Dictionary = rows[i]
		var source := str(row.get("source", "team"))
		var source_index := int(row.get("index", 0))
		var active := source == "team" and source_index == _active_pokemon_index(_team())
		_add_collection_row(parent, row.get("pokemon", {}), source, source_index, Vector2(0, y + 106.0 + float(i) * 62.0), active)
	return y + 116.0 + float(rows.size()) * 62.0


func _add_collection_details(parent: Control, y: float) -> float:
	var pokemon := _selected_collection_pokemon()
	UI.add_panel_label(parent, _text("selected_pokemon"), Vector2(0, y), Vector2(296, 24), 15, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "DetailsTitle")
	if pokemon.is_empty():
		UI.add_panel_label(parent, _text("empty_slot"), Vector2(0, y + 28.0), Vector2(296, 52), 14, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "NoSelection")
		return y + 92.0

	var panel := Panel.new()
	panel.name = "CollectionDetails"
	panel.position = Vector2(0, y + 28.0)
	panel.size = Vector2(296, 476)
	parent.add_child(panel)
	UI.style_panel_button(panel, Color(0.88, 0.94, 0.98), Color(0.34, 0.50, 0.62), 2)
	PokemonHelpers.add_animated_sprite(panel, pokemon, Vector2(10, 10), Vector2(72, 72), false, "DetailSprite")
	var name := str(pokemon.get("name", pokemon.get("species", "Pokemon")))
	var species := str(pokemon.get("species", name))
	var header := "#%03d %s\n%s %d | %s" % [int(pokemon.get("dex_number", 0)), name, _text("level"), int(pokemon.get("level", 1)), species]
	var header_label := UI.add_panel_label(panel, header, Vector2(92, 8), Vector2(188, 44), 13, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Header")
	_fit_label(header_label, true)
	var basic := "%s: %s\n%s: %s\n%s: %s\n%s: %s\n%s: %s\n%s: %s\n%s: %s" % [
		_text("type"), _pokemon_types_text(pokemon),
		_text("ability"), str(pokemon.get("ability", _text("unknown"))),
		_text("nature"), str(pokemon.get("nature", _text("unknown"))),
		_text("gender"), str(pokemon.get("gender", _text("unknown"))),
		_text("status"), _pokemon_status_text(pokemon),
		_text("held_item"), _held_item_text(pokemon),
		_text("capture_date"), _capture_date_text(pokemon),
	]
	var basic_label := UI.add_panel_label(panel, basic, Vector2(92, 52), Vector2(188, 106), 9, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Basic")
	_fit_label(basic_label, true)
	var desc := "%s: %s" % [_text("description"), _collection_description(pokemon)]
	var desc_label := UI.add_panel_label(panel, desc, Vector2(12, 164), Vector2(272, 46), 9, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Description")
	_fit_label(desc_label, true)
	UI.add_panel_label(panel, _text("moves"), Vector2(12, 214), Vector2(120, 18), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "MovesTitle")
	_add_collection_moves(panel, pokemon, Vector2(12, 236))
	_add_collection_name_editor(panel, pokemon, Vector2(12, 340))
	_add_collection_action_buttons(panel, Vector2(12, 416))
	return y + 520.0


func _add_collection_moves(parent: Control, pokemon: Dictionary, pos: Vector2) -> void:
	var moves = pokemon.get("moves", [])
	var pp_current = pokemon.get("pp_current", [])
	var pp_max = pokemon.get("pp_max", [])
	if typeof(moves) != TYPE_ARRAY:
		moves = []
	for i in range(PokemonHelpers.MAX_MOVE_SLOTS):
		var row_y := pos.y + float(i) * 25.0
		if i < moves.size() and typeof(moves[i]) == TYPE_DICTIONARY:
			var move: Dictionary = moves[i]
			var pp := int(pp_current[i]) if typeof(pp_current) == TYPE_ARRAY and i < pp_current.size() else int(move.get("pp", 0))
			var max_pp := int(pp_max[i]) if typeof(pp_max) == TYPE_ARRAY and i < pp_max.size() else int(move.get("pp", 0))
			var label_text := "%s | %s | PP %d/%d" % [str(move.get("name", "Move")), str(move.get("type", "Normal")), pp, max_pp]
			var label := UI.add_panel_label(parent, label_text, Vector2(pos.x, row_y), Vector2(200, 20), 9, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Move%d" % i)
			_fit_label(label, false)
		else:
			UI.add_panel_label(parent, "-", Vector2(pos.x, row_y), Vector2(200, 20), 9, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Move%d" % i)
		_add_small_button(parent, _text("change_move"), Vector2(pos.x + 210.0, row_y - 1.0), Vector2(62, 22), Callable(self, "_show_move_editor").bind(selected_collection_source, selected_collection_index, i), "MoveChange%d" % i)


func _add_collection_name_editor(parent: Control, pokemon: Dictionary, pos: Vector2) -> void:
	UI.add_panel_label(parent, _text("nickname"), pos, Vector2(72, 24), 10, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "NicknameLabel")
	var input := LineEdit.new()
	input.name = "CollectionNicknameInput"
	input.text = str(pokemon.get("nickname", ""))
	input.placeholder_text = str(pokemon.get("species", pokemon.get("name", "Pokemon")))
	input.position = Vector2(pos.x + 74.0, pos.y)
	input.size = Vector2(198, 26)
	input.max_length = 24
	input.add_theme_font_size_override("font_size", 12)
	input.add_theme_color_override("font_color", UI.PANEL_TEXT)
	parent.add_child(input)
	_add_small_button(parent, _text("rename"), Vector2(pos.x, pos.y + 34.0), Vector2(128, 26), Callable(self, "_rename_collection_pokemon").bind(selected_collection_source, selected_collection_index, input), "Rename")
	_add_small_button(parent, _text("clear_nickname"), Vector2(pos.x + 144.0, pos.y + 34.0), Vector2(128, 26), Callable(self, "_clear_collection_nickname").bind(selected_collection_source, selected_collection_index), "ClearNickname")


func _add_collection_action_buttons(parent: Control, pos: Vector2) -> void:
	var source := selected_collection_source
	var index := selected_collection_index
	if source == "team":
		_add_small_button(parent, _text("set_active"), pos, Vector2(82, 26), Callable(self, "_set_collection_active").bind(index), "SetActive")
		_add_small_button(parent, _text("move_up"), Vector2(pos.x + 94.0, pos.y), Vector2(54, 26), Callable(self, "_move_collection_team").bind(index, -1), "MoveUp")
		_add_small_button(parent, _text("move_down"), Vector2(pos.x + 156.0, pos.y), Vector2(54, 26), Callable(self, "_move_collection_team").bind(index, 1), "MoveDown")
		_add_small_button(parent, _text("send_to_storage"), Vector2(pos.x, pos.y + 34.0), Vector2(198, 26), Callable(self, "_deposit_collection_pokemon").bind(index), "DepositSelected")
	else:
		_add_small_button(parent, _text("send_to_team"), pos, Vector2(198, 26), Callable(self, "_withdraw_collection_pokemon").bind(index), "WithdrawSelected")


func _add_collection_storage(parent: Control, y: float, rows: Array) -> void:
	UI.add_panel_label(parent, "%s (%d/%d)" % [_text("storage"), _storage().size(), SaveManager.MAX_STORAGE_SIZE], Vector2(0, y), Vector2(296, 24), 15, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "StorageTitle")
	var search := LineEdit.new()
	search.name = "CollectionSearch"
	search.placeholder_text = _text("search")
	search.text = storage_search_text
	search.position = Vector2(0, y + 30.0)
	search.size = Vector2(296, 30)
	search.add_theme_font_size_override("font_size", 12)
	search.add_theme_color_override("font_color", UI.PANEL_TEXT)
	parent.add_child(search)
	search.text_changed.connect(func(value: String):
		storage_search_text = value
		call_deferred("_show_pokemon_collection")
	)
	_add_small_button(parent, _text("sort_level"), Vector2(0, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("level"), "CollectionSortLevel")
	_add_small_button(parent, _text("sort_name"), Vector2(58, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("name"), "CollectionSortName")
	_add_small_button(parent, _text("sort_dex"), Vector2(116, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("dex"), "CollectionSortDex")
	_add_small_button(parent, _text("sort_date"), Vector2(174, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("date"), "CollectionSortDate")
	_add_small_button(parent, _text("sort_generation"), Vector2(232, y + 68.0), Vector2(52, 26), Callable(self, "_set_storage_sort").bind("generation"), "CollectionSortGen")
	if rows.is_empty():
		UI.add_panel_label(parent, _text("storage_empty"), Vector2(0, y + 116.0), Vector2(296, 44), 14, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "EmptyStorage")
		return
	for i in range(rows.size()):
		var row: Dictionary = rows[i]
		_add_collection_row(parent, row.get("pokemon", {}), "storage", int(row.get("index", 0)), Vector2(0, y + 106.0 + float(i) * 62.0))


func _sanitize_collection_selection() -> void:
	var team := _team()
	var storage := _storage()
	if selected_collection_tab == "storage":
		selected_collection_source = "storage"
		selected_collection_index = clampi(selected_collection_index, 0, maxi(0, storage.size() - 1))
	else:
		selected_collection_tab = "team"
		selected_collection_source = "team"
		selected_collection_index = clampi(selected_collection_index, 0, maxi(0, team.size() - 1))


func _select_collection_pokemon(source: String, index: int) -> void:
	selected_collection_tab = "storage" if source == "storage" else "team"
	selected_collection_source = source
	selected_collection_index = index
	_show_pokemon_collection()


func _selected_collection_pokemon() -> Dictionary:
	return _collection_pokemon(selected_collection_source, selected_collection_index)


func _collection_pokemon(source: String, index: int) -> Dictionary:
	var collection := _team() if source == "team" else _storage()
	if index < 0 or index >= collection.size() or typeof(collection[index]) != TYPE_DICTIONARY:
		return {}
	return PokemonHelpers.normalize_pokemon(collection[index], str(collection[index].get("id", PokemonHelpers.DEFAULT_STARTER_ID)))


func _save_collection_pokemon(source: String, index: int, pokemon: Dictionary) -> void:
	var team := _team()
	var storage := _storage()
	if source == "team":
		if index < 0 or index >= team.size():
			return
		team[index] = PokemonHelpers.normalize_pokemon(pokemon, str(pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	else:
		if index < 0 or index >= storage.size():
			return
		storage[index] = PokemonHelpers.normalize_pokemon(pokemon, str(pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	SaveManager.update_current_save({"team": team, "storage": storage, "active_pokemon_index": _active_pokemon_index(team)})
	_refresh_save_data()


func _rename_collection_pokemon(source: String, index: int, input: LineEdit) -> void:
	var pokemon := _collection_pokemon(source, index)
	if pokemon.is_empty():
		return
	var nickname := input.text.strip_edges()
	pokemon["nickname"] = nickname
	pokemon["name"] = nickname if nickname != "" else str(pokemon.get("species", "Pokemon"))
	_save_collection_pokemon(source, index, pokemon)
	_show_pokemon_collection()


func _clear_collection_nickname(source: String, index: int) -> void:
	var pokemon := _collection_pokemon(source, index)
	if pokemon.is_empty():
		return
	pokemon["nickname"] = ""
	pokemon["name"] = str(pokemon.get("species", "Pokemon"))
	_save_collection_pokemon(source, index, pokemon)
	_show_pokemon_collection()


func _set_collection_active(index: int) -> void:
	var team := _team()
	if index < 0 or index >= team.size():
		return
	if typeof(team[index]) == TYPE_DICTIONARY and PokemonHelpers.is_healing(team[index]):
		UI.show_message_popup(self, _text("pokemon_menu"), _text("pokemon_recovering"))
		return
	SaveManager.update_current_save({"active_pokemon_index": index})
	_refresh_save_data()
	_refresh_home_stats()
	selected_collection_tab = "team"
	selected_collection_source = "team"
	selected_collection_index = index
	_show_pokemon_collection()


func _move_collection_team(index: int, direction: int) -> void:
	var team := _team()
	var target := index + direction
	if index < 0 or index >= team.size() or target < 0 or target >= team.size():
		return
	var active_index := _active_pokemon_index(team)
	var moved = team[index]
	team[index] = team[target]
	team[target] = moved
	if active_index == index:
		active_index = target
	elif active_index == target:
		active_index = index
	SaveManager.update_current_save({"team": team, "active_pokemon_index": active_index})
	_refresh_save_data()
	_refresh_home_stats()
	selected_collection_tab = "team"
	selected_collection_source = "team"
	selected_collection_index = clampi(index + direction, 0, maxi(0, _team().size() - 1))
	_show_pokemon_collection()


func _deposit_collection_pokemon(index: int) -> void:
	var team := _team()
	var storage := _storage()
	if team.size() <= 1:
		UI.show_message_popup(self, _text("storage"), _text("last_pokemon"))
		return
	if storage.size() >= SaveManager.MAX_STORAGE_SIZE:
		UI.show_message_popup(self, _text("storage"), _text("storage_full"))
		return
	if index < 0 or index >= team.size():
		return
	var active_index := _active_pokemon_index(team)
	var pokemon = team[index]
	team.remove_at(index)
	storage.append(pokemon)
	if active_index == index:
		active_index = clampi(index, 0, maxi(0, team.size() - 1))
	elif active_index > index:
		active_index -= 1
	selected_collection_tab = "storage"
	selected_collection_source = "storage"
	selected_collection_index = storage.size() - 1
	SaveManager.update_current_save({"team": team, "storage": storage, "active_pokemon_index": active_index})
	_refresh_save_data()
	_show_pokemon_collection()


func _withdraw_collection_pokemon(storage_index: int) -> void:
	var team := _team()
	var storage := _storage()
	if team.size() >= TEAM_LIMIT:
		UI.show_message_popup(self, _text("storage"), _text("team_full"))
		return
	if storage_index < 0 or storage_index >= storage.size():
		return
	if typeof(storage[storage_index]) == TYPE_DICTIONARY and PokemonHelpers.is_healing(storage[storage_index]):
		UI.show_message_popup(self, _text("storage"), _text("pokemon_recovering"))
		return
	team.append(storage[storage_index])
	storage.remove_at(storage_index)
	selected_collection_tab = "team"
	selected_collection_source = "team"
	selected_collection_index = team.size() - 1
	SaveManager.update_current_save({"team": team, "storage": storage, "active_pokemon_index": _active_pokemon_index(team)})
	_refresh_save_data()
	_show_pokemon_collection()


func _show_move_editor(source: String, index: int, move_slot: int) -> void:
	var pokemon := _collection_pokemon(source, index)
	if pokemon.is_empty():
		return
	var popup := _create_popup(_text("available_moves"), "MoveEditorPopup", 64.0, 520.0)
	var scroll := ScrollContainer.new()
	scroll.name = "MoveEditorScroll"
	scroll.position = Vector2(28, 126)
	scroll.size = Vector2(304, 420)
	popup.add_child(scroll)
	var moves := PokemonHelpers.available_moves_for(pokemon)
	var content := Control.new()
	content.name = "MoveEditorContent"
	content.custom_minimum_size = Vector2(304, max(420, moves.size() * 52))
	scroll.add_child(content)
	for i in range(moves.size()):
		if typeof(moves[i]) != TYPE_DICTIONARY:
			continue
		var move: Dictionary = moves[i]
		var row := Button.new()
		row.name = "MoveOption%d" % i
		row.position = Vector2(0, float(i) * 52.0)
		row.size = Vector2(296, 46)
		row.focus_mode = Control.FOCUS_NONE
		UI.style_panel_button(row, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
		content.add_child(row)
		var move_text := "%s | %s | %s | PP %d" % [str(move.get("name", "Move")), str(move.get("type", "Normal")), str(move.get("category", "Physical")), int(move.get("pp", 35))]
		var label := UI.add_panel_label(row, move_text, Vector2(10, 0), Vector2(276, 46), 11, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "MoveText")
		_fit_label(label, false)
		row.pressed.connect(Callable(self, "_change_collection_move").bind(source, index, move_slot, str(move.get("name", "Tackle"))))


func _change_collection_move(source: String, index: int, move_slot: int, move_name: String) -> void:
	var pokemon := _collection_pokemon(source, index)
	if pokemon.is_empty():
		return
	var moves = pokemon.get("moves", [])
	if typeof(moves) != TYPE_ARRAY:
		moves = []
	while moves.size() <= move_slot:
		moves.append(PokemonHelpers.move_by_name("Tackle"))
	var new_move := PokemonHelpers.move_by_name(move_name)
	moves[move_slot] = new_move
	pokemon["moves"] = moves
	var pp_max = pokemon.get("pp_max", [])
	var pp_current = pokemon.get("pp_current", [])
	if typeof(pp_max) != TYPE_ARRAY:
		pp_max = []
	if typeof(pp_current) != TYPE_ARRAY:
		pp_current = []
	while pp_max.size() <= move_slot:
		pp_max.append(1)
	while pp_current.size() <= move_slot:
		pp_current.append(1)
	pp_max[move_slot] = int(new_move.get("pp", 35))
	pp_current[move_slot] = int(new_move.get("pp", 35))
	pokemon["pp_max"] = pp_max
	pokemon["pp_current"] = pp_current
	_save_collection_pokemon(source, index, pokemon)
	var editor := get_node_or_null("MoveEditorPopup")
	if editor != null:
		editor.queue_free()
	_show_pokemon_collection()


func _pokemon_status_text(pokemon: Dictionary) -> String:
	var status_value = pokemon.get("status_condition", null)
	if status_value == null or str(status_value) == "":
		return _text("none")
	return str(status_value)


func _held_item_text(pokemon: Dictionary) -> String:
	var held_item = pokemon.get("held_item", null)
	if held_item == null or str(held_item) == "":
		return _text("none")
	return str(held_item)


func _capture_date_text(pokemon: Dictionary) -> String:
	var capture_date := str(pokemon.get("capture_date", ""))
	return _text("unknown") if capture_date == "" else capture_date


func _collection_description(pokemon: Dictionary) -> String:
	var pokemon_id := str(pokemon.get("id", ""))
	if PokemonHelpers.has_definition(pokemon_id):
		return _pokemon_description(PokemonHelpers.get_definition(pokemon_id))
	var key := "description_pt" if _language() == "pt" else "description_en"
	return str(pokemon.get(key, pokemon.get("species", "Pokemon")))


func _show_pokedex() -> void:
	_close_pokemon_popup()
	var popup := _create_popup(_text("pokedex"), "PokeDexPopup", 34.0, 580.0)
	var species_ids := PokemonHelpers.species_ids()
	var total := species_ids.size()
	var seen_count := _count_registered_species(_seen_pokemon_ids(), species_ids)
	var owned_count := _count_registered_species(_owned_pokemon_ids(), species_ids)
	UI.add_panel_label(
		popup,
		"%s\n%s" % [_text("seen_count") % [seen_count, total], _text("captured_count") % [owned_count, total]],
		Vector2(42, 92),
		Vector2(276, 42),
		13,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		"PokedexCounts"
	)
	var scroll := ScrollContainer.new()
	scroll.name = "PokeDexScroll"
	scroll.position = Vector2(28, 142)
	scroll.size = Vector2(304, 430)
	popup.add_child(scroll)

	var content := Control.new()
	content.name = "PokeDexContent"
	content.custom_minimum_size = Vector2(304, species_ids.size() * 168)
	scroll.add_child(content)

	for i in range(species_ids.size()):
		_add_pokedex_entry(content, str(species_ids[i]), i)


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
		_center_status_text(team),
		Vector2(42, 500),
		Vector2(276, 36),
		10,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		"CenterStatus"
	)
	pokemon_center_status_label.clip_text = true
	pokemon_center_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pokemon_center_heal_button = UI.add_orange_button(pokemon_center_popup, _text("heal_team"), Vector2(42, 552), Vector2(132, 44), Callable(self, "_heal_team"), "HealTeam")
	UI.add_orange_button(pokemon_center_popup, _text("storage"), Vector2(186, 552), Vector2(132, 44), Callable(self, "_show_pokemon_collection"), "Storage")
	_set_center_heal_enabled(_team_has_center_targets(team))
	if _team_has_recovering_pokemon(team):
		_refresh_center_countdown()


func _team() -> Array:
	_refresh_save_data()
	var team_value = save_data.get("team", [])
	if typeof(team_value) == TYPE_ARRAY:
		return team_value
	return []


func _has_ready_team_pokemon() -> bool:
	for entry in _team():
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var pokemon := PokemonHelpers.complete_healing_if_ready(entry)
		if int(pokemon.get("hp", 0)) > 0 and not PokemonHelpers.is_healing(pokemon):
			return true
	return false


func _storage() -> Array:
	_refresh_save_data()
	var storage_value = save_data.get("storage", [])
	if typeof(storage_value) == TYPE_ARRAY:
		return storage_value
	return []


func _active_pokemon_index(team: Array = []) -> int:
	var source_team := team if not team.is_empty() else _team()
	return clampi(int(save_data.get("active_pokemon_index", 0)), 0, maxi(0, source_team.size() - 1))


func _first_owned_pokemon() -> Dictionary:
	var team := _team()
	var active_index := _active_pokemon_index(team)
	if not team.is_empty() and active_index < team.size() and typeof(team[active_index]) == TYPE_DICTIONARY:
		return team[active_index]
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
	var xp_to_next := int(pokemon.get("xp_to_next_level", PokemonHelpers.xp_to_next_level_for(level)))
	var xp_text := "%d/%d" % [xp, xp_to_next] if xp_to_next > 0 else "%d/MAX" % xp
	var recovery_text := _pokemon_recovery_text(pokemon)
	var title := "#%03d %s  %s %d" % [dex_number, name, _text("level"), level] if show_dex else "%s  %s %d" % [name, _text("level"), level]
	var title_font := 13 if compact else 16
	var title_label := UI.add_panel_label(panel, title, Vector2(76, 7), Vector2(188, 22), title_font, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	_fit_label(title_label, false)
	var info_text := ""
	var info_pos := Vector2(76, 31)
	var info_size := Vector2(188, node_size.y - 35.0)
	var info_font := 10 if compact else 11
	if compact:
		info_text = "%s: %d/%d   %s: %s\n%s" % [_text("hp"), hp, max_hp, _text("xp"), xp_text, types if recovery_text == "" else recovery_text]
		info_font = 9 if recovery_text != "" else info_font
	else:
		info_text = "%s: %s\n%s: %d/%d   %s: %s" % [_text("type"), types, _text("hp"), hp, max_hp, _text("xp"), xp_text]
		info_pos = Vector2(76, 34)
		info_size = Vector2(188, node_size.y - 44.0)
		if recovery_text != "":
			info_text = "%s\n%s" % [info_text, recovery_text]
			info_font = 10
	var info_label := UI.add_panel_label(panel, info_text, info_pos, info_size, info_font, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Info")
	_fit_label(info_label, true)
	if not compact and (show_starter or bool(pokemon.get("starter", false))):
		UI.add_panel_label(panel, _text("active") if show_starter else _text("starter_tag"), Vector2(108, node_size.y - 24.0), Vector2(70, 18), 10, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Starter")


func _add_empty_team_slot(parent: Control, slot: int, y: float, slot_height: float) -> void:
	var panel := Panel.new()
	panel.name = "EmptySlot%d" % slot
	panel.position = Vector2(42, y)
	panel.size = Vector2(276, slot_height)
	parent.add_child(panel)
	UI.style_panel_button(panel, Color(0.72, 0.78, 0.84), Color(0.34, 0.50, 0.62), 2)
	UI.add_panel_label(panel, "%s %d" % [_text("empty_slot"), slot], Vector2(12, 0), Vector2(252, slot_height), 15, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Empty")


func _add_pokedex_entry(parent: Control, pokemon_id: String, index: int) -> void:
	var seen := _seen_pokemon_ids().has(pokemon_id)
	var owned := _owned_pokemon_ids().has(pokemon_id)
	var registered := seen or owned
	var index_entry := PokemonHelpers.species_index_entry(pokemon_id)
	var definition := PokemonHelpers.get_definition(pokemon_id) if registered else index_entry
	var panel := Panel.new()
	panel.name = "%sDex" % str(definition.get("name", "Pokemon"))
	panel.position = Vector2(0, float(index) * 168.0)
	panel.size = Vector2(296, 158)
	parent.add_child(panel)
	UI.style_panel_button(panel, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)

	var dex_number := int(definition.get("dex_number", 0))
	var pokemon_name := str(definition.get("name", "Pokemon")) if registered else "????"
	if registered:
		PokemonHelpers.add_animated_sprite(panel, definition, Vector2(12, 18), Vector2(58, 58), false, "DexSprite")
	else:
		_add_placeholder_icon(panel, Vector2(18, 22), Vector2(46, 46), "?")
	var name_label := UI.add_panel_label(panel, "#%03d %s" % [dex_number, pokemon_name], Vector2(84, 12), Vector2(190, 22), 16, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Name")
	_fit_label(name_label, false)
	var type_text := _pokemon_types_text(definition) if owned else "???"
	var info_label := UI.add_panel_label(panel, "%s: %s\n%s: %s" % [_text("type"), type_text, _text("status"), _pokedex_status(pokemon_id)], Vector2(84, 38), Vector2(190, 42), 11, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Info")
	_fit_label(info_label, true)
	var description_label := UI.add_panel_label(panel, _pokemon_description(definition) if owned else _text("unknown"), Vector2(12, 84), Vector2(272, 62), 10, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "Description")
	_fit_label(description_label, true)


func _count_registered_species(ids: Array, species_ids: Array) -> int:
	var count := 0
	for pokemon_id in species_ids:
		if ids.has(str(pokemon_id)):
			count += 1
	return count


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
	return []


func _seen_pokemon_ids() -> Array:
	_refresh_save_data()
	var seen_value = save_data.get("seen_pokemon", [])
	if typeof(seen_value) == TYPE_ARRAY:
		return seen_value
	return []


func _heal_team() -> void:
	if not _has_active_save():
		UI.show_message_popup(self, _text("debug_menu"), _text("no_active_save"))
		return

	_refresh_save_data()
	var team := _team()
	if not _team_has_center_targets(team):
		_set_center_status(_text("healed_team"))
		return

	var money := int(save_data.get("money", 3000))
	if money < POKEMON_CENTER_COST:
		_set_center_status(_text("not_enough_money_center"))
		return

	_set_center_heal_enabled(false)
	for i in range(team.size()):
		if typeof(team[i]) == TYPE_DICTIONARY:
			var pokemon := PokemonHelpers.complete_healing_if_ready(team[i])
			if not PokemonHelpers.is_healing(pokemon) and _pokemon_needs_center(pokemon):
				pokemon = PokemonHelpers.start_healing(pokemon)
			team[i] = pokemon
	SaveManager.update_current_save({"money": money - POKEMON_CENTER_COST, "team": team})
	_refresh_save_data()
	_refresh_home_stats()
	if pokemon_center_popup != null and is_instance_valid(pokemon_center_popup):
		_show_pokemon_center()
		_set_center_status(_text("healing_started"))
	else:
		UI.show_message_popup(self, _text("pokemon_center"), _text("healing_started"))


func _set_active_pokemon(index: int) -> void:
	var team := _team()
	if index < 0 or index >= team.size():
		return
	if typeof(team[index]) == TYPE_DICTIONARY and PokemonHelpers.is_healing(team[index]):
		UI.show_message_popup(self, _text("pokemon_menu"), _text("pokemon_recovering"))
		return
	SaveManager.update_current_save({"active_pokemon_index": index})
	_refresh_save_data()
	_refresh_home_stats()
	_show_my_team_pokemon()


func _move_team_pokemon(index: int, direction: int) -> void:
	var team := _team()
	var target := index + direction
	if index < 0 or index >= team.size() or target < 0 or target >= team.size():
		return
	var active_index := _active_pokemon_index(team)
	var moved = team[index]
	team[index] = team[target]
	team[target] = moved
	if active_index == index:
		active_index = target
	elif active_index == target:
		active_index = index
	SaveManager.update_current_save({"team": team, "active_pokemon_index": active_index})
	_refresh_save_data()
	_refresh_home_stats()
	_show_my_team_pokemon()


func _deposit_team_pokemon(index: int) -> void:
	var team := _team()
	if team.size() <= 1:
		UI.show_message_popup(self, _text("storage"), _text("last_pokemon"))
		return
	var storage := _storage()
	if storage.size() >= 500:
		UI.show_message_popup(self, _text("storage"), _text("storage_full"))
		return
	if index < 0 or index >= team.size():
		return
	var pokemon = team[index]
	team.remove_at(index)
	storage.append(pokemon)
	var active_index := clampi(int(save_data.get("active_pokemon_index", 0)), 0, maxi(0, team.size() - 1))
	SaveManager.update_current_save({"team": team, "storage": storage, "active_pokemon_index": active_index})
	_refresh_save_data()
	_refresh_home_stats()
	_show_my_team_pokemon()


func _withdraw_storage_pokemon(storage_index: int) -> void:
	var team := _team()
	if team.size() >= TEAM_LIMIT:
		UI.show_message_popup(self, _text("storage"), _text("team_full"))
		return
	var storage := _storage()
	if storage_index < 0 or storage_index >= storage.size():
		return
	if typeof(storage[storage_index]) == TYPE_DICTIONARY and PokemonHelpers.is_healing(storage[storage_index]):
		UI.show_message_popup(self, _text("storage"), _text("pokemon_recovering"))
		return
	team.append(storage[storage_index])
	storage.remove_at(storage_index)
	SaveManager.update_current_save({"team": team, "storage": storage})
	_refresh_save_data()
	_refresh_home_stats()
	_show_storage()


func _show_storage() -> void:
	if storage_popup != null and is_instance_valid(storage_popup):
		storage_popup.queue_free()
	storage_popup = _create_popup(_text("storage"), "StoragePopup", 34.0, 580.0)

	var search := LineEdit.new()
	search.name = "StorageSearch"
	search.placeholder_text = _text("search")
	search.text = storage_search_text
	search.position = Vector2(42, 96)
	search.size = Vector2(276, 34)
	storage_popup.add_child(search)
	search.text_changed.connect(func(value: String):
		storage_search_text = value
		call_deferred("_show_storage")
	)

	_add_small_button(storage_popup, _text("sort_level"), Vector2(42, 136), Vector2(52, 28), Callable(self, "_set_storage_sort").bind("level"), "SortLevel")
	_add_small_button(storage_popup, _text("sort_name"), Vector2(98, 136), Vector2(52, 28), Callable(self, "_set_storage_sort").bind("name"), "SortName")
	_add_small_button(storage_popup, _text("sort_dex"), Vector2(154, 136), Vector2(52, 28), Callable(self, "_set_storage_sort").bind("dex"), "SortDex")
	_add_small_button(storage_popup, _text("sort_date"), Vector2(210, 136), Vector2(52, 28), Callable(self, "_set_storage_sort").bind("date"), "SortDate")
	_add_small_button(storage_popup, _text("sort_generation"), Vector2(266, 136), Vector2(52, 28), Callable(self, "_set_storage_sort").bind("generation"), "SortGeneration")

	var scroll := ScrollContainer.new()
	scroll.name = "StorageScroll"
	scroll.position = Vector2(28, 172)
	scroll.size = Vector2(304, 398)
	storage_popup.add_child(scroll)
	var rows := _filtered_storage_rows()
	var content := Control.new()
	content.custom_minimum_size = Vector2(304, max(398, rows.size() * 78))
	scroll.add_child(content)
	if rows.is_empty():
		UI.add_panel_label(content, _text("storage_empty"), Vector2(16, 80), Vector2(272, 40), 15, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "EmptyStorage")
	for i in range(rows.size()):
		var row: Dictionary = rows[i]
		var pokemon: Dictionary = row.get("pokemon", {})
		var source_index := int(row.get("index", 0))
		_add_pokemon_card(content, pokemon, Vector2(0, float(i) * 78.0), Vector2(220, 70), false, false)
		_add_small_button(content, _text("withdraw"), Vector2(226, float(i) * 78.0 + 18.0), Vector2(68, 30), Callable(self, "_withdraw_storage_pokemon").bind(source_index), "Withdraw%d" % i)


func _set_storage_sort(sort_mode: String) -> void:
	storage_sort_mode = sort_mode
	if pokemon_popup != null and is_instance_valid(pokemon_popup) and pokemon_popup.name == "PokemonCollectionPopup":
		_show_pokemon_collection()
	else:
		_show_storage()


func _filtered_storage_rows() -> Array:
	var rows := []
	var query := storage_search_text.strip_edges().to_lower()
	var storage := _storage()
	for i in range(storage.size()):
		if typeof(storage[i]) != TYPE_DICTIONARY:
			continue
		var pokemon: Dictionary = storage[i]
		var haystack := "%s %s %s" % [str(pokemon.get("name", "")), str(pokemon.get("species", "")), str(pokemon.get("generation", ""))]
		if query == "" or haystack.to_lower().find(query) >= 0:
			rows.append({"index": i, "pokemon": pokemon})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var pa: Dictionary = a.get("pokemon", {})
		var pb: Dictionary = b.get("pokemon", {})
		match storage_sort_mode:
			"name":
				return str(pa.get("name", pa.get("species", ""))) < str(pb.get("name", pb.get("species", "")))
			"dex":
				return int(pa.get("dex_number", 0)) < int(pb.get("dex_number", 0))
			"date":
				return str(pa.get("capture_date", "")) < str(pb.get("capture_date", ""))
			"generation":
				return int(pa.get("generation", 1)) < int(pb.get("generation", 1))
			_:
				return int(pa.get("level", 1)) > int(pb.get("level", 1))
	)
	return rows


func _filtered_collection_rows() -> Array:
	var rows := []
	var query := storage_search_text.strip_edges().to_lower()
	var team := _team()
	for i in range(team.size()):
		if typeof(team[i]) == TYPE_DICTIONARY:
			_append_collection_row_if_matches(rows, "team", i, team[i], query)
	var storage := _storage()
	for i in range(storage.size()):
		if typeof(storage[i]) == TYPE_DICTIONARY:
			_append_collection_row_if_matches(rows, "storage", i, storage[i], query)
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var pa: Dictionary = a.get("pokemon", {})
		var pb: Dictionary = b.get("pokemon", {})
		match storage_sort_mode:
			"name":
				return str(pa.get("name", pa.get("species", ""))) < str(pb.get("name", pb.get("species", "")))
			"dex":
				return int(pa.get("dex_number", 0)) < int(pb.get("dex_number", 0))
			"date":
				return str(pa.get("capture_date", "")) < str(pb.get("capture_date", ""))
			"generation":
				return int(pa.get("generation", 1)) < int(pb.get("generation", 1))
			_:
				return int(pa.get("level", 1)) > int(pb.get("level", 1))
	)
	return rows


func _append_collection_row_if_matches(rows: Array, source: String, index: int, pokemon: Dictionary, query: String) -> void:
	var normalized := PokemonHelpers.normalize_pokemon(pokemon, str(pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	var haystack := "%s %s %s" % [str(normalized.get("name", "")), str(normalized.get("species", "")), str(normalized.get("generation", ""))]
	if query == "" or haystack.to_lower().find(query) >= 0:
		rows.append({"source": source, "index": index, "pokemon": normalized})


func _collection_total_count() -> int:
	return _team().size() + _storage().size()


func _team_has_center_targets(team: Array) -> bool:
	for entry in team:
		if typeof(entry) == TYPE_DICTIONARY:
			var pokemon := PokemonHelpers.complete_healing_if_ready(entry)
			if not PokemonHelpers.is_healing(pokemon) and _pokemon_needs_center(pokemon):
				return true
	return false


func _team_has_recovering_pokemon(team: Array) -> bool:
	for entry in team:
		if typeof(entry) == TYPE_DICTIONARY and PokemonHelpers.is_healing(entry):
			return true
	return false


func _pokemon_needs_center(pokemon: Dictionary) -> bool:
	var normalized := PokemonHelpers.complete_healing_if_ready(pokemon)
	if int(normalized.get("hp", 0)) < int(normalized.get("max_hp", 1)):
		return true
	var status_value = normalized.get("status_condition", null)
	if status_value != null and str(status_value) != "":
		return true
	var pp_current = normalized.get("pp_current", [])
	var pp_max = normalized.get("pp_max", [])
	if typeof(pp_current) != TYPE_ARRAY or typeof(pp_max) != TYPE_ARRAY:
		return true
	for i in range(pp_max.size()):
		if i >= pp_current.size() or int(pp_current[i]) < int(pp_max[i]):
			return true
	return false


func _center_status_text(team: Array) -> String:
	var recovering := []
	for entry in team:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var pokemon: Dictionary = entry
		var recovery_text := _pokemon_recovery_text(pokemon)
		if recovery_text != "":
			recovering.append("%s %s" % [str(pokemon.get("name", pokemon.get("species", "Pokemon"))), _format_recovery_time(PokemonHelpers.healing_remaining_seconds(pokemon))])
	if not recovering.is_empty():
		return _text("healing_remaining") % ", ".join(recovering)
	return _text("center_cost_time") % POKEMON_CENTER_COST


func _pokemon_recovery_text(pokemon: Dictionary) -> String:
	if not PokemonHelpers.is_healing(pokemon):
		return ""
	return _format_recovery_time(PokemonHelpers.healing_remaining_seconds(pokemon))


func _format_recovery_time(seconds: int) -> String:
	var safe_seconds := maxi(0, seconds)
	var minutes := int(floor(float(safe_seconds) / 60.0))
	var remainder := safe_seconds % 60
	return "%02d:%02d" % [minutes, remainder]


func _refresh_center_countdown() -> void:
	await get_tree().create_timer(1.0).timeout
	if pokemon_center_popup != null and is_instance_valid(pokemon_center_popup):
		_show_pokemon_center()


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
	if storage_popup != null and is_instance_valid(storage_popup):
		storage_popup.queue_free()
	pokemon_popup = null
	pokemon_center_popup = null
	storage_popup = null
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
	if not debug_enabled:
		return
	var now := Time.get_ticks_msec()
	if now > debug_click_deadline_msec:
		debug_click_count = 0
	if debug_click_count == 0:
		debug_click_deadline_msec = now + DEBUG_CLICK_WINDOW_MSEC
	debug_click_count += 1
	if debug_click_count >= 4:
		debug_click_count = 0
		debug_click_deadline_msec = 0
		_show_debug_menu()


func _show_debug_menu() -> void:
	if not debug_enabled:
		return
	if not _has_active_save():
		UI.show_message_popup(self, _text("debug_menu"), _text("no_active_save"))
		return

	if debug_popup != null and is_instance_valid(debug_popup):
		debug_popup.queue_free()

	debug_popup = _create_popup(_text("debug_menu"), "DebugPopup", 34.0, 580.0)
	var scroll := ScrollContainer.new()
	scroll.name = "DebugScroll"
	scroll.position = Vector2(28, 100)
	scroll.size = Vector2(304, 438)
	debug_popup.add_child(scroll)

	var content := Control.new()
	content.name = "DebugContent"
	content.custom_minimum_size = Vector2(304, 806)
	scroll.add_child(content)

	var y := 0.0
	y = _add_debug_section(content, _text("debug_gold"), y)
	y = _add_debug_button_row(content, y, [
		[_text("debug_add") % "1.000", Callable(self, "_debug_add_money").bind(1000)],
		[_text("debug_add") % "10.000", Callable(self, "_debug_add_money").bind(10000)],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_add") % "100.000", Callable(self, "_debug_add_money").bind(100000)],
		[_text("debug_add") % "1.000.000", Callable(self, "_debug_add_money").bind(1000000)],
	])
	y = _add_debug_section(content, _text("debug_account_xp"), y)
	y = _add_debug_button_row(content, y, [
		[_text("debug_add") % "100", Callable(self, "_debug_add_account_xp").bind(100)],
		[_text("debug_add") % "1.000", Callable(self, "_debug_add_account_xp").bind(1000)],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_add") % "10.000", Callable(self, "_debug_add_account_xp").bind(10000)],
	])
	y = _add_debug_section(content, _text("debug_badges"), y)
	y = _add_debug_button_row(content, y, [
		[_text("debug_add") % "1", Callable(self, "_debug_add_badges").bind(1)],
		[_text("debug_all_badges"), Callable(self, "_debug_set_badges").bind(8)],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_remove_badges"), Callable(self, "_debug_set_badges").bind(0)],
	])
	y = _add_debug_section(content, _text("debug_energy"), y)
	y = _add_debug_button_row(content, y, [
		[_text("debug_restore_energy"), Callable(self, "_debug_restore_energy")],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_add") % "5", Callable(self, "_debug_add_energy").bind(5)],
		[_text("debug_add") % "10", Callable(self, "_debug_add_energy").bind(10)],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_add") % "30", Callable(self, "_debug_add_energy").bind(30)],
	])
	y = _add_debug_section(content, _text("debug_pokemon"), y)
	y = _add_debug_button_row(content, y, [
		[_text("debug_heal_team"), Callable(self, "_debug_heal_team")],
		[_text("debug_clear_status"), Callable(self, "_debug_clear_status")],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_restore_pp"), Callable(self, "_debug_restore_pp")],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_add_bulbasaur"), Callable(self, "_debug_add_pokemon").bind("bulbasaur")],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_add_charmander"), Callable(self, "_debug_add_pokemon").bind("charmander")],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_add_squirtle"), Callable(self, "_debug_add_pokemon").bind("squirtle")],
	])
	y = _add_debug_section(content, _text("debug_team"), y)
	y = _add_debug_button_row(content, y, [
		[_text("debug_fill_team"), Callable(self, "_debug_fill_team")],
		[_text("debug_clear_team"), Callable(self, "_debug_clear_team")],
	])
	y = _add_debug_section(content, _text("debug_storage"), y)
	y = _add_debug_button_row(content, y, [
		[_text("debug_clear_storage"), Callable(self, "_debug_clear_storage")],
	])
	y = _add_debug_button_row(content, y, [
		[_text("debug_starters_storage"), Callable(self, "_debug_add_starters_to_storage")],
	])
	content.custom_minimum_size = Vector2(304, y + 12.0)

	_add_small_button(debug_popup, _text("close"), Vector2(110, 550), Vector2(140, 34), Callable(self, "_close_debug_popup"), "DebugClose")


func _add_debug_section(parent: Control, title: String, y: float) -> float:
	var label := UI.add_panel_label(parent, title, Vector2(0, y), Vector2(296, 24), 14, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "DebugSection%s" % title.replace(" ", ""))
	_fit_label(label, false)
	return y + 28.0


func _add_debug_button_row(parent: Control, y: float, actions: Array) -> float:
	for i in range(actions.size()):
		var action = actions[i]
		if typeof(action) != TYPE_ARRAY or action.size() < 2:
			continue
		var button_width := 140.0 if actions.size() > 1 else 292.0
		var x := 0.0 + float(i) * 152.0
		var callback: Callable = action[1]
		_add_small_button(parent, str(action[0]), Vector2(x, y), Vector2(button_width, 32), callback, "DebugAction%d%d" % [int(y), i])
	return y + 38.0


func _debug_add_money(amount: int) -> void:
	_update_debug_save({"money": int(save_data.get("money", 3000)) + amount})


func _debug_add_account_xp(amount: int) -> void:
	var level: int = maxi(1, int(save_data.get("level", 1)))
	var xp: int = maxi(0, int(save_data.get("xp", 0))) + amount
	while level < PokemonHelpers.MAX_LEVEL:
		var required: int = PokemonHelpers.xp_to_next_level_for(level)
		if required <= 0 or xp < required:
			break
		xp -= required
		level += 1
	_update_debug_save({"xp": xp, "level": level})


func _debug_add_badges(amount: int) -> void:
	_update_debug_save({"badges": clampi(int(save_data.get("badges", 0)) + amount, 0, 8)})


func _debug_set_badges(amount: int) -> void:
	_update_debug_save({"badges": clampi(amount, 0, 8)})


func _debug_restore_energy() -> void:
	var energy_max := maxi(1, int(save_data.get("energy_max", 30)))
	_update_debug_save({"energy_current": energy_max})


func _debug_add_energy(amount: int) -> void:
	var energy_max := maxi(1, int(save_data.get("energy_max", 30)))
	var energy_current := clampi(int(save_data.get("energy_current", energy_max)), 0, energy_max)
	_update_debug_save({"energy_current": mini(energy_max, energy_current + amount)})


func _debug_heal_team() -> void:
	var team := _team()
	for i in range(team.size()):
		if typeof(team[i]) == TYPE_DICTIONARY:
			var pokemon: Dictionary = team[i]
			pokemon["hp"] = int(pokemon.get("max_hp", 39))
			pokemon["status_condition"] = null
			pokemon["pp_current"] = pokemon.get("pp_max", [])
			pokemon["healing"] = false
			pokemon["healing_finish_timestamp"] = 0
			team[i] = PokemonHelpers.normalize_pokemon(pokemon, str(pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	_update_debug_save({"team": team})


func _debug_clear_status() -> void:
	var team := _team()
	for i in range(team.size()):
		if typeof(team[i]) == TYPE_DICTIONARY:
			var pokemon: Dictionary = team[i]
			pokemon["status_condition"] = null
			team[i] = PokemonHelpers.normalize_pokemon(pokemon, str(pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	_update_debug_save({"team": team})


func _debug_restore_pp() -> void:
	var team := _team()
	for i in range(team.size()):
		if typeof(team[i]) == TYPE_DICTIONARY:
			var pokemon: Dictionary = team[i]
			pokemon["pp_current"] = pokemon.get("pp_max", [])
			team[i] = PokemonHelpers.normalize_pokemon(pokemon, str(pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	_update_debug_save({"team": team})


func _debug_add_pokemon(pokemon_id: String) -> void:
	var team := _team()
	var storage := _storage()
	var pokemon := _debug_new_pokemon(pokemon_id)
	if team.size() < TEAM_LIMIT:
		team.append(pokemon)
	elif storage.size() < SaveManager.MAX_STORAGE_SIZE:
		storage.append(pokemon)
	_update_debug_save(_debug_with_seen_owned({"team": team, "storage": storage}, [pokemon_id]))


func _debug_fill_team() -> void:
	var team := _team()
	var starter_ids := PokemonHelpers.starter_ids()
	var index := 0
	while team.size() < TEAM_LIMIT:
		team.append(_debug_new_pokemon(str(starter_ids[index % starter_ids.size()])))
		index += 1
	_update_debug_save(_debug_with_seen_owned({"team": team, "active_pokemon_index": _active_pokemon_index(team)}, starter_ids))


func _debug_clear_team() -> void:
	var starter_id := str(save_data.get("starter_id", PokemonHelpers.DEFAULT_STARTER_ID))
	var team := [_debug_new_pokemon(starter_id)]
	_update_debug_save(_debug_with_seen_owned({"team": team, "active_pokemon_index": 0}, [starter_id]))


func _debug_clear_storage() -> void:
	_update_debug_save({"storage": []})


func _debug_add_starters_to_storage() -> void:
	var storage := _storage()
	var starter_ids := PokemonHelpers.starter_ids()
	for pokemon_id in starter_ids:
		if storage.size() >= SaveManager.MAX_STORAGE_SIZE:
			break
		storage.append(_debug_new_pokemon(str(pokemon_id)))
	_update_debug_save(_debug_with_seen_owned({"storage": storage}, starter_ids))


func _debug_new_pokemon(pokemon_id: String) -> Dictionary:
	var pokemon := PokemonHelpers.starter_save_data(pokemon_id)
	pokemon["capture_date"] = Time.get_datetime_string_from_system()
	return PokemonHelpers.normalize_pokemon(pokemon, pokemon_id)


func _debug_with_seen_owned(changes: Dictionary, pokemon_ids: Array) -> Dictionary:
	var updated := changes.duplicate(true)
	var seen := _seen_pokemon_ids().duplicate()
	var owned := _owned_pokemon_ids().duplicate()
	for pokemon_id in pokemon_ids:
		var safe_id := str(pokemon_id)
		if PokemonHelpers.has_definition(safe_id):
			if not seen.has(safe_id):
				seen.append(safe_id)
			if not owned.has(safe_id):
				owned.append(safe_id)
	updated["seen_pokemon"] = seen
	updated["owned_pokemon"] = owned
	return updated


func _update_debug_save(changes: Dictionary) -> void:
	if not _has_active_save():
		UI.show_message_popup(self, _text("debug_menu"), _text("no_active_save"))
		return

	SaveManager.update_current_save(changes)
	_refresh_save_data()
	_refresh_home_stats()
	if debug_popup != null and is_instance_valid(debug_popup):
		_show_debug_menu()


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


func _stat_name(stat_key: String) -> String:
	var safe_key := PokemonHelpers.normalized_stat_key(stat_key)
	if safe_key == "":
		return _text("type")
	return _text("stat_%s" % safe_key)


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
