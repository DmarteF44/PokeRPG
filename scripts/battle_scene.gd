extends Control

const UI = preload("res://scripts/ui_factory.gd")
const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")
const GymData = preload("res://scripts/gym_data.gd")

const EFFECT_PATH_BY_TYPE = {
	"Bug": "res://assets/battle/effects/bug_slash.png",
	"Dragon": "res://assets/battle/effects/dragon_flare.png",
	"Electric": "res://assets/battle/effects/electric_spark.png",
	"Fire": "res://assets/battle/effects/fire_burst.png",
	"Flying": "res://assets/battle/effects/flying_gust.png",
	"Ghost": "res://assets/battle/effects/ghost_wisp.png",
	"Grass": "res://assets/battle/effects/grass_leaf.png",
	"Ground": "res://assets/battle/effects/ground_dust.png",
	"Ice": "res://assets/battle/effects/ice_shard.png",
	"Normal": "res://assets/battle/effects/normal_hit.png",
	"Poison": "res://assets/battle/effects/poison_bubble.png",
	"Rock": "res://assets/battle/effects/rock_impact.png",
	"Steel": "res://assets/battle/effects/steel_flash.png",
	"Water": "res://assets/battle/effects/water_splash.png",
}
const BATTLE_HEAL_ITEMS = {
	"potion": {"heal": 20, "revive": false},
	"super_potion": {"heal": 50, "revive": false},
	"hyper_potion": {"heal": 120, "revive": false},
	"max_potion": {"heal": -1, "revive": false},
	"revive": {"heal": 0.5, "revive": true},
	"max_revive": {"heal": 1.0, "revive": true},
}
const BATTLE_BALL_ITEMS = {
	"poke_ball": 1.0,
	"great_ball": 1.5,
	"ultra_ball": 2.0,
	"master_ball": -1.0,
}
const DEFAULT_WILD_CATCH_RATE = 190
const STATUS_CAPTURE_BONUS = {
	"sleep": 2.5,
	"asleep": 2.5,
	"freeze": 2.5,
	"frozen": 2.5,
	"paralysis": 1.5,
	"paralyzed": 1.5,
	"burn": 1.5,
	"burned": 1.5,
	"poison": 1.5,
	"poisoned": 1.5,
	"toxic": 1.5,
}
const BATTLE_STAGE_KEYS = ["attack", "defense", "sp_attack", "sp_defense", "speed", "accuracy", "evasion"]
const TYPE_CHART = {
	"Normal": {"Rock": 0.5, "Ghost": 0.0, "Steel": 0.5},
	"Fire": {"Fire": 0.5, "Water": 0.5, "Grass": 2.0, "Ice": 2.0, "Bug": 2.0, "Rock": 0.5, "Dragon": 0.5, "Steel": 2.0},
	"Water": {"Fire": 2.0, "Water": 0.5, "Grass": 0.5, "Ground": 2.0, "Rock": 2.0, "Dragon": 0.5},
	"Electric": {"Water": 2.0, "Electric": 0.5, "Grass": 0.5, "Ground": 0.0, "Flying": 2.0, "Dragon": 0.5},
	"Grass": {"Fire": 0.5, "Water": 2.0, "Grass": 0.5, "Poison": 0.5, "Ground": 2.0, "Flying": 0.5, "Bug": 0.5, "Rock": 2.0, "Dragon": 0.5, "Steel": 0.5},
	"Ice": {"Fire": 0.5, "Water": 0.5, "Grass": 2.0, "Ice": 0.5, "Ground": 2.0, "Flying": 2.0, "Dragon": 2.0, "Steel": 0.5},
	"Fighting": {"Normal": 2.0, "Ice": 2.0, "Poison": 0.5, "Flying": 0.5, "Psychic": 0.5, "Bug": 0.5, "Rock": 2.0, "Ghost": 0.0, "Dark": 2.0, "Steel": 2.0, "Fairy": 0.5},
	"Poison": {"Grass": 2.0, "Poison": 0.5, "Ground": 0.5, "Rock": 0.5, "Ghost": 0.5, "Steel": 0.0, "Fairy": 2.0},
	"Ground": {"Fire": 2.0, "Electric": 2.0, "Grass": 0.5, "Poison": 2.0, "Flying": 0.0, "Bug": 0.5, "Rock": 2.0, "Steel": 2.0},
	"Flying": {"Electric": 0.5, "Grass": 2.0, "Fighting": 2.0, "Bug": 2.0, "Rock": 0.5, "Steel": 0.5},
	"Psychic": {"Fighting": 2.0, "Poison": 2.0, "Psychic": 0.5, "Dark": 0.0, "Steel": 0.5},
	"Bug": {"Fire": 0.5, "Grass": 2.0, "Fighting": 0.5, "Poison": 0.5, "Flying": 0.5, "Psychic": 2.0, "Ghost": 0.5, "Dark": 2.0, "Steel": 0.5, "Fairy": 0.5},
	"Rock": {"Fire": 2.0, "Ice": 2.0, "Fighting": 0.5, "Ground": 0.5, "Flying": 2.0, "Bug": 2.0, "Steel": 0.5},
	"Ghost": {"Normal": 0.0, "Psychic": 2.0, "Ghost": 2.0, "Dark": 0.5},
	"Dragon": {"Dragon": 2.0, "Steel": 0.5, "Fairy": 0.0},
	"Dark": {"Fighting": 0.5, "Psychic": 2.0, "Ghost": 2.0, "Dark": 0.5, "Fairy": 0.5},
	"Steel": {"Fire": 0.5, "Water": 0.5, "Electric": 0.5, "Ice": 2.0, "Rock": 2.0, "Steel": 0.5, "Fairy": 2.0},
	"Fairy": {"Fire": 0.5, "Fighting": 2.0, "Poison": 0.5, "Dragon": 2.0, "Dark": 2.0, "Steel": 0.5},
}

