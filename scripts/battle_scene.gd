extends Control

const UI = preload("res://scripts/ui_factory.gd")
const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")

const TEXT = {
	"en": {
		"battle": "Battle",
		"attack": "Attack",
		"bag": "Bag",
		"pokemon": "Pokemon",
		"run": "Run",
		"hp": "HP",
		"level": "Lv.",
		"wild_appeared": "Wild %s appeared!",
		"go": "Go! %s!",
		"what_do": "What will %s do?",
		"used": "%s used %s!",
		"damage": "Damage: %d",
		"enemy_fainted": "Enemy fainted!",
		"your_fainted": "Your Pokemon fainted!",
		"xp_gain": "%s gained 25 XP!",
		"level_up": "%s grew to level %d!",
		"battle_bag_soon": "Battle Bag coming soon.",
		"switch_soon": "Switching Pokemon coming soon.",
		"return_home": "Return Home",
	},
	"pt": {
		"battle": "Batalha",
		"attack": "Atacar",
		"bag": "Mochila",
		"pokemon": "Pokemon",
		"run": "Fugir",
		"hp": "HP",
		"level": "Nv.",
		"wild_appeared": "%s selvagem apareceu!",
		"go": "Vai! %s!",
		"what_do": "O que %s vai fazer?",
		"used": "%s usou %s!",
		"damage": "Dano: %d",
		"enemy_fainted": "O inimigo desmaiou!",
		"your_fainted": "Seu Pokémon desmaiou!",
		"xp_gain": "%s ganhou 25 XP!",
		"level_up": "%s subiu para o nível %d!",
		"battle_bag_soon": "Mochila em batalha em breve.",
		"switch_soon": "Troca de Pokémon em breve.",
		"return_home": "Voltar para Home",
	},
}

var settings: Dictionary = {}
var save_data: Dictionary = {}
var player_pokemon: Dictionary = {}
var enemy_pokemon: Dictionary = {}
var player_team_index := 0
var battle_over := false

var message_label: Label
var action_panel: Control
var attack_panel: Control
var enemy_hp_fill: ColorRect
var enemy_hp_label: Label
var enemy_name_label: Label
var player_hp_fill: ColorRect
var player_hp_label: Label
var player_name_label: Label


