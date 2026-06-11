extends Control

const UI = preload("res://scripts/ui_factory.gd")
const WorldMapData = preload("res://scripts/world_map_data.gd")

const TEXT = {
	"en": {
		"energy": "Energy",
		"explore": "Explore Map",
		"types": "Pokemon types on this map:",
		"requires": "Requires Lv. %d / %d badges",
		"none_found": "None pokemon found",
		"found": "Pokemon %s found!",
		"fight": "Click here to fight",
		"no_energy": "Your energy has been depleted for today.",
		"level": "Level",
		"forest": "Forest Map",
		"fire": "Fire Map",
		"cave": "Cave Map",
		"ice": "Ice Map",
		"factory": "Factory Map",
		"water": "Water Map",
		"electric": "Electric Map",
		"desert": "Desert Map",
		"ghost": "Ghost Tower",
		"dragon": "Dragon Valley",
		"safari": "Safari Zone",
	},
	"pt": {
		"energy": "Energia",
		"explore": "Explorar Mapa",
		"types": "Tipos de Pokemon neste mapa:",
		"requires": "Requer Nv. %d / %d insígnias",
		"none_found": "None pokemon found",
		"found": "Pokemon %s found!",
		"fight": "Click here to fight",
		"no_energy": "Você está sem energia para explorar hoje.",
		"level": "Nível",
		"forest": "Floresta",
		"fire": "Mapa de Fogo",
		"cave": "Caverna",
		"ice": "Mapa de Gelo",
		"factory": "Fábrica",
		"water": "Mapa de Água",
		"electric": "Mapa Elétrico",
		"desert": "Deserto",
		"ghost": "Torre Fantasma",
		"dragon": "Vale dos Dragões",
		"safari": "Zona Safari",
	},
}

var settings: Dictionary = {}
var save_data: Dictionary = {}
var map_data: Dictionary = {}
var current_map_key := "forest"
var current_encounter: Dictionary = {}
var result_container: Control
var energy_label: Label
var explore_button: TextureButton