const TEXT = {
	"en": {
		"battle": "Battle",
		"attack": "Attack",
		"fight": "Fight",
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
		"choose_next": "Choose another Pokemon.",
		"no_ready_pokemon": "No Pokemon is ready to battle.",
		"xp_gain": "%s gained 25 XP!",
		"level_up": "%s grew to level %d!",
		"evolution_start": "What? %s is evolving!",
		"evolution_done": "Congratulations! Your %s evolved into %s!",
		"no_pp": "No PP left.",
		"miss": "The attack missed!",
		"critical": "A critical hit!",
		"super_effective": "It's super effective!",
		"not_very_effective": "It's not very effective...",
		"no_effect": "It had no effect...",
		"item_used": "%s used %s!",
		"item_empty": "No item left.",
		"item_no_effect": "It had no effect.",
		"switched": "Go, %s!",
		"caught": "%s was caught!",
		"capture_failed": "Oh no! %s broke free!",
		"throw_ball": "You threw a %s!",
		"capture_shake_1": "The ball shook once...",
		"capture_shake_2": "The ball shook twice...",
		"capture_shake_3": "The ball shook three times...",
		"capture_click": "Click!",
		"sent_team": "%s joined your team.",
		"sent_storage": "The team is full. Pokemon sent to Storage.",
		"status_applied": "%s is now %s!",
		"stat_stage_changed": "%s's %s fell!",
		"seeded": "%s was seeded!",
		"drained": "%s had energy drained!",
		"cannot_switch": "Cannot switch to that Pokemon.",
		"run_success": "Got away safely!",
		"run_failed": "Could not escape!",
		"trainer_appeared": "%s sent out %s!",
		"cannot_capture_trainer": "You cannot capture a trainer's Pokemon.",
		"cannot_run_trainer": "You cannot run from a gym battle.",
		"gym_next": "Next gym battle: %s.",
		"gym_completed": "%s defeated! %s earned.",
		"gym_reward": "Reward: $%d",
		"next_battle": "Next Battle",
		"back": "Back",
		"return_home": "Return Home",
	},
	"pt": {
		"battle": "Batalha",
		"attack": "Atacar",
		"fight": "Fight",
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
		"choose_next": "Escolha outro Pokémon.",
		"no_ready_pokemon": "Nenhum Pokémon está pronto para batalhar.",
		"xp_gain": "%s ganhou 25 XP!",
		"level_up": "%s subiu para o nível %d!",
		"evolution_start": "O quê? %s está evoluindo!",
		"evolution_done": "Parabéns! Seu %s evoluiu para %s!",
		"no_pp": "Sem PP suficientes.",
		"miss": "O ataque errou!",
		"critical": "Acerto crítico!",
		"super_effective": "É super efetivo!",
		"not_very_effective": "Não foi muito efetivo...",
		"no_effect": "Não teve efeito...",
		"item_used": "%s usou %s!",
		"item_empty": "Item esgotado.",
		"item_no_effect": "Não teve efeito.",
		"switched": "Vá, %s!",
		"caught": "%s foi capturado!",
		"capture_failed": "Ah não! %s escapou!",
		"throw_ball": "Você lançou uma %s!",
		"capture_shake_1": "A bola balançou uma vez...",
		"capture_shake_2": "A bola balançou duas vezes...",
		"capture_shake_3": "A bola balançou três vezes...",
		"capture_click": "Click!",
		"sent_team": "%s entrou no seu time.",
		"sent_storage": "O time está cheio. Pokémon enviado ao Storage.",
		"status_applied": "%s agora está com %s!",
		"stat_stage_changed": "%s teve %s reduzido!",
		"seeded": "%s foi semeado!",
		"drained": "%s teve energia drenada!",
		"cannot_switch": "Não é possível trocar para esse Pokémon.",
		"run_success": "Fugiu com segurança!",
		"run_failed": "Não conseguiu fugir!",
		"trainer_appeared": "%s enviou %s!",
		"cannot_capture_trainer": "Você não pode capturar Pokémon de treinador.",
		"cannot_run_trainer": "Você não pode fugir de uma batalha de ginásio.",
		"gym_next": "Próxima batalha do ginásio: %s.",
		"gym_completed": "%s derrotado! %s recebida.",
		"gym_reward": "Recompensa: $%d",
		"next_battle": "Próxima batalha",
		"back": "Voltar",
		"return_home": "Voltar para Home",
	},
}

var settings: Dictionary = {}
var save_data: Dictionary = {}
var player_pokemon: Dictionary = {}
var enemy_pokemon: Dictionary = {}
var battle_team: Array = []
var player_team_index := 0
var battle_over := false
var pending_no_ready_message := false
var player_stat_stages: Dictionary = {}
var enemy_stat_stages: Dictionary = {}
var player_seeded := false
var enemy_seeded := false
var awaiting_forced_switch := false
var capture_in_progress := false

var message_label: Label
var action_panel: Control
var attack_panel: Control
var enemy_hp_fill: ColorRect
var enemy_hp_label: Label
var enemy_name_label: Label
var player_hp_fill: ColorRect
var player_hp_label: Label
var player_name_label: Label
var enemy_sprite: TextureRect
var player_sprite: TextureRect
var battle_effect_layer: Control


func _ready() -> void:
	randomize()
	player_stat_stages = _empty_stat_stages()
	enemy_stat_stages = _empty_stat_stages()
	settings = SaveManager.load_settings()
	_setup_battle_data()
	UI.setup_screen(self)
	UI.add_background(self)
	UI.add_topbar(self)
	UI.add_label(self, _text("battle"), Vector2(60, 6), Vector2(240, 32), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TopTitle")

	_add_enemy_area()
	_add_player_area()
	_add_battle_effect_layer()
	_add_message_box()
	_add_action_buttons()
	_update_status()
	if pending_no_ready_message:
		battle_over = true
		message_label.text = _text("no_ready_pokemon")
		_add_return_button()
		return
	var opening := _text("trainer_appeared") % [str(enemy_pokemon.get("trainer_name", "Trainer")), str(enemy_pokemon.get("name", "Pokemon"))] if _is_trainer_battle() else _text("wild_appeared") % str(enemy_pokemon.get("name", "Wild Dummy"))
	message_label.text = "%s\n%s\n%s" % [
		opening,
		_text("go") % str(player_pokemon.get("name", "Pokemon")),
		_text("what_do") % str(player_pokemon.get("name", "Pokemon")),
	]


func _setup_battle_data() -> void:
	save_data = SaveManager.get_current_save()
	if save_data.is_empty() and SaveManager.has_save(1):
		save_data = SaveManager.load_save(1)

	var team_value = save_data.get("team", []) if not save_data.is_empty() else []
	if typeof(team_value) == TYPE_ARRAY and not team_value.is_empty() and typeof(team_value[0]) == TYPE_DICTIONARY:
		battle_team = []
		for entry in team_value:
			if typeof(entry) == TYPE_DICTIONARY:
				battle_team.append(_battle_pokemon_copy(entry))
		player_team_index = _first_battle_ready_index(battle_team, clampi(int(save_data.get("active_pokemon_index", 0)), 0, battle_team.size() - 1))
		if player_team_index < 0:
			player_team_index = 0
			pending_no_ready_message = true
		player_pokemon = _battle_pokemon_copy(battle_team[player_team_index])
		battle_team[player_team_index] = _battle_pokemon_copy(player_pokemon)
	else:
		player_pokemon = _battle_pokemon_copy(PokemonHelpers.starter_save_data(PokemonHelpers.DEFAULT_STARTER_ID))
		battle_team = [_battle_pokemon_copy(player_pokemon)]
		pending_no_ready_message = int(player_pokemon.get("hp", 1)) <= 0 or PokemonHelpers.is_healing(player_pokemon)

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
		"species": str(value.get("species", value.get("name", "Pokemon"))),
		"nickname": str(value.get("nickname", "")),
		"name": str(value.get("name", "Pokemon")),
		"level": max(1, int(value.get("level", 3))),
		"hp": hp,
		"max_hp": max_hp,
		"attack": max(1, int(value.get("attack", 8))),
		"defense": max(1, int(value.get("defense", 5))),
		"sp_attack": max(1, int(value.get("sp_attack", value.get("attack", 8)))),
		"sp_defense": max(1, int(value.get("sp_defense", value.get("defense", 5)))),
		"speed": max(1, int(value.get("speed", 30))),
		"types": types,
		"status_condition": null if value.get("status_condition", null) == null else _normalized_status_key(value.get("status_condition", "")),
		"catch_rate": clampi(int(value.get("catch_rate", DEFAULT_WILD_CATCH_RATE)), 1, 255),
		"icon_path": str(value.get("icon_path", "res://assets/sprites/sprite_wurmple_96.png")),
		"moves": _normalized_enemy_moves(value.get("moves", [])),
		"pp_max": _normalized_enemy_pp_max(value.get("moves", []), value.get("pp_max", [])),
		"pp_current": _normalized_enemy_pp_current(value.get("moves", []), value.get("pp_max", []), value.get("pp_current", [])),
		"trainer_battle": bool(value.get("trainer_battle", false)),
		"trainer_name": str(value.get("trainer_name", "")),
		"trainer_role": str(value.get("trainer_role", "")),
		"gym_id": str(value.get("gym_id", "")),
		"gym_opponent_index": int(value.get("gym_opponent_index", 0)),
		"gym_badge": str(value.get("gym_badge", "")),
	}


func _is_trainer_battle() -> bool:
	return bool(enemy_pokemon.get("trainer_battle", false))


