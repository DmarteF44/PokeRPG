extends Control

const UI = preload("res://scripts/ui_factory.gd")
const WorldMapData = preload("res://scripts/world_map_data.gd")
const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

const TEXT = {
	"en": {
		"energy": "Energy",
		"explore": "Explore Map",
		"types": "Pokemon types on this map:",
		"requires": "Requires Lv. %d / %d badges",
		"none_found": "You explored the area but found nothing.",
		"found": "Pokemon %s found!",
		"item_found": "Found item: %s x%d",
		"fight": "Fight",
		"ignore_encounter": "Ignore",
		"no_energy": "You are out of energy.",
		"no_ready_pokemon": "No Pokemon is ready to explore.",
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
		"fish": "Fish",
		"no_fishing_gear": "You need a fishing rod and line to fish here.",
		"no_bait": "You have no bait left.",
		"incompatible_gear": "Your line is too strong for your rod! Fishing with reduced tier.",
		"gear_too_weak": "This area needs stronger fishing gear (an Obsidian Rod and matching line).",
		"lava": "Lava Fields",
		"reel": "Reel!",
		"fishing_hint": "Tap Reel when the marker is in the zone!",
		"fish_hooked": "Something's biting!",
		"fish_escaped": "The fish got away...",
	},
	"pt": {
		"energy": "Energia",
		"explore": "Explorar Mapa",
		"types": "Tipos de Pokemon neste mapa:",
		"requires": "Requer Nv. %d / %d insígnias",
		"none_found": "Você explorou a área, mas não encontrou nada.",
		"found": "Pokemon %s encontrado!",
		"item_found": "Item encontrado: %s x%d",
		"fight": "Lutar",
		"ignore_encounter": "Ignorar",
		"no_energy": "Você está sem energia.",
		"no_ready_pokemon": "Nenhum Pokémon está pronto para explorar.",
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
		"fish": "Pescar",
		"no_fishing_gear": "Você precisa de uma vara e uma linha de pesca para pescar aqui.",
		"no_bait": "Você não tem mais iscas.",
		"incompatible_gear": "Sua linha é forte demais para sua vara! Pescando com nível reduzido.",
		"gear_too_weak": "Esta área exige equipamento de pesca mais forte (uma Vara de Obsidiana e linha compatível).",
		"lava": "Campos de Lava",
		"reel": "Puxar!",
		"fishing_hint": "Toque em Puxar quando o marcador estiver na zona!",
		"fish_hooked": "Algo está mordendo a isca!",
		"fish_escaped": "O peixe escapou...",
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
	_add_home_button()
	_add_hud_icons()
	_build_map_screen()


# The topbar here is just a static background image (unlike Home's, which
# adds its own icon row) - without this there was no way back to Home short
# of the Android hardware back button.
func _add_home_button() -> void:
	var button := Button.new()
	button.name = "HomeButton"
	button.text = "←"
	button.position = Vector2(8, 6)
	button.size = Vector2(34, 32)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.flat = true
	add_child(button)
	button.pressed.connect(func():
		AudioManager.play_sfx("click")
		get_tree().change_scene_to_file("res://scenes/HomeScreen.tscn")
	)


# Mirrors Home's own topbar icon row (same icons, same x positions) so the
# bag/shop/pokemon/etc. screens are one tap away while exploring too, instead
# of forcing a trip back to Home first. World Map is left out since the
# back arrow above already covers "leave this map", and traveling to a
# different map is still reachable from Home.
const HUD_ICON_DATA = [
	["res://assets/ui/icons/icon_tournament_32.png", 58.0, "tournament", "T"],
	["res://assets/ui/icons/icon_pokemon.png", 108.0, "pokemon", "P"],
	["res://assets/ui/icons/icon_bag_32.png", 158.0, "bag", "B"],
	["res://assets/ui/icons/icon_shop_32.png", 208.0, "shop", "S"],
	["res://assets/ui/icons/icon_profile_32.png", 258.0, "profile", "U"],
	["res://assets/ui/icons/icon_options_32.png", 318.0, "options", "O"],
]


func _add_hud_icons() -> void:
	for data in HUD_ICON_DATA:
		var icon_path: String = data[0]
		var x: float = data[1]
		var popup_key: String = data[2]
		var fallback_text: String = data[3]
		var pos := Vector2(x, 6.0)
		var callback := Callable(self, "_open_home_popup").bind(popup_key)
		if UI.resource_exists(icon_path):
			UI.add_icon_button(self, icon_path, pos, callback, "Hud%s" % popup_key.capitalize())
		else:
			_add_hud_fallback_icon(pos, callback, popup_key, fallback_text)


func _add_hud_fallback_icon(pos: Vector2, callback: Callable, popup_key: String, fallback_text: String) -> void:
	var button := Button.new()
	button.name = "Hud%sFallback" % popup_key.capitalize()
	button.text = fallback_text
	button.position = pos
	button.size = Vector2(32, 32)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	add_child(button)
	button.pressed.connect(func():
		AudioManager.play_sfx("click")
		callback.call()
	)


func _open_home_popup(popup_key: String) -> void:
	GameState.pending_home_popup = popup_key
	get_tree().change_scene_to_file("res://scenes/HomeScreen.tscn")


func _refresh_save_data() -> void:
	save_data = SaveManager.get_current_save()
	if save_data.is_empty() and SaveManager.has_save(1):
		save_data = SaveManager.load_save(1)


func _add_background() -> void:
	var background := str(map_data.get("background", ""))
	if UI.resource_exists(background):
		var texture := UI.add_texture(self, background, Vector2.ZERO, UI.SCREEN_SIZE, "MapBackground", TextureRect.STRETCH_SCALE)
		texture.modulate = Color(0.78, 0.82, 0.86, 1)
	else:
		UI.add_background(self)


func _build_map_screen() -> void:
	_add_map_icon()
	_add_fit_label(self, _requirements_text(), Vector2(28, 154), Vector2(304, 32), 14, Color(0.94, 0.97, 1.0), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Requirement", true)
	energy_label = _add_fit_label(self, _energy_text(), Vector2(28, 190), Vector2(304, 28), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Energy", false)
	_add_fit_label(self, _text("types"), Vector2(24, 232), Vector2(312, 28), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TypesText", true)

	_add_badges()
	var can_explore := WorldMapData.meets_requirements(save_data, map_data)
	if current_map_key == "water":
		explore_button = UI.add_orange_button(self, _text("explore"), Vector2(18, 358), Vector2(160, 48), Callable(self, "_explore_map"), "ExploreButton")
		var fish_button := UI.add_orange_button(self, _text("fish"), Vector2(182, 358), Vector2(160, 48), Callable(self, "_start_fishing"), "FishButton")
		if not can_explore:
			fish_button.disabled = true
			fish_button.modulate = Color(0.62, 0.62, 0.62, 0.9)
	else:
		explore_button = UI.add_orange_button(self, _text("explore"), Vector2(70, 358), Vector2(220, 48), Callable(self, "_explore_map"), "ExploreButton")
	if not can_explore:
		explore_button.disabled = true
		explore_button.modulate = Color(0.62, 0.62, 0.62, 0.9)

	result_container = Control.new()
	result_container.name = "Result"
	result_container.position = Vector2(0, 412)
	result_container.size = Vector2(360, 210)
	add_child(result_container)


func _add_map_icon() -> void:
	var icon_path := str(map_data.get("icon", ""))
	if not UI.resource_exists(icon_path):
		icon_path = str(map_data.get("thumbnail", ""))

	if UI.resource_exists(icon_path):
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

	if not _has_battle_ready_pokemon():
		_show_center_result(_text("no_ready_pokemon"), Color.WHITE)
		return

	var energy_current := int(save_data.get("energy_current", 30))
	if energy_current <= 0:
		_show_center_result(_text("no_energy"), Color.WHITE)
		return

	var next_energy: int = max(0, energy_current - 1)
	var exploration_result := WorldMapData.roll_exploration(current_map_key)
	var changes: Dictionary = {
		"energy_current": next_energy,
		"current_map": current_map_key,
		"pending_encounter": {},
	}
	SaveManager.update_current_save(changes)
	_refresh_save_data()
	_update_energy_label()

	var result_type := str(exploration_result.get("type", "nothing"))
	if result_type == "nothing":
		_show_center_result(_text("none_found"), Color.WHITE)
		return

	if result_type == "item":
		var item_id := str(exploration_result.get("item_id", "potion"))
		var amount := maxi(1, int(exploration_result.get("amount", 1)))
		InventoryManager.add_item(item_id, amount)
		_show_center_result(_text("item_found") % [_item_display_name(item_id), amount], Color(0.96, 0.86, 0.32))
		return

	current_encounter = exploration_result.get("pokemon", {})
	if current_encounter.is_empty():
		_show_center_result(_text("none_found"), Color.WHITE)
		return

	var seen = save_data.get("seen_pokemon", [])
	if typeof(seen) != TYPE_ARRAY:
		seen = []
	var encounter_id := str(current_encounter.get("id", ""))
	if encounter_id != "" and not seen.has(encounter_id):
		seen.append(encounter_id)
	SaveManager.update_current_save({"pending_encounter": current_encounter, "current_map": current_map_key, "seen_pokemon": seen})
	_refresh_save_data()
	_show_encounter_result(current_encounter)


const ITEMS_PATH = "res://data/items.json"
const FISHING_BAR_WIDTH = 280.0
const FISHING_MARKER_WIDTH = 12.0
var fishing_marker: ColorRect
var fishing_zone_start := 0.0
var fishing_zone_width := 60.0
var fishing_tween: Tween
var fishing_gear_cache: Dictionary = {}


func _loaded_items() -> Array:
	var file := FileAccess.open(ITEMS_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_ARRAY else []


# Uses whichever owned rod/line/bait is best; there's no separate "equip"
# step since the player only ever owns one of each at a time in practice
# (rods/lines are one-time purchases, not consumed).
func _fishing_gear() -> Dictionary:
	var items := _loaded_items()
	var rod_tier := 0
	var line_tier := 0
	var best_bait := {}
	for item in items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var item_id := str(item.get("id", ""))
		if InventoryManager.get_item_amount(item_id) <= 0:
			continue
		var effect_type := str(item.get("effect_type", ""))
		if effect_type == "fishing_rod":
			rod_tier = maxi(rod_tier, int(item.get("fishing_tier", 0)))
		elif effect_type == "fishing_line":
			line_tier = maxi(line_tier, int(item.get("fishing_tier", 0)))
		elif effect_type == "fishing_bait":
			if best_bait.is_empty() or int(item.get("rarity_bonus", 0)) > int(best_bait.get("rarity_bonus", 0)):
				best_bait = item
	if rod_tier <= 0 or line_tier <= 0:
		return {}
	return {
		"rod_tier": rod_tier,
		"line_tier": line_tier,
		"effective_tier": mini(rod_tier, line_tier),
		"bait_id": str(best_bait.get("id", "")),
		"bait_rarity_bonus": int(best_bait.get("rarity_bonus", 0)),
		"bait_amount": InventoryManager.get_item_amount(str(best_bait.get("id", ""))),
	}


func _start_fishing() -> void:
	_clear_result()
	_refresh_save_data()
	if not WorldMapData.meets_requirements(save_data, map_data):
		_show_center_result(_requirements_text(), Color.WHITE)
		return
	if not _has_battle_ready_pokemon():
		_show_center_result(_text("no_ready_pokemon"), Color.WHITE)
		return
	var energy_current := int(save_data.get("energy_current", 30))
	if energy_current <= 0:
		_show_center_result(_text("no_energy"), Color.WHITE)
		return
	var gear := _fishing_gear()
	if gear.is_empty():
		_show_center_result(_text("no_fishing_gear"), Color.WHITE)
		return
	if int(gear.get("bait_amount", 0)) <= 0:
		_show_center_result(_text("no_bait"), Color.WHITE)
		return
	var required_tier := int(map_data.get("required_fishing_tier", 0))
	if required_tier > 0 and int(gear.get("effective_tier", 0)) < required_tier:
		_show_center_result(_text("gear_too_weak"), Color.WHITE)
		return
	fishing_gear_cache = gear
	_show_fishing_minigame(gear)


func _show_fishing_minigame(gear: Dictionary) -> void:
	if int(gear.get("line_tier", 1)) > int(gear.get("rod_tier", 1)):
		_add_fit_label(result_container, _text("incompatible_gear"), Vector2(20, 0), Vector2(320, 34), 12, Color(0.98, 0.72, 0.32), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "GearWarning", true)

	_add_fit_label(result_container, _text("fishing_hint"), Vector2(20, 32), Vector2(320, 24), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "FishingHint", true)

	# Better bait widens the success zone, matching its rarity_bonus.
	fishing_zone_width = 60.0 + float(gear.get("bait_rarity_bonus", 0)) * 20.0
	fishing_zone_start = randf() * (FISHING_BAR_WIDTH - fishing_zone_width)

	var bar_bg := ColorRect.new()
	bar_bg.name = "FishingBarBg"
	bar_bg.position = Vector2(40, 66)
	bar_bg.size = Vector2(FISHING_BAR_WIDTH, 20)
	bar_bg.color = Color(0.05, 0.05, 0.05, 0.9)
	result_container.add_child(bar_bg)

	var zone := ColorRect.new()
	zone.name = "FishingZone"
	zone.position = Vector2(40 + fishing_zone_start, 66)
	zone.size = Vector2(fishing_zone_width, 20)
	zone.color = Color(0.30, 0.85, 0.40, 0.9)
	result_container.add_child(zone)

	fishing_marker = ColorRect.new()
	fishing_marker.name = "FishingMarker"
	fishing_marker.position = Vector2(40, 64)
	fishing_marker.size = Vector2(FISHING_MARKER_WIDTH, 24)
	fishing_marker.color = Color(0.95, 0.95, 0.95, 1.0)
	result_container.add_child(fishing_marker)

	fishing_tween = create_tween()
	fishing_tween.set_loops()
	fishing_tween.tween_property(fishing_marker, "position:x", 40.0 + FISHING_BAR_WIDTH - FISHING_MARKER_WIDTH, 0.9).set_trans(Tween.TRANS_LINEAR)
	fishing_tween.tween_property(fishing_marker, "position:x", 40.0, 0.9).set_trans(Tween.TRANS_LINEAR)

	UI.add_orange_button(result_container, _text("reel"), Vector2(70, 156), Vector2(220, 48), Callable(self, "_resolve_fishing"), "ReelButton")


func _resolve_fishing() -> void:
	if fishing_tween != null and fishing_tween.is_valid():
		fishing_tween.kill()
	var marker_x := 40.0
	if fishing_marker != null and is_instance_valid(fishing_marker):
		marker_x = fishing_marker.position.x
	var relative_x := marker_x - 40.0
	var hit := relative_x >= fishing_zone_start and relative_x <= fishing_zone_start + fishing_zone_width

	var gear := fishing_gear_cache
	InventoryManager.remove_item(str(gear.get("bait_id", "")), 1)
	var energy_current := int(save_data.get("energy_current", 30))
	SaveManager.update_current_save({"energy_current": maxi(0, energy_current - 1), "current_map": current_map_key})
	_refresh_save_data()
	_update_energy_label()
	_clear_result()

	if not hit:
		_show_center_result(_text("fish_escaped"), Color.WHITE)
		return

	var exploration_result := WorldMapData.roll_encounter(current_map_key)
	current_encounter = exploration_result
	if current_encounter.is_empty():
		_show_center_result(_text("fish_escaped"), Color.WHITE)
		return

	var seen = save_data.get("seen_pokemon", [])
	if typeof(seen) != TYPE_ARRAY:
		seen = []
	var encounter_id := str(current_encounter.get("id", ""))
	if encounter_id != "" and not seen.has(encounter_id):
		seen.append(encounter_id)
	SaveManager.update_current_save({"pending_encounter": current_encounter, "current_map": current_map_key, "seen_pokemon": seen})
	_refresh_save_data()
	_show_encounter_result(current_encounter)


func _show_encounter_result(pokemon: Dictionary) -> void:
	var display_pokemon := PokemonHelpers.normalize_pokemon(pokemon, str(pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	PokemonHelpers.add_animated_sprite(result_container, display_pokemon, Vector2(28, 0), Vector2(96, 96), false, "EncounterSprite")

	_add_fit_label(result_container, _text("found") % str(pokemon.get("name", "Pokemon")), Vector2(128, 8), Vector2(204, 40), 16, Color(0.2, 0.62, 1.0), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "FoundText", true)
	_add_fit_label(result_container, "%s: %d" % [_text("level"), int(pokemon.get("level", 1))], Vector2(128, 54), Vector2(204, 28), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Level", false)
	UI.add_orange_button(result_container, _text("fight"), Vector2(20, 132), Vector2(158, 52), Callable(self, "_open_battle_scene"), "FightButton")
	UI.add_orange_button(result_container, _text("ignore_encounter"), Vector2(182, 132), Vector2(158, 52), Callable(self, "_ignore_encounter"), "IgnoreButton")


func _ignore_encounter() -> void:
	current_encounter = {}
	SaveManager.update_current_save({"pending_encounter": {}})
	_refresh_save_data()
	_clear_result()


func _show_center_result(message: String, color: Color) -> void:
	_add_fit_label(result_container, message, Vector2(20, 42), Vector2(320, 70), 18, color, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "ResultMessage", true)


func _clear_result() -> void:
	if fishing_tween != null and fishing_tween.is_valid():
		fishing_tween.kill()
	# Freed immediately (not queue_free) so a result screen rebuilt in the same
	# call (e.g. tapping Explore/Fish again right away) never collides with a
	# same-named node still pending deletion from the previous result.
	for child in result_container.get_children():
		child.free()


func _open_battle_scene() -> void:
	if current_encounter.is_empty():
		return
	SaveManager.update_current_save({"pending_encounter": current_encounter, "current_map": current_map_key})
	get_tree().change_scene_to_file("res://scenes/BattleScene.tscn")


func _has_battle_ready_pokemon() -> bool:
	var team_value = save_data.get("team", [])
	if typeof(team_value) != TYPE_ARRAY:
		return false
	for entry in team_value:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var pokemon := PokemonHelpers.complete_healing_if_ready(entry)
		if int(pokemon.get("hp", 0)) > 0 and not PokemonHelpers.is_healing(pokemon):
			return true
	return false


func _item_display_name(item_id: String) -> String:
	var formatted := []
	for word in item_id.split("_", false):
		formatted.append(str(word).capitalize())
	return " ".join(formatted)


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