func _ready() -> void:
	randomize()
	settings = SaveManager.load_settings()
	_setup_battle_data()
	UI.setup_screen(self)
	UI.add_background(self)
	UI.add_topbar(self)
	UI.add_label(self, _text("battle"), Vector2(60, 6), Vector2(240, 32), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TopTitle")

	_add_enemy_area()
	_add_player_area()
	_add_message_box()
	_add_action_buttons()
	_update_status()
	message_label.text = "%s\n%s\n%s" % [
		_text("wild_appeared") % str(enemy_pokemon.get("name", "Wild Dummy")),
		_text("go") % str(player_pokemon.get("name", "Pokemon")),
		_text("what_do") % str(player_pokemon.get("name", "Pokemon")),
	]


func _setup_battle_data() -> void:
	save_data = SaveManager.get_current_save()
	if save_data.is_empty() and SaveManager.has_save(1):
		save_data = SaveManager.load_save(1)

	var team_value = save_data.get("team", []) if not save_data.is_empty() else []
	if typeof(team_value) == TYPE_ARRAY and not team_value.is_empty() and typeof(team_value[0]) == TYPE_DICTIONARY:
		player_team_index = 0
		player_pokemon = PokemonHelpers.normalize_pokemon(team_value[0])
	else:
		player_pokemon = PokemonHelpers.starter_save_data(PokemonHelpers.DEFAULT_STARTER_ID)

	var pending_encounter = save_data.get("pending_encounter", {}) if not save_data.is_empty() else {}
	if typeof(pending_encounter) == TYPE_DICTIONARY and not pending_encounter.is_empty():
		enemy_pokemon = _normalize_enemy_pokemon(pending_encounter)
	else:
		enemy_pokemon = _normalize_enemy_pokemon({
			"id": "wurmple",
			"dex_number": 265,
			"name": "Wurmple",
			"level": 3,
			"hp": 25,
			"max_hp": 25,
			"attack": 8,
			"defense": 5,
			"speed": 30,
			"types": ["Bug"],
			"icon_path": "res://assets/sprites/sprite_wurmple_96.png",
		})


func _normalize_enemy_pokemon(value: Dictionary) -> Dictionary:
	var max_hp: int = max(1, int(value.get("max_hp", value.get("hp", 25))))
	var hp: int = clampi(int(value.get("hp", max_hp)), 0, max_hp)
	var types_value = value.get("types", ["Normal"])
	var types: Array = ["Normal"]
	if typeof(types_value) != TYPE_ARRAY or types_value.is_empty():
		types = ["Normal"]
	else:
		types = types_value
	return {
		"id": str(value.get("id", "wurmple")),
		"dex_number": int(value.get("dex_number", 0)),
		"name": str(value.get("name", "Pokemon")),
		"level": max(1, int(value.get("level", 3))),
		"hp": hp,
		"max_hp": max_hp,
		"attack": max(1, int(value.get("attack", 8))),
		"defense": max(1, int(value.get("defense", 5))),
		"speed": max(1, int(value.get("speed", 30))),
		"types": types,
		"icon_path": str(value.get("icon_path", "res://assets/sprites/sprite_wurmple_96.png")),
	}


func _add_enemy_area() -> void:
	enemy_name_label = UI.add_label(self, "", Vector2(18, 62), Vector2(180, 24), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "EnemyName")
	enemy_hp_fill = _add_hp_bar(Vector2(18, 92), Vector2(146, 12), "Enemy")
	enemy_hp_label = UI.add_label(self, "", Vector2(18, 108), Vector2(146, 22), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "EnemyHpText")
	PokemonHelpers.add_animated_sprite(self, enemy_pokemon, Vector2(226, 70), Vector2(96, 96), false, "EnemySprite")


func _add_player_area() -> void:
	PokemonHelpers.add_animated_sprite(self, player_pokemon, Vector2(36, 266), Vector2(112, 112), true, "PlayerSprite")
	player_name_label = UI.add_label(self, "", Vector2(166, 278), Vector2(178, 24), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER, "PlayerName")
	player_hp_fill = _add_hp_bar(Vector2(198, 310), Vector2(146, 12), "Player")
	player_hp_label = UI.add_label(self, "", Vector2(198, 326), Vector2(146, 22), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER, "PlayerHpText")


func _add_message_box() -> void:
	var box := ColorRect.new()
	box.name = "MessageBox"
	box.position = Vector2(16, 404)
	box.size = Vector2(328, 92)
	box.color = Color(0.05, 0.11, 0.19, 0.88)
	add_child(box)

	message_label = UI.add_label(box, "", Vector2(16, 10), Vector2(296, 72), 15, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "BattleText")


func _add_action_buttons() -> void:
	action_panel = Control.new()
	action_panel.name = "ActionPanel"
	action_panel.position = Vector2.ZERO
	action_panel.size = UI.SCREEN_SIZE
	add_child(action_panel)

	UI.add_orange_button(action_panel, _text("attack"), Vector2(28, 512), Vector2(140, 44), Callable(self, "_show_attack_panel"), "Attack")
	UI.add_orange_button(action_panel, _text("bag"), Vector2(192, 512), Vector2(140, 44), Callable(self, "_show_bag"), "Bag")
	UI.add_orange_button(action_panel, _text("pokemon"), Vector2(28, 570), Vector2(140, 44), Callable(self, "_show_pokemon"), "Pokemon")
	UI.add_orange_button(action_panel, _text("run"), Vector2(192, 570), Vector2(140, 44), Callable(self, "_run"), "Run")


func _show_attack_panel() -> void:
	if battle_over:
		return
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

	var moves := PokemonHelpers.moves_for(str(player_pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	for i in range(moves.size()):
		var move: Dictionary = moves[i]
		var pos := Vector2(28.0 + float(i % 2) * 164.0, 516.0 + float(int(i / 2)) * 54.0)
		UI.add_orange_button(attack_panel, str(move.get("name", "Tackle")), pos, Vector2(140, 44), Callable(self, "_use_move").bind(move), str(move.get("name", "Move")).replace(" ", ""))


func _use_move(move: Dictionary) -> void:
	if battle_over:
		return
	_hide_attack_panel()

	var player_name := str(player_pokemon.get("name", "Pokemon"))
	var enemy_name := str(enemy_pokemon.get("name", "Enemy"))
	var damage := _calculate_damage(player_pokemon, enemy_pokemon, move)
	enemy_pokemon["hp"] = max(0, int(enemy_pokemon.get("hp", 0)) - damage)
	_update_status()

	var lines := [
		_text("used") % [player_name, str(move.get("name", "Move"))],
		_text("damage") % damage,
	]

	if int(enemy_pokemon.get("hp", 0)) <= 0:
		battle_over = true
		lines.append(_text("enemy_fainted"))
		lines.append(_grant_victory_xp())
		_persist_player_pokemon()
		message_label.text = _join_lines(lines)
		_add_return_button()
		return

	var enemy_move := {"name": "Tackle", "power": 35, "type": "Normal"}
	var enemy_damage := _calculate_damage(enemy_pokemon, player_pokemon, enemy_move)
	player_pokemon["hp"] = max(0, int(player_pokemon.get("hp", 0)) - enemy_damage)
	lines.append(_text("used") % [enemy_name, "Tackle"])
	lines.append(_text("damage") % enemy_damage)
	_update_status()
	_persist_player_pokemon()

	if int(player_pokemon.get("hp", 0)) <= 0:
		battle_over = true
		lines.append(_text("your_fainted"))
		message_label.text = _join_lines(lines)
		_add_return_button()
		return

	lines.append(_text("what_do") % player_name)
	message_label.text = _join_lines(lines)


func _calculate_damage(attacker: Dictionary, defender: Dictionary, move: Dictionary) -> int:
	var base_damage := int((int(attacker.get("attack", 8)) + int(move.get("power", 35))) / 4) - int(int(defender.get("defense", 5)) / 6)
	return max(1, base_damage + randi_range(-2, 2))


func _grant_victory_xp() -> String:
	var player_name := str(player_pokemon.get("name", "Pokemon"))
	player_pokemon["xp"] = int(player_pokemon.get("xp", 0)) + 25
	var message := _text("xp_gain") % player_name
	if int(player_pokemon.get("xp", 0)) >= 100:
		player_pokemon["xp"] = int(player_pokemon.get("xp", 0)) - 100
		player_pokemon["level"] = int(player_pokemon.get("level", 5)) + 1
		player_pokemon["max_hp"] = int(player_pokemon.get("max_hp", 39)) + 3
		player_pokemon["attack"] = int(player_pokemon.get("attack", 50)) + 1
		player_pokemon["defense"] = int(player_pokemon.get("defense", 45)) + 1
		player_pokemon["speed"] = int(player_pokemon.get("speed", 50)) + 1
		player_pokemon["hp"] = int(player_pokemon.get("max_hp", 39))
		message = "%s\n%s" % [message, _text("level_up") % [player_name, int(player_pokemon.get("level", 5))]]
	return message


func _persist_player_pokemon() -> void:
	if save_data.is_empty():
		return
	var team_value = save_data.get("team", [])
	if typeof(team_value) != TYPE_ARRAY or team_value.is_empty():
		return
	team_value[player_team_index] = player_pokemon
	SaveManager.update_current_save({"team": team_value})
	save_data = SaveManager.get_current_save()


func _update_status() -> void:
	enemy_name_label.text = "%s %s %d" % [str(enemy_pokemon.get("name", "Enemy")), _text("level"), int(enemy_pokemon.get("level", 3))]
	enemy_hp_label.text = "%s %d/%d" % [_text("hp"), int(enemy_pokemon.get("hp", 0)), int(enemy_pokemon.get("max_hp", 1))]
	player_name_label.text = "%s %s %d" % [str(player_pokemon.get("name", "Pokemon")), _text("level"), int(player_pokemon.get("level", 5))]
	player_hp_label.text = "%s %d/%d" % [_text("hp"), int(player_pokemon.get("hp", 0)), int(player_pokemon.get("max_hp", 1))]
	_resize_hp_fill(enemy_hp_fill, enemy_pokemon)
	_resize_hp_fill(player_hp_fill, player_pokemon)


func _resize_hp_fill(fill: ColorRect, pokemon: Dictionary) -> void:
	if fill == null:
		return
	var max_hp: int = max(1, int(pokemon.get("max_hp", 1)))
	var hp: int = clampi(int(pokemon.get("hp", max_hp)), 0, max_hp)
	var ratio: float = float(hp) / float(max_hp)
	fill.size = Vector2(142.0 * ratio, fill.size.y)
	fill.color = Color(0.24, 0.85, 0.24) if ratio > 0.5 else Color(0.95, 0.75, 0.18) if ratio > 0.2 else Color(0.88, 0.20, 0.16)


func _hide_attack_panel() -> void:
	if attack_panel != null and is_instance_valid(attack_panel):
		attack_panel.queue_free()


func _join_lines(lines: Array) -> String:
	var text_lines := []
	for line in lines:
		text_lines.append(str(line))
	return "\n".join(text_lines)


func _show_bag() -> void:
	UI.show_message_popup(self, _text("bag"), _text("battle_bag_soon"))


func _show_pokemon() -> void:
	UI.show_message_popup(self, _text("pokemon"), _text("switch_soon"))


func _run() -> void:
	get_tree().change_scene_to_file("res://scenes/ForestMap.tscn")


func _add_return_button() -> void:
	if action_panel != null and is_instance_valid(action_panel):
		action_panel.queue_free()
	_hide_attack_panel()
	UI.add_orange_button(self, _text("return_home"), Vector2(70, 540), Vector2(220, 48), Callable(self, "_return_home"), "ReturnHome")


func _return_home() -> void:
	get_tree().change_scene_to_file("res://scenes/HomeScreen.tscn")


func _add_hp_bar(pos: Vector2, node_size: Vector2, node_name: String) -> ColorRect:
	var bg := ColorRect.new()
	bg.name = "%sHpBack" % node_name
	bg.position = pos
	bg.size = node_size
	bg.color = Color(0.02, 0.02, 0.02, 0.95)
	add_child(bg)

	var fill := ColorRect.new()
	fill.name = "%sHpFill" % node_name
	fill.position = pos + Vector2(2, 2)
	fill.size = Vector2(node_size.x - 4.0, node_size.y - 4.0)
	fill.color = Color(0.24, 0.85, 0.24)
	add_child(fill)
	return fill


func _language() -> String:
	var language := str(settings.get("language", "en"))
	return language if TEXT.has(language) else "en"


func _text(key: String) -> String:
	var language_text: Dictionary = TEXT[_language()]
	var english_text: Dictionary = TEXT["en"]
	return str(language_text.get(key, english_text.get(key, key)))