func _first_battle_ready_index(team_value: Array, preferred_index: int) -> int:
	if preferred_index >= 0 and preferred_index < team_value.size() and typeof(team_value[preferred_index]) == TYPE_DICTIONARY:
		var preferred := PokemonHelpers.normalize_pokemon(team_value[preferred_index])
		if int(preferred.get("hp", 0)) > 0 and not PokemonHelpers.is_healing(preferred):
			return preferred_index
	for i in range(team_value.size()):
		if typeof(team_value[i]) != TYPE_DICTIONARY:
			continue
		var pokemon := PokemonHelpers.normalize_pokemon(team_value[i])
		if int(pokemon.get("hp", 0)) > 0 and not PokemonHelpers.is_healing(pokemon):
			return i
	return -1


func _normalized_enemy_moves(moves_value) -> Array:
	var moves := []
	if typeof(moves_value) == TYPE_ARRAY:
		for entry in moves_value:
			if typeof(entry) == TYPE_DICTIONARY:
				moves.append(PokemonHelpers.move_by_name(str(entry.get("name", "Tackle"))))
			elif typeof(entry) == TYPE_STRING:
				moves.append(PokemonHelpers.move_by_name(str(entry)))
			if moves.size() >= PokemonHelpers.MAX_MOVE_SLOTS:
				break
	if moves.is_empty():
		moves.append(PokemonHelpers.move_by_name("Tackle"))
	return moves


func _normalized_enemy_pp_max(moves_value, pp_max_value) -> Array:
	var moves := _normalized_enemy_moves(moves_value)
	var pp_max := []
	if typeof(pp_max_value) == TYPE_ARRAY:
		for i in range(min(pp_max_value.size(), moves.size())):
			pp_max.append(maxi(1, int(pp_max_value[i])))
	for i in range(pp_max.size(), moves.size()):
		var move: Dictionary = moves[i]
		pp_max.append(maxi(1, int(move.get("pp", 35))))
	return pp_max


func _normalized_enemy_pp_current(moves_value, pp_max_value, pp_current_value) -> Array:
	var pp_max := _normalized_enemy_pp_max(moves_value, pp_max_value)
	var pp_current := []
	if typeof(pp_current_value) == TYPE_ARRAY:
		for i in range(min(pp_current_value.size(), pp_max.size())):
			pp_current.append(clampi(int(pp_current_value[i]), 0, int(pp_max[i])))
	for i in range(pp_current.size(), pp_max.size()):
		pp_current.append(int(pp_max[i]))
	return pp_current


func _add_enemy_area() -> void:
	enemy_name_label = UI.add_label(self, "", Vector2(18, 62), Vector2(180, 24), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "EnemyName")
	enemy_hp_fill = _add_hp_bar(Vector2(18, 92), Vector2(146, 12), "Enemy")
	enemy_hp_label = UI.add_label(self, "", Vector2(18, 108), Vector2(146, 22), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "EnemyHpText")
	enemy_sprite = PokemonHelpers.add_animated_sprite(self, enemy_pokemon, Vector2(226, 70), Vector2(96, 96), false, "EnemySprite")


func _add_player_area() -> void:
	player_sprite = PokemonHelpers.add_animated_sprite(self, player_pokemon, Vector2(36, 266), Vector2(112, 112), true, "PlayerSprite")
	player_name_label = UI.add_label(self, "", Vector2(166, 278), Vector2(178, 24), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER, "PlayerName")
	player_hp_fill = _add_hp_bar(Vector2(198, 310), Vector2(146, 12), "Player")
	player_hp_label = UI.add_label(self, "", Vector2(198, 326), Vector2(146, 22), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER, "PlayerHpText")


func _add_battle_effect_layer() -> void:
	battle_effect_layer = Control.new()
	battle_effect_layer.name = "BattleEffectLayer"
	battle_effect_layer.position = Vector2.ZERO
	battle_effect_layer.size = UI.SCREEN_SIZE
	battle_effect_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(battle_effect_layer)


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

	UI.add_orange_button(action_panel, _text("fight"), Vector2(28, 512), Vector2(140, 44), Callable(self, "_show_attack_panel"), "Fight")
	UI.add_orange_button(action_panel, _text("bag"), Vector2(192, 512), Vector2(140, 44), Callable(self, "_show_bag"), "Bag")
	UI.add_orange_button(action_panel, _text("pokemon"), Vector2(28, 570), Vector2(140, 44), Callable(self, "_show_pokemon"), "Pokemon")
	UI.add_orange_button(action_panel, _text("run"), Vector2(192, 570), Vector2(140, 44), Callable(self, "_run"), "Run")


func _show_attack_panel() -> void:
	if battle_over or capture_in_progress:
		return
	if _require_forced_switch():
		return
	_hide_attack_panel()

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

	var moves := _player_moves()
	var pp_current := _player_pp_current()
	var pp_max := _player_pp_max()
	for i in range(moves.size()):
		var move: Dictionary = moves[i]
		var pos := Vector2(28.0 + float(i % 2) * 164.0, 516.0 + float(int(i / 2)) * 54.0)
		var move_text := "%s\n%s PP %d/%d" % [
			str(move.get("name", "Tackle")),
			str(move.get("type", "Normal")),
			int(pp_current[i]) if i < pp_current.size() else 0,
			int(pp_max[i]) if i < pp_max.size() else 0,
		]
		var button := UI.add_orange_button(attack_panel, move_text, pos, Vector2(140, 44), Callable(self, "_use_move_index").bind(i), str(move.get("name", "Move")).replace(" ", ""))
		var label = button.get_node_or_null("Text")
		if label is Label:
			label.add_theme_font_size_override("font_size", 11)
			label.clip_text = true
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	UI.add_orange_button(attack_panel, _text("back"), Vector2(132, 474), Vector2(96, 26), Callable(self, "_hide_attack_panel"), "Back")


func _use_move_index(move_index: int) -> void:
	if battle_over or capture_in_progress:
		return
	if _require_forced_switch():
		return
	var moves := _player_moves()
	if move_index < 0 or move_index >= moves.size():
		return
	var pp_current := _player_pp_current()
	if move_index >= pp_current.size() or int(pp_current[move_index]) <= 0:
		message_label.text = _text("no_pp")
		return

	_hide_attack_panel()
	_consume_player_pp(move_index)
	var move: Dictionary = moves[move_index]
	var lines := []
	var player_first := _player_moves_first()

	if player_first:
		_execute_attack(true, move, lines)
		if _finish_battle_if_needed(lines):
			return
		_execute_enemy_turn(lines)
		if _finish_battle_if_needed(lines):
			return
	else:
		_execute_enemy_turn(lines)
		if _finish_battle_if_needed(lines):
			return
		_execute_attack(true, move, lines)
		if _finish_battle_if_needed(lines):
			return

	_finish_round(lines)


func _player_moves() -> Array:
	var moves_value = player_pokemon.get("moves", [])
	if typeof(moves_value) == TYPE_ARRAY and not moves_value.is_empty():
		return moves_value
	return PokemonHelpers.moves_for(str(player_pokemon.get("id", PokemonHelpers.DEFAULT_STARTER_ID)), int(player_pokemon.get("level", 5)))


func _player_pp_max() -> Array:
	var pp_max = player_pokemon.get("pp_max", [])
	if typeof(pp_max) != TYPE_ARRAY or pp_max.size() != _player_moves().size():
		pp_max = []
		for move in _player_moves():
			if typeof(move) == TYPE_DICTIONARY:
				pp_max.append(maxi(1, int(move.get("pp", 35))))
	player_pokemon["pp_max"] = pp_max
	return pp_max


func _player_pp_current() -> Array:
	var pp_max := _player_pp_max()
	var pp_current = player_pokemon.get("pp_current", [])
	if typeof(pp_current) != TYPE_ARRAY:
		pp_current = []
	var normalized := []
	for i in range(pp_max.size()):
		var current := int(pp_current[i]) if i < pp_current.size() else int(pp_max[i])
		normalized.append(clampi(current, 0, int(pp_max[i])))
	player_pokemon["pp_current"] = normalized
	return normalized