func _ready() -> void:
	randomize()
	settings = SaveManager.load_settings()
	_refresh_save_data()
	current_map_key = str(save_data.get("current_map", "forest"))
	map_data = WorldMapData.map_for_key(current_map_key)

	UI.setup_screen(self)
	_add_background()
	UI.add_topbar(self)
	_add_fit_label(self, _map_title(), Vector2(60, 6), Vector2(240, 32), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TopTitle", false)
	_build_map_screen()


func _refresh_save_data() -> void:
	save_data = SaveManager.get_current_save()
	if save_data.is_empty() and SaveManager.has_save(1):
		save_data = SaveManager.load_save(1)


func _add_background() -> void:
	var background := str(map_data.get("background", ""))
	if background != "" and FileAccess.file_exists(background):
		var texture := UI.add_texture(self, background, Vector2.ZERO, UI.SCREEN_SIZE, "MapBackground", TextureRect.STRETCH_SCALE)
		texture.modulate = Color(0.78, 0.82, 0.86, 1)
	else:
		UI.add_background(self)


func _build_map_screen() -> void:
	_add_fit_label(self, _map_title(), Vector2(20, 54), Vector2(320, 30), 22, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Title", false)
	_add_map_icon()
	_add_fit_label(self, _requirements_text(), Vector2(28, 154), Vector2(304, 32), 14, Color(0.94, 0.97, 1.0), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Requirement", true)
	energy_label = _add_fit_label(self, _energy_text(), Vector2(28, 190), Vector2(304, 28), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Energy", false)
	_add_fit_label(self, _text("types"), Vector2(24, 232), Vector2(312, 28), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TypesText", true)

	_add_badges()
	explore_button = UI.add_orange_button(self, _text("explore"), Vector2(70, 358), Vector2(220, 48), Callable(self, "_explore_map"), "ExploreButton")
	if not WorldMapData.meets_requirements(save_data, map_data):
		explore_button.disabled = true
		explore_button.modulate = Color(0.62, 0.62, 0.62, 0.9)

	result_container = Control.new()
	result_container.name = "Result"
	result_container.position = Vector2(0, 412)
	result_container.size = Vector2(360, 210)
	add_child(result_container)


func _add_map_icon() -> void:
	var icon_path := str(map_data.get("icon", ""))
	if icon_path == "" or not FileAccess.file_exists(icon_path):
		icon_path = str(map_data.get("thumbnail", ""))

	if icon_path != "" and FileAccess.file_exists(icon_path):
		UI.add_texture(self, icon_path, Vector2(142, 88), Vector2(76, 58), "MapIcon", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		return

	var placeholder := ColorRect.new()
	placeholder.name = "MapIconPlaceholder"
	placeholder.position = Vector2(142, 88)
	placeholder.size = Vector2(76, 58)
	placeholder.color = Color(0.28, 0.42, 0.54, 0.95)
	add_child(placeholder)
	_add_fit_label(placeholder, _map_title().substr(0, 2).to_upper(), Vector2.ZERO, placeholder.size, 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Code", false)


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
	_refresh_save_data()

	if not WorldMapData.meets_requirements(save_data, map_data):
		_show_center_result(_requirements_text(), Color.WHITE)
		return

	var energy_current := int(save_data.get("energy_current", 30))
	if energy_current <= 0:
		_show_center_result(_text("no_energy"), Color.WHITE)
		return

	var next_energy: int = max(0, energy_current - 1)
	current_encounter = WorldMapData.roll_encounter(current_map_key)
	var changes: Dictionary = {
		"energy_current": next_energy,
		"current_map": current_map_key,
		"pending_encounter": current_encounter,
	}
	SaveManager.update_current_save(changes)
	_refresh_save_data()
	_update_energy_label()

	if current_encounter.is_empty():
		_show_center_result(_text("none_found"), Color.WHITE)
		return

	_show_encounter_result(current_encounter)


func _show_encounter_result(pokemon: Dictionary) -> void:
	var icon_path := str(pokemon.get("icon_path", ""))
	if icon_path != "" and FileAccess.file_exists(icon_path):
		UI.add_texture(result_container, icon_path, Vector2(28, 8), Vector2(96, 96), "EncounterSprite", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	else:
		var placeholder := ColorRect.new()
		placeholder.name = "EncounterPlaceholder"
		placeholder.position = Vector2(28, 8)
		placeholder.size = Vector2(96, 96)
		placeholder.color = Color(0.28, 0.42, 0.54, 0.95)
		result_container.add_child(placeholder)

	_add_fit_label(result_container, _text("found") % str(pokemon.get("name", "Pokemon")), Vector2(128, 8), Vector2(204, 40), 16, Color(0.2, 0.62, 1.0), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "FoundText", true)
	_add_fit_label(result_container, "%s: %d" % [_text("level"), int(pokemon.get("level", 1))], Vector2(128, 54), Vector2(204, 28), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Level", false)
	UI.add_orange_button(result_container, _text("fight"), Vector2(55, 132), Vector2(250, 52), Callable(self, "_open_battle_scene"), "FightButton")


func _show_center_result(message: String, color: Color) -> void:
	_add_fit_label(result_container, message, Vector2(20, 42), Vector2(320, 70), 18, color, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "ResultMessage", true)


func _clear_result() -> void:
	for child in result_container.get_children():
		child.queue_free()


func _open_battle_scene() -> void:
	if current_encounter.is_empty():
		return
	SaveManager.update_current_save({"pending_encounter": current_encounter, "current_map": current_map_key})
	get_tree().change_scene_to_file("res://scenes/BattleScene.tscn")


func _update_energy_label() -> void:
	if energy_label != null and is_instance_valid(energy_label):
		energy_label.text = _energy_text()


func _energy_text() -> String:
	return "%s %d/%d" % [_text("energy"), int(save_data.get("energy_current", 30)), int(save_data.get("energy_max", 30))]


func _requirements_text() -> String:
	return _text("requires") % [int(map_data.get("min_level", 1)), int(map_data.get("min_badges", 0))]


func _map_title() -> String:
	return _text(str(map_data.get("key", "forest")))


func _add_fit_label(parent: Node, text: String, pos: Vector2, node_size: Vector2, font_size: int, color: Color, align: int, valign: int, node_name: String, wrap: bool) -> Label:
	var label := UI.add_label(parent, text, pos, node_size, font_size, color, align, valign, node_name)
	label.clip_text = true
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return label


func _language() -> String:
	var language := str(settings.get("language", "en"))
	return language if TEXT.has(language) else "en"


func _text(key: String) -> String:
	var language_text: Dictionary = TEXT[_language()]
	var english_text: Dictionary = TEXT["en"]
	return str(language_text.get(key, english_text.get(key, key)))