func _consume_player_pp(move_index: int) -> void:
	var pp_current := _player_pp_current()
	if move_index >= 0 and move_index < pp_current.size():
		pp_current[move_index] = maxi(0, int(pp_current[move_index]) - 1)
		player_pokemon["pp_current"] = pp_current


func _player_moves_first() -> bool:
	var player_speed := int(_modified_stat(player_pokemon, "speed", true))
	var enemy_speed := int(_modified_stat(enemy_pokemon, "speed", false))
	if player_speed == enemy_speed:
		return randf() < 0.5
	return player_speed > enemy_speed


func _execute_enemy_turn(lines: Array) -> void:
	if int(enemy_pokemon.get("hp", 0)) <= 0:
		return
	var enemy_move := _consume_enemy_move()
	_execute_attack(false, enemy_move, lines)


func _execute_attack(attacker_is_player: bool, move: Dictionary, lines: Array) -> void:
	var attacker := player_pokemon if attacker_is_player else enemy_pokemon
	var defender := enemy_pokemon if attacker_is_player else player_pokemon
	var target_sprite := enemy_sprite if attacker_is_player else player_sprite
	var attacker_name := str(attacker.get("name", "Pokemon"))
	var move_name := str(move.get("name", "Move"))
	lines.append(_text("used") % [attacker_name, move_name])

	var accuracy := clampi(int(move.get("accuracy", 100)), 0, 100)
	var effective_accuracy := float(accuracy) * _accuracy_stage_multiplier(attacker_is_player) / _evasion_stage_multiplier(not attacker_is_player)
	if randf() * 100.0 > effective_accuracy:
		lines.append(_text("miss"))
		return

	var damage_result := _calculate_damage_result(attacker, defender, move)
	var damage := int(damage_result.get("damage", 0))
	if int(move.get("power", 0)) > 0:
		defender["hp"] = maxi(0, int(defender.get("hp", 0)) - damage)
		if attacker_is_player:
			enemy_pokemon = defender
		else:
			player_pokemon = defender

		_play_move_feedback(move, target_sprite)
		_update_status()
		lines.append(_text("damage") % damage)
		if bool(damage_result.get("critical", false)):
			lines.append(_text("critical"))
		var effectiveness := float(damage_result.get("effectiveness", 1.0))
		var effect_line := _effectiveness_message(effectiveness)
		if effect_line != "":
			lines.append(effect_line)
	_apply_move_effects(attacker_is_player, move, lines)


func _calculate_damage_result(attacker: Dictionary, defender: Dictionary, move: Dictionary) -> Dictionary:
	var power := maxi(0, int(move.get("power", 40)))
	var effectiveness := _type_effectiveness(str(move.get("type", "Normal")), defender.get("types", []))
	var critical := randf() < 0.0625
	if power <= 0 or effectiveness <= 0.0:
		return {"damage": 0, "critical": critical and power > 0, "effectiveness": effectiveness}

	var level := maxi(1, int(attacker.get("level", 1)))
	var category := str(move.get("category", "Physical"))
	var attack_key := "sp_attack" if category == "Special" else "attack"
	var defense_key := "sp_defense" if category == "Special" else "defense"
	var attacker_is_player := attacker == player_pokemon
	var attack_stat := int(_modified_stat(attacker, attack_key, attacker_is_player))
	var defense_stat := int(_modified_stat(defender, defense_key, not attacker_is_player))
	var base := (((2.0 * float(level) / 5.0 + 2.0) * float(power) * float(maxi(1, attack_stat)) / float(maxi(1, defense_stat))) / 50.0) + 2.0
	var modifier := randf_range(0.85, 1.0) * _stab_multiplier(attacker, str(move.get("type", "Normal"))) * effectiveness
	if critical:
		modifier *= 1.5
	return {"damage": maxi(1, int(round(base * modifier))), "critical": critical, "effectiveness": effectiveness}


func _stab_multiplier(attacker: Dictionary, move_type: String) -> float:
	var types_value = attacker.get("types", [])
	if typeof(types_value) == TYPE_ARRAY:
		for type_name in types_value:
			if str(type_name).to_lower() == move_type.to_lower():
				return 1.5
	return 1.0


func _type_effectiveness(move_type: String, defender_types) -> float:
	var types: Array = []
	if typeof(defender_types) == TYPE_ARRAY:
		types = defender_types
	var effectiveness := 1.0
	var chart: Dictionary = TYPE_CHART.get(move_type, {})
	for defender_type in types:
		effectiveness *= float(chart.get(str(defender_type), 1.0))
	return effectiveness


func _effectiveness_message(effectiveness: float) -> String:
	if effectiveness <= 0.0:
		return _text("no_effect")
	if effectiveness > 1.0:
		return _text("super_effective")
	if effectiveness < 1.0:
		return _text("not_very_effective")
	return ""


func _apply_move_effects(attacker_is_player: bool, move: Dictionary, lines: Array) -> void:
	var effects = move.get("effects", [])
	if typeof(effects) != TYPE_ARRAY:
		return
	for effect in effects:
		if typeof(effect) != TYPE_DICTIONARY:
			continue
		var chance := clampf(float(effect.get("chance", 100.0)), 0.0, 100.0)
		if randf() * 100.0 > chance:
			continue
		var target_is_player := _effect_targets_player(attacker_is_player, str(effect.get("target", "enemy")))
		match str(effect.get("type", "")):
			"modify_stat":
				var stat_key := str(effect.get("stat", ""))
				var stages := int(effect.get("stages", 0))
				if stat_key != "" and stages != 0:
					_adjust_stat_stage(target_is_player, stat_key, stages)
					var target_name := str((player_pokemon if target_is_player else enemy_pokemon).get("name", "Pokemon"))
					lines.append(_text("stat_stage_changed") % [target_name, stat_key])
			"drain":
				if str(effect.get("timing", "")) == "end_turn":
					if target_is_player:
						player_seeded = true
						lines.append(_text("seeded") % str(player_pokemon.get("name", "Pokemon")))
					else:
						enemy_seeded = true
						lines.append(_text("seeded") % str(enemy_pokemon.get("name", "Pokemon")))
			"apply_status":
				var status_key := _normalized_status_key(effect.get("status", ""))
				if status_key != "":
					var target_pokemon := player_pokemon if target_is_player else enemy_pokemon
					var current_status = target_pokemon.get("status_condition", null)
					if current_status == null or str(current_status) == "":
						target_pokemon["status_condition"] = status_key
						if target_is_player:
							player_pokemon = target_pokemon
						else:
							enemy_pokemon = target_pokemon
						lines.append(_text("status_applied") % [str(target_pokemon.get("name", "Pokemon")), _status_display(status_key)])
						_update_status()


func _apply_end_turn_effects(lines: Array) -> void:
	if enemy_seeded and int(enemy_pokemon.get("hp", 0)) > 0 and int(player_pokemon.get("hp", 0)) > 0:
		var drain := maxi(1, int(ceil(float(enemy_pokemon.get("max_hp", 1)) * 0.125)))
		enemy_pokemon["hp"] = maxi(0, int(enemy_pokemon.get("hp", 0)) - drain)
		player_pokemon["hp"] = mini(int(player_pokemon.get("max_hp", 1)), int(player_pokemon.get("hp", 0)) + drain)
		lines.append(_text("drained") % str(enemy_pokemon.get("name", "Pokemon")))
	if player_seeded and int(player_pokemon.get("hp", 0)) > 0 and int(enemy_pokemon.get("hp", 0)) > 0:
		var drain := maxi(1, int(ceil(float(player_pokemon.get("max_hp", 1)) * 0.125)))
		player_pokemon["hp"] = maxi(0, int(player_pokemon.get("hp", 0)) - drain)
		enemy_pokemon["hp"] = mini(int(enemy_pokemon.get("max_hp", 1)), int(enemy_pokemon.get("hp", 0)) + drain)
		lines.append(_text("drained") % str(player_pokemon.get("name", "Pokemon")))
	_update_status()


func _effect_targets_player(attacker_is_player: bool, target: String) -> bool:
	match target:
		"self", "user":
			return attacker_is_player
		_:
			return not attacker_is_player


func _adjust_stat_stage(target_is_player: bool, stat_key: String, amount: int) -> void:
	var stages := player_stat_stages if target_is_player else enemy_stat_stages
	if not stages.has(stat_key):
		return
	stages[stat_key] = clampi(int(stages.get(stat_key, 0)) + amount, -6, 6)
	if target_is_player:
		player_stat_stages = stages
	else:
		enemy_stat_stages = stages


func _modified_stat(pokemon: Dictionary, stat_key: String, is_player: bool) -> float:
	var base := maxi(1, int(pokemon.get(stat_key, 1)))
	var stages := player_stat_stages if is_player else enemy_stat_stages
	return float(base) * _stage_multiplier(int(stages.get(stat_key, 0)))


func _accuracy_stage_multiplier(is_player: bool) -> float:
	var stages := player_stat_stages if is_player else enemy_stat_stages
	return _accuracy_multiplier(int(stages.get("accuracy", 0)))


func _evasion_stage_multiplier(is_player: bool) -> float:
	var stages := player_stat_stages if is_player else enemy_stat_stages
	return _accuracy_multiplier(int(stages.get("evasion", 0)))


func _stage_multiplier(stage: int) -> float:
	var safe_stage := clampi(stage, -6, 6)
	return (2.0 + float(safe_stage)) / 2.0 if safe_stage >= 0 else 2.0 / (2.0 - float(safe_stage))


func _accuracy_multiplier(stage: int) -> float:
	var safe_stage := clampi(stage, -6, 6)
	return (3.0 + float(safe_stage)) / 3.0 if safe_stage >= 0 else 3.0 / (3.0 - float(safe_stage))


func _normalized_status_key(status_value) -> String:
	var status := str(status_value).strip_edges().to_lower().replace("-", "_").replace(" ", "_")
	match status:
		"slp", "asleep":
			return "sleep"
		"frz", "frozen":
			return "freeze"
		"par", "paralyze", "paralyzed":
			return "paralysis"
		"brn", "burned":
			return "burn"
		"psn", "poisoned", "badly_poisoned":
			return "poison"
		_:
			return status


func _status_display(status_key: String) -> String:
	match _normalized_status_key(status_key):
		"sleep":
			return "sono" if _language() == "pt" else "sleep"
		"freeze":
			return "congelamento" if _language() == "pt" else "freeze"
		"paralysis":
			return "paralisia" if _language() == "pt" else "paralysis"
		"burn":
			return "queimadura" if _language() == "pt" else "burn"
		"poison":
			return "veneno" if _language() == "pt" else "poison"
		_:
			return status_key


func _empty_stat_stages() -> Dictionary:
	var stages := {}
	for stat_key in BATTLE_STAGE_KEYS:
		stages[str(stat_key)] = 0
	return stages


func _finish_round(lines: Array) -> void:
	_apply_end_turn_effects(lines)
	if _finish_battle_if_needed(lines):
		return
	_persist_player_pokemon()
	lines.append(_text("what_do") % str(player_pokemon.get("name", "Pokemon")))
	message_label.text = _join_lines(lines)


func _finish_battle_if_needed(lines: Array) -> bool:
	_persist_player_pokemon()
	if int(enemy_pokemon.get("hp", 0)) <= 0:
		battle_over = true
		lines.append(_text("enemy_fainted"))
		lines.append(_grant_victory_xp())
		var gym_result := _gym_victory_result()
		if gym_result.is_empty():
			_persist_player_pokemon({"pending_encounter": {}})
		else:
			for line in gym_result.get("lines", []):
				lines.append(str(line))
			_persist_player_pokemon(gym_result.get("changes", {}))
		message_label.text = _join_lines(lines)
		if bool(gym_result.get("continue", false)):
			_add_gym_next_button()
		else:
			_add_return_button()
		return true
	if int(player_pokemon.get("hp", 0)) <= 0:
		lines.append(_text("your_fainted"))
		if _has_ready_switch():
			awaiting_forced_switch = true
			lines.append(_text("choose_next"))
			message_label.text = _join_lines(lines)
			_show_pokemon()
			return true
		battle_over = true
		message_label.text = _join_lines(lines)
		_add_return_button()
		return true
	return false


func _gym_victory_result() -> Dictionary:
	var state := GymData.next_victory_state(SaveManager.get_current_save())
	if state.is_empty():
		return {}

	if bool(state.get("completed", false)):
		var gym: Dictionary = state.get("gym", {})
		var leader := str(gym.get("leader", "Leader"))
		var badge := str(gym.get("badge", "Badge"))
		var reward := int(gym.get("reward_money", 0))
		return {
			"continue": false,
			"changes": {
				"pending_encounter": {},
				"gym_challenge": {},
				"gyms_completed": state.get("gyms_completed", []),
				"gym_leaders_defeated": state.get("gym_leaders_defeated", []),
				"badges_obtained": state.get("badges_obtained", []),
				"badges": int(state.get("badges", 0)),
				"money": int(state.get("money", 3000)),
			},
			"lines": [
				_text("gym_completed") % [leader, badge],
				_text("gym_reward") % reward,
			],
		}

	var gym_id := str(enemy_pokemon.get("gym_id", ""))
	var next_index := int(state.get("next_index", 0))
	return {
		"continue": true,
		"changes": {
			"pending_encounter": state.get("next_encounter", {}),
			"gym_challenge": GymData.challenge_for(gym_id, next_index),
		},
		"lines": [_text("gym_next") % str(state.get("next_label", "Trainer"))],
	}


func _grant_victory_xp() -> String:
	var player_name := str(player_pokemon.get("name", "Pokemon"))
	var xp_result := PokemonHelpers.grant_xp(player_pokemon, 25)
	player_pokemon = xp_result.get("pokemon", player_pokemon)
	var lines := [_text("xp_gain") % player_name]
	var level_ups: Array = xp_result.get("level_ups", [])
	for level in level_ups:
		lines.append(_text("level_up") % [player_name, int(level)])

	var evolutions: Array = xp_result.get("evolutions", [])
	for evolution in evolutions:
		if typeof(evolution) != TYPE_DICTIONARY:
			continue
		var before: Dictionary = evolution.get("from", {})
		var after: Dictionary = evolution.get("to", {})
		var before_name := str(before.get("species", before.get("name", player_name)))
		var after_name := str(after.get("species", after.get("name", player_name)))
		lines.append(_text("evolution_start") % before_name)
		lines.append(_text("evolution_done") % [before_name, after_name])
		call_deferred("_show_evolution_popup", before, after)
	return _join_lines(lines)


func _enemy_moves() -> Array:
	var moves_value = enemy_pokemon.get("moves", [])
	return moves_value if typeof(moves_value) == TYPE_ARRAY and not moves_value.is_empty() else [PokemonHelpers.move_by_name("Tackle")]


func _consume_enemy_move() -> Dictionary:
	var moves := _enemy_moves()
	var pp_current = enemy_pokemon.get("pp_current", [])
	if typeof(pp_current) != TYPE_ARRAY:
		pp_current = []
	for i in range(moves.size()):
		var current := int(pp_current[i]) if i < pp_current.size() else 1
		if current > 0:
			while pp_current.size() <= i:
				pp_current.append(1)
			pp_current[i] = maxi(0, current - 1)
			enemy_pokemon["pp_current"] = pp_current
			return moves[i]
	return PokemonHelpers.move_by_name("Tackle")


func _persist_player_pokemon(extra_changes: Dictionary = {}) -> void:
	save_data = SaveManager.get_current_save()
	if save_data.is_empty():
		return
	if battle_team.is_empty() or player_team_index < 0 or player_team_index >= battle_team.size():
		return
	battle_team[player_team_index] = _battle_pokemon_copy(player_pokemon)
	var changes := {
		"team": _battle_team_snapshot(),
		"active_pokemon_index": player_team_index,
	}
	for key in extra_changes.keys():
		changes[key] = extra_changes[key]
	SaveManager.update_current_save(changes)


func _battle_pokemon_copy(pokemon: Dictionary) -> Dictionary:
	return PokemonHelpers.normalize_pokemon(pokemon).duplicate(true)


func _battle_team_snapshot() -> Array:
	var snapshot: Array = []
	for entry in battle_team:
		if typeof(entry) == TYPE_DICTIONARY:
			snapshot.append(_battle_pokemon_copy(entry))
	return snapshot
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


func _play_move_feedback(move: Dictionary, target_sprite: TextureRect) -> void:
	_play_attack_effect(move, target_sprite)
	_play_damage_flash(target_sprite)


func _play_attack_effect(move: Dictionary, target_sprite: TextureRect) -> void:
	if target_sprite == null or not is_instance_valid(target_sprite):
		return
	if battle_effect_layer == null or not is_instance_valid(battle_effect_layer):
		return

	var effect_path := _effect_path_for_move(move)
	if effect_path == "" or not FileAccess.file_exists(effect_path):
		return
	var texture = load(effect_path)
	if texture == null:
		return

	var effect := TextureRect.new()
	effect.name = "MoveEffect"
	effect.texture = texture
	effect.size = Vector2(96, 96)
	effect.position = target_sprite.position + target_sprite.size * 0.5 - effect.size * 0.5
	effect.pivot_offset = effect.size * 0.5
	effect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.modulate = Color(1, 1, 1, 0.95)
	effect.scale = Vector2(0.72, 0.72)
	battle_effect_layer.add_child(effect)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "scale", Vector2(1.26, 1.26), 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "rotation", randf_range(-0.18, 0.18), 0.24)
	tween.tween_property(effect, "modulate", Color(1, 1, 1, 0.0), 0.24).set_delay(0.10)
	tween.set_parallel(false)
	tween.tween_callback(effect.queue_free)


func _play_damage_flash(target_sprite: TextureRect) -> void:
	if target_sprite == null or not is_instance_valid(target_sprite):
		return
	var original_modulate := target_sprite.modulate
	var tween := create_tween()
	for i in range(3):
		tween.tween_property(target_sprite, "modulate", Color(1, 1, 1, 0.18), 0.055)
		tween.tween_property(target_sprite, "modulate", original_modulate, 0.055)


func _effect_path_for_move(move: Dictionary) -> String:
	var move_type := str(move.get("type", "Normal")).capitalize()
	return str(EFFECT_PATH_BY_TYPE.get(move_type, EFFECT_PATH_BY_TYPE["Normal"]))


func _hide_attack_panel() -> void:
	if attack_panel != null and is_instance_valid(attack_panel):
		attack_panel.queue_free()
	attack_panel = null


func _require_forced_switch() -> bool:
	if not awaiting_forced_switch:
		return false
	message_label.text = _text("choose_next")
	_show_pokemon()
	return true


func _has_ready_switch() -> bool:
	for i in range(battle_team.size()):
		if i == player_team_index or typeof(battle_team[i]) != TYPE_DICTIONARY:
			continue
		var pokemon := PokemonHelpers.normalize_pokemon(battle_team[i])
		if int(pokemon.get("hp", 0)) > 0 and not PokemonHelpers.is_healing(pokemon):
			return true
	return false


func _join_lines(lines: Array) -> String:
	var text_lines := []
	for line in lines:
		text_lines.append(str(line))
	return "\n".join(text_lines)


func _show_bag() -> void:
	if battle_over or capture_in_progress:
		return
	if _require_forced_switch():
		return
	_hide_attack_panel()
	attack_panel = _new_bottom_panel("BagPanel")
	var item_ids := ["potion", "super_potion", "hyper_potion", "max_potion", "revive", "max_revive", "poke_ball", "great_ball", "ultra_ball", "master_ball"]
	var scroll := ScrollContainer.new()
	scroll.name = "BattleBagScroll"
	scroll.position = Vector2(20, 508)
	scroll.size = Vector2(320, 86)
	attack_panel.add_child(scroll)
	var content := Control.new()
	content.name = "BattleBagItems"
	content.custom_minimum_size = Vector2(304, ceil(float(item_ids.size()) / 2.0) * 38.0)
	scroll.add_child(content)
	for i in range(item_ids.size()):
		var item_id := str(item_ids[i])
		var amount := InventoryManager.get_item_amount(item_id)
		var pos := Vector2(4.0 + float(i % 2) * 154.0, float(int(i / 2)) * 38.0)
		var button := UI.add_orange_button(content, "%s x%d" % [_item_name(item_id), amount], pos, Vector2(146, 32), Callable(self, "_use_bag_item").bind(item_id), "Item%s" % item_id)
		var label = button.get_node_or_null("Text")
		if label is Label:
			label.add_theme_font_size_override("font_size", 10)
		if amount <= 0:
			button.disabled = true
			button.modulate = Color(0.72, 0.72, 0.72, 0.9)
	UI.add_orange_button(attack_panel, _text("back"), Vector2(192, 596), Vector2(140, 24), Callable(self, "_hide_attack_panel"), "Back")


func _show_pokemon() -> void:
	if battle_over or capture_in_progress:
		return
	_hide_attack_panel()
	attack_panel = _new_bottom_panel("PokemonPanel")
	var team := _battle_team()
	for i in range(min(team.size(), SaveManager.MAX_TEAM_SIZE)):
		if typeof(team[i]) != TYPE_DICTIONARY:
			continue
		var pokemon: Dictionary = PokemonHelpers.normalize_pokemon(team[i])
		var pos := Vector2(28.0 + float(i % 2) * 164.0, 512.0 + float(int(i / 2)) * 36.0)
		var button_text := "%s %s%d\n%s %d/%d" % [
			str(pokemon.get("name", "Pokemon")),
			_text("level"),
			int(pokemon.get("level", 1)),
			_text("hp"),
			int(pokemon.get("hp", 0)),
			int(pokemon.get("max_hp", 1)),
		]
		var button := UI.add_orange_button(attack_panel, button_text, pos, Vector2(140, 32), Callable(self, "_switch_pokemon").bind(i), "Switch%d" % i)
		var label = button.get_node_or_null("Text")
		if label is Label:
			label.add_theme_font_size_override("font_size", 10)
		var disabled := i == player_team_index or int(pokemon.get("hp", 0)) <= 0 or PokemonHelpers.is_healing(pokemon)
		if disabled:
			button.disabled = true
			button.modulate = Color(0.62, 0.62, 0.62, 0.9)
	UI.add_orange_button(attack_panel, _text("back"), Vector2(192, 586), Vector2(140, 28), Callable(self, "_hide_attack_panel"), "Back")


func _run() -> void:
	if battle_over or capture_in_progress:
		return
	if _require_forced_switch():
		return
	if _is_trainer_battle():
		message_label.text = _text("cannot_run_trainer")
		return
	_hide_attack_panel()
	var player_speed := maxi(1, int(player_pokemon.get("speed", 1)))
	var enemy_speed := maxi(1, int(enemy_pokemon.get("speed", 1)))
	var chance := 1.0 if player_speed >= enemy_speed else clampf(0.25 + (float(player_speed) / float(enemy_speed)) * 0.5, 0.10, 0.85)
	if randf() <= chance:
		SaveManager.update_current_save({"pending_encounter": {}})
		get_tree().change_scene_to_file("res://scenes/ForestMap.tscn")
		return
	var lines := [_text("run_failed")]
	_execute_enemy_turn(lines)
	if _finish_battle_if_needed(lines):
		return
	_finish_round(lines)


func _new_bottom_panel(panel_name: String) -> Control:
	var panel := Control.new()
	panel.name = panel_name
	panel.position = Vector2.ZERO
	panel.size = UI.SCREEN_SIZE
	add_child(panel)
	var bg := ColorRect.new()
	bg.name = "%sBg" % panel_name
	bg.position = Vector2(16, 504)
	bg.size = Vector2(328, 116)
	bg.color = Color(0.03, 0.10, 0.17, 0.92)
	panel.add_child(bg)
	return panel


func _use_bag_item(item_id: String) -> void:
	if battle_over or capture_in_progress:
		return
	if _require_forced_switch():
		return
	if InventoryManager.get_item_amount(item_id) <= 0:
		message_label.text = _text("item_empty")
		return
	if BATTLE_BALL_ITEMS.has(item_id):
		_use_capture_item(item_id)
		return

	var used := false
	var target_index := player_team_index
	var target_pokemon := _battle_pokemon_copy(player_pokemon)
	var max_hp := maxi(1, int(player_pokemon.get("max_hp", 1)))
	var current_hp := clampi(int(player_pokemon.get("hp", max_hp)), 0, max_hp)
	var item_data: Dictionary = BATTLE_HEAL_ITEMS.get(item_id, {})
	if item_data.is_empty():
		message_label.text = _text("item_no_effect")
		return

	if bool(item_data.get("revive", false)):
		target_index = _first_fainted_team_index()
		if target_index >= 0:
			target_pokemon = PokemonHelpers.normalize_pokemon(battle_team[target_index])
			max_hp = maxi(1, int(target_pokemon.get("max_hp", 1)))
			var ratio := float(item_data.get("heal", 0.5))
			target_pokemon["hp"] = maxi(1, int(ceil(float(max_hp) * ratio)))
			used = true
	else:
		var heal_value = item_data.get("heal", 0)
		if current_hp > 0 and current_hp < max_hp:
			player_pokemon["hp"] = max_hp if int(heal_value) < 0 else mini(max_hp, current_hp + int(heal_value))
			target_pokemon = player_pokemon
			used = true

	if not used:
		message_label.text = _text("item_no_effect")
		return

	if target_index == player_team_index:
		player_pokemon = _battle_pokemon_copy(target_pokemon)
	battle_team[target_index] = _battle_pokemon_copy(target_pokemon)
	InventoryManager.remove_item(item_id, 1)
	_hide_attack_panel()
	_update_status()
	var lines := [_text("item_used") % [str(target_pokemon.get("name", "Pokemon")), _item_name(item_id)]]
	_execute_enemy_turn(lines)
	if _finish_battle_if_needed(lines):
		return
	_finish_round(lines)


func _use_capture_item(item_id: String) -> void:
	if _is_trainer_battle():
		message_label.text = _text("cannot_capture_trainer")
		return
	capture_in_progress = true
	if not InventoryManager.remove_item(item_id, 1):
		capture_in_progress = false
		message_label.text = _text("item_empty")
		return
	_hide_attack_panel()
	if action_panel != null and is_instance_valid(action_panel):
		action_panel.visible = false
	var enemy_name := str(enemy_pokemon.get("name", "Pokemon"))
	var capture_result := _roll_capture(item_id)
	var caught := bool(capture_result.get("caught", false))
	await _play_capture_feedback(item_id, int(capture_result.get("shakes", 0)), caught)
	if caught:
		var destination := str(_capture_enemy().get("destination", "team"))
		battle_over = true
		var lines := [_text("capture_click"), _text("caught") % enemy_name]
		if destination == "storage":
			lines.append(_text("sent_storage"))
		else:
			lines.append(_text("sent_team") % enemy_name)
		message_label.text = _join_lines(lines)
		capture_in_progress = false
		_add_return_button()
		return

	var lines := [_text("capture_failed") % enemy_name]
	if action_panel != null and is_instance_valid(action_panel):
		action_panel.visible = true
	capture_in_progress = false
	_execute_enemy_turn(lines)
	if _finish_battle_if_needed(lines):
		return
	_finish_round(lines)


func _roll_capture(item_id: String) -> Dictionary:
	if item_id == "master_ball":
		return {"caught": true, "shakes": 3, "chance": 1.0}

	var chance := _capture_chance(item_id)
	var caught := randf() <= chance
	if caught:
		return {"caught": true, "shakes": 3, "chance": chance}

	var shake_probability := clampf(pow(chance, 1.0 / 3.0), 0.05, 0.98)
	var shakes := 0
	for i in range(3):
		if randf() <= shake_probability:
			shakes += 1
		else:
			break
	return {"caught": false, "shakes": shakes, "chance": chance}


func _capture_chance(item_id: String) -> float:
	var multiplier := float(BATTLE_BALL_ITEMS.get(item_id, 1.0))
	if multiplier < 0.0:
		return 1.0
	var max_hp := maxi(1, int(enemy_pokemon.get("max_hp", 1)))
	var hp := clampi(int(enemy_pokemon.get("hp", max_hp)), 0, max_hp)
	var catch_rate := clampf(float(enemy_pokemon.get("catch_rate", DEFAULT_WILD_CATCH_RATE)), 1.0, 255.0)
	var status_bonus := float(STATUS_CAPTURE_BONUS.get(_normalized_status_key(enemy_pokemon.get("status_condition", "")), 1.0))
	var hp_factor := float(3 * max_hp - 2 * hp) / float(3 * max_hp)
	var capture_value := hp_factor * catch_rate * multiplier * status_bonus
	if capture_value >= 255.0:
		return 1.0
	return clampf(capture_value / 255.0, 0.01, 0.98)


func _capture_enemy() -> Dictionary:
	save_data = SaveManager.get_current_save()
	var captured := enemy_pokemon.duplicate(true)
	captured["capture_date"] = Time.get_datetime_string_from_system()
	captured["starter"] = false
	captured["healing"] = false
	captured["healing_finish_timestamp"] = 0
	captured = PokemonHelpers.normalize_pokemon(captured, str(captured.get("id", PokemonHelpers.DEFAULT_STARTER_ID)))
	var storage = save_data.get("storage", [])
	if typeof(storage) != TYPE_ARRAY:
		storage = []
	var destination := "team"
	if battle_team.size() < SaveManager.MAX_TEAM_SIZE:
		battle_team.append(_battle_pokemon_copy(captured))
	else:
		storage.append(_battle_pokemon_copy(captured))
		destination = "storage"
	var seen := _merged_pokemon_ids(save_data.get("seen_pokemon", []), str(captured.get("id", "")))
	var owned := _merged_pokemon_ids(save_data.get("owned_pokemon", []), str(captured.get("id", "")))
	SaveManager.update_current_save({
		"team": _battle_team_snapshot(),
		"storage": storage,
		"seen_pokemon": seen,
		"owned_pokemon": owned,
		"pending_encounter": {},
		"active_pokemon_index": player_team_index,
	})
	save_data = SaveManager.get_current_save()
	return {"pokemon": captured, "destination": destination}


func _merged_pokemon_ids(value, pokemon_id: String) -> Array:
	var ids := []
	if typeof(value) == TYPE_ARRAY:
		for entry in value:
			var safe_id := str(entry)
			if safe_id != "" and not ids.has(safe_id):
				ids.append(safe_id)
	if pokemon_id != "" and not ids.has(pokemon_id):
		ids.append(pokemon_id)
	return ids


func _first_fainted_team_index() -> int:
	for i in range(battle_team.size()):
		if typeof(battle_team[i]) == TYPE_DICTIONARY and int(battle_team[i].get("hp", 0)) <= 0:
			return i
	return -1


func _play_capture_feedback(item_id: String, shakes: int, caught: bool) -> void:
	message_label.text = _text("throw_ball") % _item_name(item_id)
	if battle_effect_layer == null or not is_instance_valid(battle_effect_layer):
		return
	var texture_path := "res://assets/items/pokeballs/%s.png" % item_id
	if not FileAccess.file_exists(texture_path):
		return
	var ball := TextureRect.new()
	ball.name = "CaptureBall"
	ball.texture = load(texture_path)
	ball.position = player_sprite.position + Vector2(44, 12)
	ball.size = Vector2(34, 34)
	ball.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ball.pivot_offset = ball.size * 0.5
	battle_effect_layer.add_child(ball)

	await get_tree().create_timer(0.18).timeout
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ball, "position", enemy_sprite.position + Vector2(30, 30), 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ball, "rotation", TAU * 1.15, 0.32)
	tween.set_parallel(false)
	await tween.finished

	if enemy_sprite != null and is_instance_valid(enemy_sprite):
		enemy_sprite.visible = false
	for i in range(clampi(shakes, 0, 3)):
		message_label.text = _text("capture_shake_%d" % [i + 1])
		var shake_tween := create_tween()
		shake_tween.tween_property(ball, "rotation", 0.34, 0.09)
		shake_tween.tween_property(ball, "rotation", -0.34, 0.09)
		shake_tween.tween_property(ball, "rotation", 0.0, 0.08)
		await shake_tween.finished
		await get_tree().create_timer(0.22).timeout

	if caught:
		message_label.text = _text("capture_click")
		var caught_tween := create_tween()
		caught_tween.tween_property(ball, "modulate", Color(1, 1, 1, 0.0), 0.22).set_delay(0.15)
		caught_tween.tween_callback(ball.queue_free)
		await caught_tween.finished
		return

	message_label.text = _text("capture_failed") % str(enemy_pokemon.get("name", "Pokemon"))
	var break_tween := create_tween()
	break_tween.set_parallel(true)
	break_tween.tween_property(ball, "scale", Vector2(1.45, 1.45), 0.18)
	break_tween.tween_property(ball, "modulate", Color(1, 1, 1, 0.0), 0.18)
	break_tween.set_parallel(false)
	break_tween.tween_callback(ball.queue_free)
	await break_tween.finished
	if enemy_sprite != null and is_instance_valid(enemy_sprite):
		enemy_sprite.visible = true
		_play_damage_flash(enemy_sprite)


func _switch_pokemon(index: int) -> void:
	if battle_over:
		return
	var team := _battle_team()
	if index < 0 or index >= team.size() or index == player_team_index or typeof(team[index]) != TYPE_DICTIONARY:
		message_label.text = _text("cannot_switch")
		return
	var next_pokemon := _battle_pokemon_copy(team[index])
	if int(next_pokemon.get("hp", 0)) <= 0 or PokemonHelpers.is_healing(next_pokemon):
		message_label.text = _text("cannot_switch")
		return

	var was_forced_switch := awaiting_forced_switch
	battle_team[player_team_index] = _battle_pokemon_copy(player_pokemon)
	player_team_index = index
	player_pokemon = _battle_pokemon_copy(next_pokemon)
	player_stat_stages = _empty_stat_stages()
	player_seeded = false
	awaiting_forced_switch = false
	battle_team[player_team_index] = _battle_pokemon_copy(player_pokemon)
	SaveManager.update_current_save({"team": _battle_team_snapshot(), "active_pokemon_index": player_team_index})
	save_data = SaveManager.get_current_save()
	_refresh_player_sprite()
	_update_status()
	_hide_attack_panel()

	var lines := [_text("switched") % str(player_pokemon.get("name", "Pokemon"))]
	if was_forced_switch:
		lines.append(_text("what_do") % str(player_pokemon.get("name", "Pokemon")))
		message_label.text = _join_lines(lines)
		return
	_execute_enemy_turn(lines)
	if _finish_battle_if_needed(lines):
		return
	_finish_round(lines)


func _battle_team() -> Array:
	return battle_team


func _refresh_player_sprite() -> void:
	if player_sprite != null and is_instance_valid(player_sprite):
		player_sprite.queue_free()
	player_sprite = PokemonHelpers.add_animated_sprite(self, player_pokemon, Vector2(36, 266), Vector2(112, 112), true, "PlayerSprite")


func _item_name(item_id: String) -> String:
	match item_id:
		"poke_ball":
			return "Pokébola" if _language() == "pt" else "Poke Ball"
		"great_ball":
			return "Great Ball"
		"ultra_ball":
			return "Ultra Ball"
		"master_ball":
			return "Master Ball"
		"potion":
			return "Poção" if _language() == "pt" else "Potion"
		"super_potion":
			return "Super Poção" if _language() == "pt" else "Super Potion"
		"hyper_potion":
			return "Hiper Poção" if _language() == "pt" else "Hyper Potion"
		"max_potion":
			return "Poção Máxima" if _language() == "pt" else "Max Potion"
		"revive":
			return "Reviver" if _language() == "pt" else "Revive"
		"max_revive":
			return "Reviver Máximo" if _language() == "pt" else "Max Revive"
		_:
			return item_id.replace("_", " ").capitalize()


func _add_return_button() -> void:
	if action_panel != null and is_instance_valid(action_panel):
		action_panel.queue_free()
	_hide_attack_panel()
	UI.add_orange_button(self, _text("return_home"), Vector2(70, 540), Vector2(220, 48), Callable(self, "_return_home"), "ReturnHome")


func _add_gym_next_button() -> void:
	if action_panel != null and is_instance_valid(action_panel):
		action_panel.queue_free()
	_hide_attack_panel()
	UI.add_orange_button(self, _text("next_battle"), Vector2(70, 540), Vector2(220, 48), Callable(self, "_continue_gym_battle"), "NextGymBattle")


func _continue_gym_battle() -> void:
	get_tree().change_scene_to_file("res://scenes/BattleScene.tscn")


func _return_home() -> void:
	SaveManager.update_current_save({"pending_encounter": {}, "gym_challenge": {}})
	get_tree().change_scene_to_file("res://scenes/HomeScreen.tscn")


func _show_evolution_popup(before: Dictionary, after: Dictionary) -> void:
	var before_name := str(before.get("species", before.get("name", "Pokemon")))
	var after_name := str(after.get("species", after.get("name", "Pokemon")))
	var overlay := Control.new()
	overlay.name = "EvolutionPopup"
	overlay.position = Vector2.ZERO
	overlay.size = UI.SCREEN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = UI.SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.48)
	overlay.add_child(shade)

	UI.add_texture(overlay, UI.POPUP_PANEL, Vector2(15, 120), Vector2(330, 360), "Panel", TextureRect.STRETCH_SCALE)
	UI.add_panel_label(overlay, _text("evolution_start") % before_name, Vector2(38, 150), Vector2(284, 42), 16, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "StartText")
	PokemonHelpers.add_animated_sprite(overlay, before, Vector2(66, 222), Vector2(78, 78), false, "BeforeSprite")
	UI.add_panel_label(overlay, "↓", Vector2(160, 234), Vector2(40, 44), 30, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Arrow")
	PokemonHelpers.add_animated_sprite(overlay, after, Vector2(216, 222), Vector2(78, 78), false, "AfterSprite")
	UI.add_panel_label(overlay, _text("evolution_done") % [before_name, after_name], Vector2(38, 318), Vector2(284, 58), 15, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "DoneText")
	var close_callback = func():
		overlay.queue_free()
	UI.add_orange_button(overlay, "OK", Vector2(70, 396), Vector2(220, 48), close_callback, "CloseEvolution")


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
