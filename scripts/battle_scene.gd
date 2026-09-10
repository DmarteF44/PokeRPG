extends Control

const UI = preload("res://scripts/ui_factory.gd")
const PokemonHelpers = preload("res://scripts/pokemon_helpers.gd")
const GymData = preload("res://scripts/gym_data.gd")
const CupManager = preload("res://scripts/cup_manager.gd")

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
	"Fighting": "res://assets/battle/effects/fighting_impact.png",
	"Psychic": "res://assets/battle/effects/psychic_swirl.png",
	"Fairy": "res://assets/battle/effects/fairy_sparkle.png",
	"Dark": "res://assets/battle/effects/dark_shadow.png",
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
		"mega_evolve": "Mega Evolve",
		"mega_evolved_message": "%s Mega Evolved into %s!",
		"primal_revert": "Primal Revert",
		"primal_reverted_message": "Reverted to its Primal form: %s!",
		"dynamax": "Dynamax",
		"dynamaxed_message": "%s Dynamaxed!",
		"dynamax_wore_off": "%s's Dynamax wore off!",
		"z_move_name": "Z-%s",
		"terastallize": "Terastallize",
		"terastallized_message": "%s Terastallized into the %s type!",
		"battle_bond_message": "%s's Battle Bond awakened! It transformed into Ash-Greninja!",
		"hp": "HP",
		"level": "Lv.",
		"wild_appeared": "Wild %s appeared!",
		"go": "Go! %s!",
		"what_do": "What will %s do?",
		"used": "%s used %s!",
		"damage": "Damage: %d",
		"enemy_fainted": "Enemy fainted!",
		"your_fainted": "Your Pokemon fainted!",
		"switch_fainted_tag": "Fainted",
		"switch_active_tag": "In battle",
		"choose_next": "Choose another Pokemon.",
		"no_ready_pokemon": "No Pokemon is ready to battle.",
		"xp_gain": "%s gained 25 XP!",
		"level_up": "%s grew to level %d!",
		"trainer_level_up": "You reached trainer level %d!",
		"evolution_start": "What? %s is evolving!",
		"evolution_done": "Congratulations! Your %s evolved into %s!",
		"move_learn_wants": "%s wants to learn %s!",
		"move_learn_full": "But %s already knows 4 moves. Choose a move to forget, or give up learning %s.",
		"move_learn_replaced": "%s forgot %s and learned %s!",
		"move_learn_already_known": "%s already knows %s!",
		"move_learn_cancelled": "%s did not learn %s.",
		"give_up_learning": "Give Up",
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
		"stat_stage_boosted": "%s's %s rose!",
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
		"cup_next_pokemon": "%s sends out its next Pokemon!",
		"cup_round_won": "Round won! +$%d, +%d XP.",
		"cup_champion": "You are the champion of the %s!",
		"cup_badge_earned": "%s earned!",
		"cup_rewards": "Rewards: +$%d, +%d XP.",
		"cup_eliminated": "Eliminated from the tournament. You can try again.",
		"tutorial_battle_step_fight": "These are your moves. Tap FIGHT to pick an attack.",
		"tutorial_battle_step_bag": "This is your Bag. Use Potions to heal your Pokemon, or a Poke Ball to try to catch the wild one.",
		"tutorial_battle_step_pokemon": "Here you can switch your active Pokemon for another one on your team.",
		"tutorial_battle_step_run": "Here you can run from the battle (not available against trainers).",
		"tutorial_battle_step_catch": "This wild Pokemon is already low on HP! The lower its HP, the better your catch chance - open the Bag and throw a Poke Ball now, or keep attacking to win instead.",
		"tutorial_next": "Next",
		"tutorial_got_it": "Got it!",
		"tutorial_reward_intro": "Tutorial complete! Thanks for learning the ropes.",
		"tutorial_reward_mew": "You received a Mew!",
		"tutorial_reward_extras": "+$%d, 5 Poke Balls, 5 Potions, and a Tutorial Badge!",
		"next_battle": "Next Battle",
		"back": "Back",
		"return_home": "Return Home",
		"already_status": "%s is already %s!",
		"fully_paralyzed": "%s is paralyzed! It can't move!",
		"fast_asleep": "%s is fast asleep.",
		"woke_up": "%s woke up!",
		"frozen_solid": "%s is frozen solid!",
		"thawed_out": "%s thawed out!",
		"hurt_by_poison": "%s is hurt by poison!",
		"hurt_by_burn": "%s is hurt by its burn!",
	},
	"pt": {
		"battle": "Batalha",
		"attack": "Atacar",
		"fight": "Lutar",
		"bag": "Mochila",
		"pokemon": "Pokemon",
		"run": "Fugir",
		"mega_evolve": "Mega Evoluir",
		"mega_evolved_message": "%s Mega Evoluiu para %s!",
		"primal_revert": "Regressão Primitiva",
		"primal_reverted_message": "Regrediu para sua forma Primitiva: %s!",
		"dynamax": "Dynamax",
		"dynamaxed_message": "%s usou Dynamax!",
		"dynamax_wore_off": "O Dynamax de %s acabou!",
		"z_move_name": "Z-%s",
		"terastallize": "Teracristalizar",
		"terastallized_message": "%s Teracristalizou para o tipo %s!",
		"battle_bond_message": "O Vínculo de Batalha de %s despertou! Transformou-se em Greninja de Ash!",
		"hp": "HP",
		"level": "Nv.",
		"wild_appeared": "%s selvagem apareceu!",
		"go": "Vai! %s!",
		"what_do": "O que %s vai fazer?",
		"used": "%s usou %s!",
		"damage": "Dano: %d",
		"enemy_fainted": "O inimigo desmaiou!",
		"your_fainted": "Seu Pokémon desmaiou!",
		"switch_fainted_tag": "Desmaiado",
		"switch_active_tag": "Em batalha",
		"choose_next": "Escolha outro Pokémon.",
		"no_ready_pokemon": "Nenhum Pokémon está pronto para batalhar.",
		"xp_gain": "%s ganhou 25 XP!",
		"level_up": "%s subiu para o nível %d!",
		"trainer_level_up": "Você alcançou o nível de treinador %d!",
		"evolution_start": "O quê? %s está evoluindo!",
		"evolution_done": "Parabéns! Seu %s evoluiu para %s!",
		"move_learn_wants": "%s quer aprender %s!",
		"move_learn_full": "Mas %s já conhece 4 golpes. Escolha um golpe para esquecer, ou desista de aprender %s.",
		"move_learn_replaced": "%s esqueceu %s e aprendeu %s!",
		"move_learn_already_known": "%s já conhece %s!",
		"move_learn_cancelled": "%s não aprendeu %s.",
		"give_up_learning": "Desistir",
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
		"stat_stage_boosted": "%s teve %s aumentado!",
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
		"cup_next_pokemon": "%s enviou seu próximo Pokémon!",
		"cup_round_won": "Rodada vencida! +$%d, +%d XP.",
		"cup_champion": "Você é o campeão da %s!",
		"cup_badge_earned": "%s recebida!",
		"cup_rewards": "Recompensas: +$%d, +%d XP.",
		"cup_eliminated": "Eliminado do torneio. Você pode tentar de novo.",
		"tutorial_battle_step_fight": "Estes são seus golpes. Toque em LUTAR para escolher um ataque.",
		"tutorial_battle_step_bag": "Aqui fica sua Mochila. Use Poções pra curar seu Pokémon, ou uma Poké Bola pra tentar capturar o selvagem.",
		"tutorial_battle_step_pokemon": "Aqui você troca seu Pokémon ativo por outro do seu time.",
		"tutorial_battle_step_run": "Aqui você foge da batalha (não disponível contra treinadores).",
		"tutorial_battle_step_catch": "Esse Pokémon selvagem já está com pouca vida! Quanto mais baixo o HP, maior a chance de captura - abra a Mochila e jogue uma Poké Bola agora, ou continue atacando pra vencer.",
		"tutorial_next": "Próximo",
		"tutorial_got_it": "Entendi!",
		"tutorial_reward_intro": "Tutorial concluído! Obrigado por aprender o básico.",
		"tutorial_reward_mew": "Você recebeu um Mew!",
		"tutorial_reward_extras": "+$%d, 5 Poké Bolas, 5 Poções, e a Insígnia do Tutorial!",
		"next_battle": "Próxima batalha",
		"back": "Voltar",
		"return_home": "Voltar para Home",
		"already_status": "%s já está com %s!",
		"fully_paralyzed": "%s está paralisado e não conseguiu se mover!",
		"fast_asleep": "%s está dormindo.",
		"woke_up": "%s acordou!",
		"frozen_solid": "%s está completamente congelado!",
		"thawed_out": "%s descongelou!",
		"hurt_by_poison": "%s sofreu dano do veneno!",
		"hurt_by_burn": "%s sofreu dano da queimadura!",
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
var mega_button: TextureButton
var dynamax_button: TextureButton
var tera_button: TextureButton


func _ready() -> void:
	randomize()
	player_stat_stages = _empty_stat_stages()
	enemy_stat_stages = _empty_stat_stages()
	settings = SaveManager.load_settings()
	_setup_battle_data()
	UI.setup_screen(self)
	_add_battle_background()
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
	var variant_tag := PokemonHelpers.variant_tag(enemy_pokemon)
	var opening := _text("trainer_appeared") % [str(enemy_pokemon.get("trainer_name", "Trainer")), str(enemy_pokemon.get("name", "Pokemon")) + variant_tag] if _is_trainer_battle() else _text("wild_appeared") % (str(enemy_pokemon.get("name", "Wild Dummy")) + variant_tag)
	message_label.text = "%s\n%s\n%s" % [
		opening,
		_text("go") % str(player_pokemon.get("name", "Pokemon")),
		_text("what_do") % str(player_pokemon.get("name", "Pokemon")),
	]
	if _is_tutorial_battle():
		_start_tutorial_walkthrough()


# A battle over a generic gray background looked the same no matter where in
# the world it happened - use the current map's own battle backdrop when one
# exists (falling back to the default background otherwise) so a forest
# encounter actually looks like a forest.
func _add_battle_background() -> void:
	var map_key := str(save_data.get("current_map", "forest"))
	var path := "res://assets/backgrounds/battle/bg_battle_%s_360x640.png" % map_key
	if UI.resource_exists(path):
		var background := UI.add_texture(self, path, Vector2.ZERO, UI.SCREEN_SIZE, "BattleBackground", TextureRect.STRETCH_SCALE)
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		UI.add_background(self)


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
		"shiny": bool(value.get("shiny", false)),
		"black": bool(value.get("black", false)),
		"alpha": bool(value.get("alpha", false)),
		"form": str(value.get("form", "")),
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
		"cup_battle": bool(value.get("cup_battle", false)),
		"cup_id": str(value.get("cup_id", "")),
		"cup_round_index": int(value.get("cup_round_index", 0)),
		"cup_team_index": int(value.get("cup_team_index", 0)),
		"cup_trainer_id": str(value.get("cup_trainer_id", "")),
		"tutorial_battle": bool(value.get("tutorial_battle", false)),
	}


func _is_trainer_battle() -> bool:
	return bool(enemy_pokemon.get("trainer_battle", false))


func _is_cup_battle() -> bool:
	return bool(enemy_pokemon.get("cup_battle", false))


func _is_tutorial_battle() -> bool:
	return bool(enemy_pokemon.get("tutorial_battle", false))


var _tutorial_step_index := 0


# Purely narrational, not a forced/blocking flow: each callout just points at
# a real UI element already on screen (nothing is disabled or hidden while
# it's up) and advances on tap, so the player can also just play normally at
# any point - the last step doesn't gate anything, it just explains that a
# low-HP wild Pokemon is easier to catch and lets them try it for real.
func _tutorial_steps() -> Array:
	return [
		{"text": _text("tutorial_battle_step_fight"), "rect": Rect2(28, 512, 140, 44)},
		{"text": _text("tutorial_battle_step_bag"), "rect": Rect2(192, 512, 140, 44)},
		{"text": _text("tutorial_battle_step_pokemon"), "rect": Rect2(28, 570, 140, 44)},
		{"text": _text("tutorial_battle_step_run"), "rect": Rect2(192, 570, 140, 44)},
		{"text": _text("tutorial_battle_step_catch"), "rect": Rect2(14, 58, 316, 68)},
	]


func _start_tutorial_walkthrough() -> void:
	_tutorial_step_index = 0
	_show_tutorial_step()


func _show_tutorial_step() -> void:
	var existing := get_node_or_null("TutorialStepOverlay")
	if existing != null:
		remove_child(existing)
		existing.queue_free()

	var steps := _tutorial_steps()
	if _tutorial_step_index >= steps.size():
		return

	var step: Dictionary = steps[_tutorial_step_index]
	var target: Rect2 = step.get("rect", Rect2())

	var overlay := Control.new()
	overlay.name = "TutorialStepOverlay"
	overlay.position = Vector2.ZERO
	overlay.size = UI.SCREEN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var highlight := Panel.new()
	highlight.name = "Highlight"
	highlight.position = target.position - Vector2(4, 4)
	highlight.size = target.size + Vector2(8, 8)
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(highlight)
	var highlight_style := StyleBoxFlat.new()
	highlight_style.bg_color = Color(0, 0, 0, 0)
	highlight_style.border_color = Color(1.0, 0.82, 0.2, 1.0)
	highlight_style.set_border_width_all(3)
	highlight_style.set_corner_radius_all(8)
	highlight.add_theme_stylebox_override("panel", highlight_style)

	# Callout box sits above the target unless that would run it off the top
	# of the screen, in which case it goes below instead.
	var callout_height := 108.0
	var callout_y := target.position.y - callout_height - 12.0
	if callout_y < 46.0:
		callout_y = target.position.y + target.size.y + 12.0
	var callout := Panel.new()
	callout.name = "Callout"
	callout.position = Vector2(20, callout_y)
	callout.size = Vector2(320, callout_height)
	callout.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(callout)
	UI.style_panel_button(callout, Color(0.98, 0.95, 0.85), Color(0.55, 0.42, 0.10), 2)
	var text_label := UI.add_panel_label(callout, str(step.get("text", "")), Vector2(12, 8), Vector2(296, 62), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_TOP, "StepText")
	_fit_label_if_available(text_label)
	var is_last := _tutorial_step_index >= steps.size() - 1
	var next_label := _text("tutorial_got_it") if is_last else _text("tutorial_next")
	UI.add_orange_button(callout, next_label, Vector2(184, 74), Vector2(124, 28), Callable(self, "_advance_tutorial_step"), "NextStep")


func _fit_label_if_available(label: Label) -> void:
	if label == null:
		return
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true


func _advance_tutorial_step() -> void:
	_tutorial_step_index += 1
	_show_tutorial_step()


const TUTORIAL_REWARD_MONEY = 1000


# One-time reward (first completion only, tracked by tutorial_battle_completed)
# for finishing the guided tutorial battle, win or catch - either outcome
# means the player made it through the walkthrough. Returns message lines to
# append to the battle-end text; empty if already granted before.
func _grant_tutorial_reward() -> Array:
	var current_save := SaveManager.get_current_save()
	if bool(current_save.get("tutorial_battle_completed", false)):
		return []

	InventoryManager.add_item("poke_ball", 5)
	InventoryManager.add_item("potion", 5)

	var mew := PokemonHelpers.starter_save_data("mew")
	var mew_level := 10
	var mew_stats := PokemonHelpers.stats_for_level("mew", mew_level)
	mew["level"] = mew_level
	mew["xp"] = 0
	mew["xp_to_next_level"] = PokemonHelpers.xp_to_next_level_for(mew_level)
	mew["max_hp"] = int(mew_stats.get("max_hp", mew.get("max_hp", 1)))
	mew["hp"] = int(mew["max_hp"])
	mew["attack"] = int(mew_stats.get("attack", mew.get("attack", 1)))
	mew["defense"] = int(mew_stats.get("defense", mew.get("defense", 1)))
	mew["sp_attack"] = int(mew_stats.get("sp_attack", mew.get("sp_attack", 1)))
	mew["sp_defense"] = int(mew_stats.get("sp_defense", mew.get("sp_defense", 1)))
	mew["speed"] = int(mew_stats.get("speed", mew.get("speed", 1)))
	mew["moves"] = PokemonHelpers.moves_for("mew", mew_level)
	mew = PokemonHelpers.normalize_pokemon(mew, "mew")

	var latest_save := SaveManager.get_current_save()
	var team_value = latest_save.get("team", [])
	var team: Array = team_value if typeof(team_value) == TYPE_ARRAY else []
	var storage_value = latest_save.get("storage", [])
	var storage: Array = storage_value if typeof(storage_value) == TYPE_ARRAY else []
	var team_capacity := SaveManager.team_capacity_for_level(int(latest_save.get("level", 1)))
	var went_to_team := team.size() < team_capacity
	if went_to_team:
		team.append(mew)
	else:
		storage.append(mew)

	var pokedex_updates := PokemonHelpers.pokedex_seen_updates(mew, latest_save)
	var owned_updates := PokemonHelpers.pokedex_owned_updates(mew, latest_save)
	for key in owned_updates:
		pokedex_updates[key] = owned_updates[key]
	pokedex_updates["team"] = team
	pokedex_updates["storage"] = storage
	pokedex_updates["money"] = int(latest_save.get("money", 0)) + TUTORIAL_REWARD_MONEY
	pokedex_updates["tutorial_battle_completed"] = true
	SaveManager.update_current_save(pokedex_updates)

	return [
		_text("tutorial_reward_intro"),
		_text("tutorial_reward_mew"),
		_text("tutorial_reward_extras") % [TUTORIAL_REWARD_MONEY],
	]


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
	enemy_sprite = PokemonHelpers.add_animated_sprite(self, enemy_pokemon, Vector2(220, 64), Vector2(108, 108), false, "EnemySprite")


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
	var held_z_type := _held_z_move_type()
	for i in range(moves.size()):
		var move: Dictionary = moves[i]
		var pos := Vector2(28.0 + float(i % 2) * 164.0, 516.0 + float(int(i / 2)) * 54.0)
		# A move can unleash its Z-Move variant only while holding the
		# matching Z-Crystal, only for a damaging move (see _use_move_index's
		# "nao criar dados ficticios" note on status Z-effects), and only
		# once per battle - see z_move_used, cleared the same battle-only
		# way as Mega/Dynamax.
		var is_z_eligible := held_z_type != "" and str(move.get("type", "")) == held_z_type and int(move.get("power", 0)) > 0 and not bool(player_pokemon.get("z_move_used", false))
		var move_text := "%s%s\n%s PP %d/%d" % [
			"⚡Z " if is_z_eligible else "",
			str(move.get("name", "Tackle")),
			str(move.get("type", "Normal")),
			int(pp_current[i]) if i < pp_current.size() else 0,
			int(pp_max[i]) if i < pp_max.size() else 0,
		]
		var button := UI.add_orange_button(attack_panel, move_text, pos, Vector2(140, 44), Callable(self, "_use_move_index").bind(i, is_z_eligible), str(move.get("name", "Move")).replace(" ", ""))
		var label = button.get_node_or_null("Text")
		if label is Label:
			# Re-asserting size after these overrides works around the same
			# Label-inflates-on-property-change quirk UI.add_label already
			# corrects for once, right after it's created (see that function).
			var target_size: Vector2 = label.size
			label.add_theme_font_size_override("font_size", 11)
			label.clip_text = true
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.size = target_size

	UI.add_orange_button(attack_panel, _text("back"), Vector2(132, 474), Vector2(96, 26), Callable(self, "_hide_attack_panel"), "Back")


func _use_move_index(move_index: int, use_z: bool = false) -> void:
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
	# ADAPTACAO DO POKERPG: real Z-Moves have a per-move power table and
	# move-specific status effects (Z-Swords Dance, Z-Recover, ...) - this
	# project uses one flat power multiplier on damaging moves only, a
	# simplification in the same spirit as Dynamax's Max Move power bump,
	# rather than risk inventing 700+ moves' worth of exact table entries.
	if use_z and int(move.get("power", 0)) > 0 and not bool(player_pokemon.get("z_move_used", false)):
		move = move.duplicate(true)
		move["power"] = int(round(float(move.get("power", 0)) * Z_MOVE_POWER_MULTIPLIER))
		move["accuracy"] = 100
		move["name"] = _text("z_move_name") % str(move.get("name", "Move"))
		player_pokemon["z_move_used"] = true
	var lines := []
	var player_first := _player_moves_first()

	if player_first:
		_execute_attack(true, move, lines)
		_check_battle_bond_trigger(lines)
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
		_check_battle_bond_trigger(lines)
		if _finish_battle_if_needed(lines):
			return

	_finish_round(lines)


# Battle Bond is the one real Pokemon mechanic with no held item or player
# button - Greninja transforms into Ash-Greninja automatically the instant
# it KOs an opposing Pokemon, once per battle (a Greninja that's already
# bonded, or one that never learned Battle Bond at all per
# PokemonHelpers.battle_bond_ids_for_species, is a no-op here).
func _check_battle_bond_trigger(lines: Array) -> void:
	if str(player_pokemon.get("battle_bond_id", "")) != "":
		return
	if int(enemy_pokemon.get("hp", 0)) > 0:
		return
	var bond_ids := PokemonHelpers.battle_bond_ids_for_species(str(player_pokemon.get("id", "")))
	if bond_ids.is_empty():
		return
	var before_name := str(player_pokemon.get("name", player_pokemon.get("species", "Pokemon")))
	player_pokemon["battle_bond_id"] = str(bond_ids[0])
	var stats := PokemonHelpers.stats_for_level(str(player_pokemon.get("id", "")), int(player_pokemon.get("level", 1)), bool(player_pokemon.get("black", false)), bool(player_pokemon.get("alpha", false)), bool(player_pokemon.get("purified", false)), str(player_pokemon.get("mega", "")) != "", true)
	for stat_key in ["max_hp", "attack", "defense", "sp_attack", "sp_defense", "speed"]:
		player_pokemon[stat_key] = int(stats.get(stat_key, player_pokemon.get(stat_key, 1)))
	player_pokemon = PokemonHelpers.normalize_pokemon(player_pokemon)
	battle_team[player_team_index] = _battle_pokemon_copy(player_pokemon)
	_refresh_player_sprite()
	lines.append(_text("battle_bond_message") % before_name)


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
	var attacker_sprite := player_sprite if attacker_is_player else enemy_sprite
	var target_sprite := enemy_sprite if attacker_is_player else player_sprite
	var attacker_name := str(attacker.get("name", "Pokemon"))
	var move_name := str(move.get("name", "Move"))

	if _resolve_pre_move_status(attacker_is_player, lines):
		return

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

		_play_move_feedback(move, attacker_sprite, target_sprite)
		_update_status()
		lines.append(_text("damage") % damage)
		if bool(damage_result.get("critical", false)):
			lines.append(_text("critical"))
		var effectiveness := float(damage_result.get("effectiveness", 1.0))
		var effect_line := _effectiveness_message(effectiveness)
		if effect_line != "":
			lines.append(effect_line)
	elif str(move.get("category", "Physical")) == "Status":
		# Zero-power status moves (Growl, ...) never called _play_move_feedback
		# above, so without this they had no animation at all - a soft cast
		# wave on the user, shared by every status move regardless of type.
		MoveAnimation.play_status_wave(attacker_sprite, battle_effect_layer)
	_apply_move_effects(attacker_is_player, move, lines)


# Returns true when the attacker's status prevents it from acting this turn
# (sleep, freeze, full paralysis), appending the relevant message. Mirrors
# real Pokemon status mechanics: paralysis has a 25% chance to fully stop a
# move, sleep counts down a random number of turns before waking, and freeze
# has a flat chance to thaw each turn it would otherwise act.
func _resolve_pre_move_status(attacker_is_player: bool, lines: Array) -> bool:
	var attacker := player_pokemon if attacker_is_player else enemy_pokemon
	var attacker_name := str(attacker.get("name", "Pokemon"))
	match _normalized_status_key(attacker.get("status_condition", "")):
		"sleep":
			var remaining := int(attacker.get("sleep_turns_remaining", 0))
			if remaining <= 0:
				attacker["status_condition"] = null
				attacker.erase("sleep_turns_remaining")
				_write_back_pokemon(attacker_is_player, attacker)
				lines.append(_text("woke_up") % attacker_name)
				return false
			attacker["sleep_turns_remaining"] = remaining - 1
			_write_back_pokemon(attacker_is_player, attacker)
			lines.append(_text("fast_asleep") % attacker_name)
			return true
		"freeze":
			if randf() < 0.20:
				attacker["status_condition"] = null
				_write_back_pokemon(attacker_is_player, attacker)
				lines.append(_text("thawed_out") % attacker_name)
				return false
			lines.append(_text("frozen_solid") % attacker_name)
			return true
		"paralysis":
			if randf() < 0.25:
				lines.append(_text("fully_paralyzed") % attacker_name)
				return true
			return false
		_:
			return false


func _write_back_pokemon(is_player: bool, pokemon: Dictionary) -> void:
	if is_player:
		player_pokemon = pokemon
	else:
		enemy_pokemon = pokemon


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
	if category != "Special" and _normalized_status_key(attacker.get("status_condition", "")) == "burn":
		attack_stat = maxi(1, int(attack_stat / 2))
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
					MoveAnimation.play_stat_aura(player_sprite if target_is_player else enemy_sprite, battle_effect_layer, stages > 0)
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
					var target_name := str(target_pokemon.get("name", "Pokemon"))
					var current_status = target_pokemon.get("status_condition", null)
					if current_status == null or str(current_status) == "":
						target_pokemon["status_condition"] = status_key
						if status_key == "sleep":
							target_pokemon["sleep_turns_remaining"] = randi_range(1, 3)
						if target_is_player:
							player_pokemon = target_pokemon
						else:
							enemy_pokemon = target_pokemon
						lines.append(_text("status_applied") % [target_name, _status_display(status_key)])
						MoveAnimation.play_status_condition(player_sprite if target_is_player else enemy_sprite, battle_effect_layer, status_key)
						_update_status()
					else:
						lines.append(_text("already_status") % [target_name, _status_display(_normalized_status_key(current_status))])


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
	_apply_status_damage(true, lines)
	_apply_status_damage(false, lines)
	_apply_dynamax_countdown(lines)
	_update_status()


# Dynamax lasts 3 of the player's rounds, same as the real games - ticked
# down here (once per finished round, alongside status damage) rather than
# per raw player action, so item use/switch attempts that bail out early
# never burn a "turn" of Dynamax that wasn't actually spent.
func _apply_dynamax_countdown(lines: Array) -> void:
	if not bool(player_pokemon.get("dynamax", false)):
		return
	var remaining := int(player_pokemon.get("dynamax_turns_remaining", 0)) - 1
	if remaining > 0:
		player_pokemon["dynamax_turns_remaining"] = remaining
		return
	var pokemon_name := str(player_pokemon.get("name", player_pokemon.get("species", "Pokemon")))
	_revert_dynamax(player_pokemon)
	lines.append(_text("dynamax_wore_off") % pokemon_name)
	if int(player_pokemon.get("hp", 0)) > 0:
		_refresh_player_sprite()


# Poison and burn both chip 1/16 max HP at the end of the round, same
# fraction real Pokemon games use outside of badly-poisoned Toxic stacking.
func _apply_status_damage(is_player: bool, lines: Array) -> void:
	var pokemon := player_pokemon if is_player else enemy_pokemon
	if int(pokemon.get("hp", 0)) <= 0:
		return
	var status := _normalized_status_key(pokemon.get("status_condition", ""))
	if status != "poison" and status != "burn":
		return
	var chip := maxi(1, int(floor(float(pokemon.get("max_hp", 1)) / 16.0)))
	pokemon["hp"] = maxi(0, int(pokemon.get("hp", 0)) - chip)
	_write_back_pokemon(is_player, pokemon)
	lines.append((_text("hurt_by_poison") if status == "poison" else _text("hurt_by_burn")) % str(pokemon.get("name", "Pokemon")))


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
	var value := float(base) * _stage_multiplier(int(stages.get(stat_key, 0)))
	if stat_key == "speed" and _normalized_status_key(pokemon.get("status_condition", "")) == "paralysis":
		value *= 0.25
	return value


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
		_refresh_mega_button()
		_refresh_dynamax_button()
		_refresh_tera_button()
		lines.append(_text("enemy_fainted"))
		lines.append(_grant_victory_xp())
		if _is_tutorial_battle():
			lines.append_array(_grant_tutorial_reward())
			_persist_player_pokemon({"pending_encounter": {}})
			message_label.text = _join_lines(lines)
			_add_return_button()
			return true
		if _is_cup_battle():
			var cup_result := _cup_victory_result()
			if cup_result.is_empty():
				_persist_player_pokemon({"pending_encounter": {}})
			else:
				for line in cup_result.get("lines", []):
					lines.append(str(line))
				_persist_player_pokemon(cup_result.get("changes", {}))
			message_label.text = _join_lines(lines)
			if bool(cup_result.get("continue", false)):
				_add_cup_next_button()
			else:
				_add_return_button()
			return true
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
		_refresh_mega_button()
		_refresh_dynamax_button()
		_refresh_tera_button()
		if _is_cup_battle():
			lines.append(_text("cup_eliminated"))
			var defeat_result := CupManager.defeat_state(SaveManager.get_current_save())
			_persist_player_pokemon(defeat_result.get("changes", {}))
		message_label.text = _join_lines(lines)
		_add_return_button()
		return true
	return false


func _cup_victory_result() -> Dictionary:
	var state := CupManager.next_victory_state(SaveManager.get_current_save())
	if state.is_empty():
		return {}

	var changes: Dictionary = state.get("changes", {}).duplicate(true)
	var result := str(state.get("result", ""))

	if result == "next_team_member" or result == "next_round":
		# CupManager only hands back the new cup_challenge pointer (round/team
		# position), not a built Pokemon encounter - build it the same way
		# _setup_battle_data() will read it back, against a save_data snapshot
		# with these changes already merged in, so it matches exactly.
		var preview_save := SaveManager.get_current_save().duplicate(true)
		for key in changes.keys():
			preview_save[key] = changes[key]
		changes["pending_encounter"] = CupManager.current_encounter(preview_save)

		var lines := []
		if result == "next_team_member":
			var trainer_name := str(enemy_pokemon.get("trainer_name", "Trainer"))
			lines.append(_text("cup_next_pokemon") % trainer_name)
		else:
			lines.append(_text("cup_round_won") % [int(state.get("money_gain", 0)), int(state.get("xp_gain", 0))])
		return {"continue": true, "changes": changes, "lines": lines}

	# result == "cup_completed"
	changes["pending_encounter"] = {}
	var already_completed := bool(state.get("already_completed", false))
	var badge_name := str(state.get("badge_name", ""))
	var cup := CupManager.cup_for_id(str(enemy_pokemon.get("cup_id", "")))
	var cup_name := str(cup.get("name_pt", cup.get("name_en", "Cup"))) if _language() == "pt" else str(cup.get("name_en", "Cup"))
	var lines := [_text("cup_champion") % cup_name]
	if not already_completed:
		lines.append(_text("cup_badge_earned") % badge_name)
	lines.append(_text("cup_rewards") % [int(state.get("money_gain", 0)), int(state.get("xp_gain", 0))])
	return {"continue": false, "changes": changes, "lines": lines}


func _add_cup_next_button() -> void:
	if action_panel != null and is_instance_valid(action_panel):
		action_panel.queue_free()
	_hide_attack_panel()
	UI.add_orange_button(self, _text("next_battle"), Vector2(70, 540), Vector2(220, 48), Callable(self, "_continue_cup_battle"), "NextCupBattle")


func _continue_cup_battle() -> void:
	get_tree().change_scene_to_file("res://scenes/BattleScene.tscn")


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


# Trainer XP earned for winning a battle (independent of whether the enemy is
# captured afterward - previously only captures granted trainer XP, so a
# player who battled without catching never leveled up or earned
# specialization points). Scales with the enemy's level; trainer/gym
# opponents are harder to reach and pay out more.
func _victory_trainer_xp() -> int:
	var level := maxi(1, int(enemy_pokemon.get("level", 1)))
	var amount := maxi(2, int(level / 2) + 1)
	if _is_trainer_battle():
		amount = int(round(amount * 1.5))
	return int(round(amount * PokemonHelpers.variant_reward_multiplier(enemy_pokemon)))


# Player-progress facts a PokeRPG-adapted evolution condition (badge count,
# etc.) might need - see PokemonHelpers.PLAYER_PROGRESS_METHODS. Threaded
# into grant_xp() so evolution checks can see them without PokemonHelpers
# itself depending on SaveManager.
func _evolution_context() -> Dictionary:
	var cups_progress = save_data.get("cups", {})
	var participated_cup_ids := []
	var won_cup_ids := []
	if typeof(cups_progress) == TYPE_DICTIONARY:
		for cup_id in cups_progress.keys():
			var entry = cups_progress[cup_id]
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			if bool(entry.get("participated", false)):
				participated_cup_ids.append(str(cup_id))
			if bool(entry.get("won", false)):
				won_cup_ids.append(str(cup_id))
	return {
		"badges": int(save_data.get("badges", 0)),
		"participated_tournament_ids": participated_cup_ids,
		"won_tournament_ids": won_cup_ids,
	}


func _grant_victory_xp() -> String:
	var player_name := str(player_pokemon.get("name", "Pokemon"))
	var training_bonus := 1.0 + float(SaveManager.specialization_points("treinamento")) * 0.02
	var xp_result := PokemonHelpers.grant_xp(player_pokemon, int(round(25 * training_bonus)), _evolution_context())
	player_pokemon = xp_result.get("pokemon", player_pokemon)
	var lines := [_text("xp_gain") % player_name]
	var level_ups: Array = xp_result.get("level_ups", [])
	for level in level_ups:
		lines.append(_text("level_up") % [player_name, int(level)])
	if not level_ups.is_empty():
		AudioManager.play_sfx("level_up")

	var trainer_xp_result := SaveManager.grant_trainer_xp(_victory_trainer_xp())
	var trainer_level_ups: Array = trainer_xp_result.get("level_ups", [])
	for trainer_level in trainer_level_ups:
		lines.append(_text("trainer_level_up") % int(trainer_level))
	if not trainer_level_ups.is_empty():
		AudioManager.play_sfx("level_up")

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

	var pending_move_learns: Array = xp_result.get("pending_move_learns", [])
	for pending in pending_move_learns:
		if typeof(pending) != TYPE_DICTIONARY:
			continue
		call_deferred("_show_move_learn_popup", str(pending.get("move_name", "")))
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


func _battle_pokemon_copy(pokemon: Dictionary, strip_battle_only: bool = false) -> Dictionary:
	var source := pokemon
	# Mega Evolution, Dynamax, Terastalization and a used Z-Move charge must
	# never survive into a persisted save (see PokemonHelpers.mega_definition
	# / _dynamax / _terastallize / _use_move_index) - reverting them
	# together here, at the one point (_battle_team_snapshot) whose output
	# ever reaches SaveManager, is what makes it safe to let them live
	# freely on the in-memory player_pokemon/battle_team for the rest of
	# the actual battle.
	if strip_battle_only and typeof(pokemon) == TYPE_DICTIONARY and (str(pokemon.get("mega", "")) != "" or bool(pokemon.get("dynamax", false)) or bool(pokemon.get("terastallized", false)) or bool(pokemon.get("z_move_used", false)) or str(pokemon.get("battle_bond_id", "")) != ""):
		source = pokemon.duplicate(true)
		if str(source.get("mega", "")) != "":
			var stats := PokemonHelpers.stats_for_level(str(source.get("id", "")), int(source.get("level", 1)), bool(source.get("black", false)), bool(source.get("alpha", false)), bool(source.get("purified", false)), false)
			for stat_key in ["max_hp", "attack", "defense", "sp_attack", "sp_defense", "speed"]:
				source[stat_key] = int(stats.get(stat_key, source.get(stat_key, 1)))
			source["hp"] = mini(int(source.get("hp", 1)), int(source["max_hp"]))
			source["mega"] = ""
		if bool(source.get("dynamax", false)):
			_revert_dynamax(source)
		if str(source.get("battle_bond_id", "")) != "":
			var bond_stats := PokemonHelpers.stats_for_level(str(source.get("id", "")), int(source.get("level", 1)), bool(source.get("black", false)), bool(source.get("alpha", false)), bool(source.get("purified", false)), str(source.get("mega", "")) != "", false)
			for stat_key in ["max_hp", "attack", "defense", "sp_attack", "sp_defense", "speed"]:
				source[stat_key] = int(bond_stats.get(stat_key, source.get(stat_key, 1)))
			source["hp"] = mini(int(source.get("hp", 1)), int(source["max_hp"]))
			source["battle_bond_id"] = ""
		source["terastallized"] = false
		source["z_move_used"] = false
	return PokemonHelpers.normalize_pokemon(source).duplicate(true)


func _revert_dynamax(pokemon: Dictionary) -> void:
	var bonus := int(pokemon.get("dynamax_bonus_hp", 0))
	pokemon["max_hp"] = maxi(1, int(pokemon.get("max_hp", 1)) - bonus)
	pokemon["hp"] = clampi(int(pokemon.get("hp", 1)) - bonus, 0, int(pokemon["max_hp"]))
	pokemon["dynamax"] = false
	pokemon["dynamax_gmax_id"] = ""
	pokemon["dynamax_turns_remaining"] = 0
	pokemon["dynamax_bonus_hp"] = 0


func _battle_team_snapshot() -> Array:
	var snapshot: Array = []
	for entry in battle_team:
		if typeof(entry) == TYPE_DICTIONARY:
			snapshot.append(_battle_pokemon_copy(entry, true))
	return snapshot


func _update_status() -> void:
	enemy_name_label.text = "%s %s %d" % [str(enemy_pokemon.get("name", "Enemy")), _text("level"), int(enemy_pokemon.get("level", 3))]
	enemy_hp_label.text = "%s %d/%d" % [_text("hp"), int(enemy_pokemon.get("hp", 0)), int(enemy_pokemon.get("max_hp", 1))]
	player_name_label.text = "%s %s %d" % [str(player_pokemon.get("name", "Pokemon")), _text("level"), int(player_pokemon.get("level", 5))]
	player_hp_label.text = "%s %d/%d" % [_text("hp"), int(player_pokemon.get("hp", 0)), int(player_pokemon.get("max_hp", 1))]
	_resize_hp_fill(enemy_hp_fill, enemy_pokemon)
	_resize_hp_fill(player_hp_fill, player_pokemon)
	_refresh_mega_button()
	_refresh_dynamax_button()
	_refresh_tera_button()


func _resize_hp_fill(fill: ColorRect, pokemon: Dictionary) -> void:
	if fill == null:
		return
	var max_hp: int = max(1, int(pokemon.get("max_hp", 1)))
	var hp: int = clampi(int(pokemon.get("hp", max_hp)), 0, max_hp)
	var ratio: float = float(hp) / float(max_hp)
	fill.color = Color(0.24, 0.85, 0.24) if ratio > 0.5 else Color(0.95, 0.75, 0.18) if ratio > 0.2 else Color(0.88, 0.20, 0.16)
	var target_width := 142.0 * ratio
	if is_equal_approx(fill.size.x, target_width):
		return
	var tween := create_tween()
	tween.tween_property(fill, "size:x", target_width, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


# Physical moves (Tackle, Scratch, Quick Attack, ...) land instantly, so the
# impact and the damage flash play together. Special moves (Ember, Water
# Gun, Ice Beam, Thunderbolt, Vine Whip, Gust, ...) travel from the attacker
# to the target first - the damage flash is deferred to the moment the
# projectile actually lands, via MoveAnimation.play_projectile's on_impact
# callback, instead of flashing before the "attack" visibly arrives.
func _play_move_feedback(move: Dictionary, attacker_sprite: TextureRect, target_sprite: TextureRect) -> void:
	var texture := _effect_texture_for_move(move)
	if texture == null or battle_effect_layer == null or not is_instance_valid(battle_effect_layer):
		_play_damage_flash(target_sprite)
		return
	if str(move.get("category", "Physical")) == "Special":
		MoveAnimation.play_projectile(attacker_sprite, target_sprite, battle_effect_layer, texture, Callable(self, "_play_damage_flash").bind(target_sprite))
	else:
		MoveAnimation.play_impact(target_sprite, battle_effect_layer, texture)
		_play_damage_flash(target_sprite)


func _effect_texture_for_move(move: Dictionary) -> Texture2D:
	var effect_path := _effect_path_for_move(move)
	if not UI.resource_exists(effect_path):
		return null
	return load(effect_path)


func _play_damage_flash(target_sprite: TextureRect) -> void:
	if target_sprite == null or not is_instance_valid(target_sprite):
		return
	AudioManager.play_sfx("hit")
	# Always restores to fully opaque, never to "whatever modulate happened
	# to be" - a sprite can be mid-fade-in from a just-completed switch when
	# its very first turn's damage flash fires (both tweens touch modulate
	# on the same node), and capturing that transient low-alpha value here
	# would permanently strand the sprite at partial opacity once this
	# flash's own tween finishes.
	var tween := create_tween()
	for i in range(3):
		tween.tween_property(target_sprite, "modulate", Color(1, 1, 1, 0.18), 0.055)
		tween.tween_property(target_sprite, "modulate", Color(1, 1, 1, 1), 0.055)


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


const ITEMS_PATH = "res://data/items.json"


# Data-driven: any item.json entry whose use_contexts includes "battle" shows
# up here automatically, so a future item (a status cure, an XP item usable
# mid-battle, etc.) doesn't also need this list hand-updated to appear.
func _battle_item_ids() -> Array:
	var file := FileAccess.open(ITEMS_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		return []
	var ids := []
	for item in parsed:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var contexts_value = item.get("use_contexts", [])
		if typeof(contexts_value) == TYPE_ARRAY and contexts_value.has("battle"):
			ids.append(str(item.get("id", "")))
	return ids


# Real Z-Moves scale power per a fixed table keyed by the base move's own
# power tier (60->100, 75->120, 100->160, ...) - this project uses one flat
# multiplier instead (see _use_move_index's "ADAPTACAO" note).
const Z_MOVE_POWER_MULTIPLIER := 1.8


func _held_z_move_type() -> String:
	var held_item := str(player_pokemon.get("held_item", ""))
	if held_item == "":
		return ""
	var item_data := _loaded_item_data(held_item)
	if str(item_data.get("effect_type", "")) != "z_crystal":
		return ""
	return str(item_data.get("z_type", ""))


func _loaded_item_data(item_id: String) -> Dictionary:
	var file := FileAccess.open(ITEMS_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		return {}
	for item in parsed:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("id", "")) == item_id:
			return item
	return {}


func _show_bag() -> void:
	if battle_over or capture_in_progress:
		return
	if _require_forced_switch():
		return
	_hide_attack_panel()
	attack_panel = _new_bottom_panel("BagPanel", 128.0)
	# Only items you actually carry - a list padded with disabled "x0" entries
	# for everything the bag could theoretically hold is just clutter here.
	var item_ids := []
	for item_id in _battle_item_ids():
		if InventoryManager.get_item_amount(str(item_id)) > 0:
			item_ids.append(str(item_id))

	var scroll := TouchScrollContainer.new()
	scroll.name = "BattleBagScroll"
	scroll.position = Vector2(20, 508)
	scroll.size = Vector2(320, 90)
	scroll.clip_contents = true
	attack_panel.add_child(scroll)
	var content := Control.new()
	content.name = "BattleBagItems"
	content.custom_minimum_size = Vector2(304, max(38.0, ceil(float(item_ids.size()) / 2.0) * 38.0))
	scroll.add_child(content)
	if item_ids.is_empty():
		UI.add_panel_label(content, _text("item_empty"), Vector2(0, 4), Vector2(304, 30), 13, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "EmptyBag")
	for i in range(item_ids.size()):
		var item_id := str(item_ids[i])
		var amount := InventoryManager.get_item_amount(item_id)
		var pos := Vector2(4.0 + float(i % 2) * 154.0, float(int(i / 2)) * 38.0)
		var button := UI.add_orange_button(content, "%s x%d" % [_item_name(item_id), amount], pos, Vector2(146, 32), Callable(self, "_use_bag_item").bind(item_id), "Item%s" % item_id)
		var label = button.get_node_or_null("Text")
		if label is Label:
			label.add_theme_font_size_override("font_size", 10)
	UI.add_orange_button(attack_panel, _text("back"), Vector2(192, 604), Vector2(140, 24), Callable(self, "_hide_attack_panel"), "Back")


func _show_pokemon() -> void:
	if battle_over or capture_in_progress:
		return
	_hide_attack_panel()
	attack_panel = _new_bottom_panel("PokemonPanel", 132.0)
	var team := _battle_team()
	for i in range(min(team.size(), SaveManager.MAX_TEAM_SIZE)):
		if typeof(team[i]) != TYPE_DICTIONARY:
			continue
		var pokemon: Dictionary = PokemonHelpers.normalize_pokemon(team[i])
		var pos := Vector2(28.0 + float(i % 2) * 164.0, 506.0 + float(int(i / 2)) * 34.0)
		var max_hp := maxi(1, int(pokemon.get("max_hp", 1)))
		var hp := clampi(int(pokemon.get("hp", 0)), 0, max_hp)
		var fainted := hp <= 0
		var status_key := _normalized_status_key(pokemon.get("status_condition", ""))
		var tag := ""
		if i == player_team_index:
			tag = " • %s" % _text("switch_active_tag")
		elif fainted:
			tag = " • %s" % _text("switch_fainted_tag")
		elif status_key != "":
			tag = " • %s" % _status_display(status_key)
		var button_text := "%s%s %s%d\n%s %d/%d" % [
			str(pokemon.get("name", "Pokemon")),
			tag,
			_text("level"),
			int(pokemon.get("level", 1)),
			_text("hp"),
			hp,
			max_hp,
		]
		var button := UI.add_orange_button(attack_panel, button_text, pos, Vector2(140, 30), Callable(self, "_switch_pokemon").bind(i), "Switch%d" % i)
		var label = button.get_node_or_null("Text")
		if label is Label:
			label.add_theme_font_size_override("font_size", 10)
		var disabled := i == player_team_index or fainted or PokemonHelpers.is_healing(pokemon)
		if disabled:
			button.disabled = true
			button.modulate = Color(0.62, 0.62, 0.62, 0.9)
		var hp_ratio := float(hp) / float(max_hp)
		var hp_color := Color(0.24, 0.85, 0.24) if hp_ratio > 0.5 else (Color(0.95, 0.78, 0.20) if hp_ratio > 0.2 else Color(0.90, 0.24, 0.24))
		UI.add_ratio_bar(attack_panel, pos + Vector2(0, 30), Vector2(140, 3), hp_ratio, hp_color, Color(0.05, 0.05, 0.05, 0.85), "SwitchHp%d" % i)
	UI.add_orange_button(attack_panel, _text("back"), Vector2(192, 610), Vector2(140, 24), Callable(self, "_hide_attack_panel"), "Back")


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


func _new_bottom_panel(panel_name: String, height: float = 116.0) -> Control:
	var panel := Control.new()
	panel.name = panel_name
	panel.position = Vector2.ZERO
	panel.size = UI.SCREEN_SIZE
	add_child(panel)
	var bg := ColorRect.new()
	bg.name = "%sBg" % panel_name
	bg.position = Vector2(16, 504)
	bg.size = Vector2(328, height)
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

	var full_item_data := _loaded_item_data(item_id)
	if str(full_item_data.get("effect_type", "")) == "temp_stat_boost":
		_use_temp_stat_boost_item(item_id, full_item_data)
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
	if target_index == player_team_index:
		# A revive targets a benched, currently-off-screen Pokemon - only the
		# active player sprite is ever visible to glow.
		MoveAnimation.play_heal_glow(player_sprite, battle_effect_layer)
	var lines := [_text("item_used") % [str(target_pokemon.get("name", "Pokemon")), _item_name(item_id)]]
	_execute_enemy_turn(lines)
	if _finish_battle_if_needed(lines):
		return
	_finish_round(lines)


func _use_temp_stat_boost_item(item_id: String, item_data: Dictionary) -> void:
	var stat_key := PokemonHelpers.normalized_stat_key(str(item_data.get("effect_stat", "")))
	if stat_key == "" or not BATTLE_STAGE_KEYS.has(stat_key):
		message_label.text = _text("item_no_effect")
		return
	if not InventoryManager.remove_item(item_id, 1):
		return

	var amount := maxi(1, int(item_data.get("effect_value", 1)))
	_adjust_stat_stage(true, stat_key, amount)
	_hide_attack_panel()
	MoveAnimation.play_stat_aura(player_sprite, battle_effect_layer, amount > 0)
	var lines := [_text("item_used") % [str(player_pokemon.get("name", "Pokemon")), _item_name(item_id)]]
	lines.append(_text("stat_stage_boosted") % [str(player_pokemon.get("name", "Pokemon")), stat_key.capitalize()])
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
		var capture_data := _capture_enemy()
		var destination := str(capture_data.get("destination", "team"))
		battle_over = true
		_refresh_mega_button()
		_refresh_dynamax_button()
		_refresh_tera_button()
		var lines := [_text("capture_click"), _text("caught") % enemy_name]
		if destination == "storage":
			lines.append(_text("sent_storage"))
		else:
			lines.append(_text("sent_team") % enemy_name)
		var trainer_xp_result: Dictionary = capture_data.get("trainer_xp", {})
		var trainer_level_ups: Array = trainer_xp_result.get("level_ups", [])
		for level in trainer_level_ups:
			lines.append(_text("trainer_level_up") % int(level))
		if _is_tutorial_battle():
			lines.append_array(_grant_tutorial_reward())
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
	var specialization_bonus := 1.0 + float(SaveManager.specialization_points("captura")) * 0.01
	# Alpha Pokemon are exceptionally though to catch (Legends: Arceus) -
	# Master Ball still bypasses this entirely via the early return above,
	# matching how it guarantees a catch in the mainline games too.
	var alpha_penalty := 0.6 if bool(enemy_pokemon.get("alpha", false)) else 1.0
	var capture_value := hp_factor * catch_rate * multiplier * status_bonus * specialization_bonus * alpha_penalty
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
	# ADAPTACAO DO POKERPG: real Lucky Pokemon (Pokemon GO) come from trades,
	# which this single-player RPG has no equivalent of - rolled directly on
	# capture instead, as the closest "you just got this one, and it's
	# lucky" moment the game actually has.
	PokemonHelpers.roll_lucky(captured)
	PokemonHelpers.roll_gmax_factor(captured)
	var storage = save_data.get("storage", [])
	if typeof(storage) != TYPE_ARRAY:
		storage = []
	var destination := "team"
	var team_capacity := SaveManager.team_capacity_for_level(int(save_data.get("level", 1)))
	if battle_team.size() < team_capacity:
		battle_team.append(_battle_pokemon_copy(captured))
	else:
		storage.append(_battle_pokemon_copy(captured))
		destination = "storage"
	var pokedex_updates := PokemonHelpers.pokedex_seen_updates(captured, save_data)
	var owned_updates := PokemonHelpers.pokedex_owned_updates(captured, save_data)
	for key in owned_updates:
		pokedex_updates[key] = owned_updates[key]
	pokedex_updates["team"] = _battle_team_snapshot()
	pokedex_updates["storage"] = storage
	pokedex_updates["pending_encounter"] = {}
	pokedex_updates["active_pokemon_index"] = player_team_index
	SaveManager.update_current_save(pokedex_updates)
	var trainer_xp_result := SaveManager.grant_trainer_xp(_capture_trainer_xp(captured))
	save_data = SaveManager.get_current_save()
	return {"pokemon": captured, "destination": destination, "trainer_xp": trainer_xp_result}


# Rarer/harder-to-catch species (lower catch_rate) and higher-level wild
# Pokemon are worth more trainer XP; common low-level catches are worth little.
func _capture_trainer_xp(captured: Dictionary) -> int:
	var catch_rate := clampf(float(captured.get("catch_rate", DEFAULT_WILD_CATCH_RATE)), 1.0, 255.0)
	var level := maxi(1, int(captured.get("level", 1)))
	var base := maxi(5, int((255.0 - catch_rate) / 8.0) + level)
	return int(round(base * PokemonHelpers.variant_reward_multiplier(captured)))


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
	if not UI.resource_exists(texture_path):
		return
	var ball := TextureRect.new()
	ball.name = "CaptureBall"
	ball.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ball.texture = load(texture_path)
	ball.position = player_sprite.position + Vector2(44, 12)
	ball.size = Vector2(34, 34)
	ball.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ball.pivot_offset = ball.size * 0.5
	battle_effect_layer.add_child(ball)
	AudioManager.play_sfx("throw")

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
		AudioManager.play_sfx("success")
		var caught_tween := create_tween()
		caught_tween.tween_property(ball, "modulate", Color(1, 1, 1, 0.0), 0.22).set_delay(0.15)
		caught_tween.tween_callback(ball.queue_free)
		await caught_tween.finished
		return

	message_label.text = _text("capture_failed") % str(enemy_pokemon.get("name", "Pokemon"))
	AudioManager.play_sfx("fail")
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
	var outgoing_sprite := player_sprite
	player_sprite = PokemonHelpers.add_animated_sprite(self, player_pokemon, Vector2(36, 266), Vector2(112, 112), true, "PlayerSprite")
	MoveAnimation.play_switch_transition(outgoing_sprite, player_sprite)


# The Mega Stone this battle's active Pokemon is both a real species match
# for (see PokemonHelpers.megas_for_species) and actually holding - returns
# {} when it can't Mega Evolve right now (wrong/no held item, no Mega for
# this species, or already Mega Evolved this battle).
func _available_mega_for_player() -> Dictionary:
	if str(player_pokemon.get("mega", "")) != "" or bool(player_pokemon.get("dynamax", false)) or bool(player_pokemon.get("terastallized", false)):
		return {}
	var held_item := str(player_pokemon.get("held_item", ""))
	if held_item == "":
		return {}
	var pokemon_id := str(player_pokemon.get("id", ""))
	for mega_id in PokemonHelpers.megas_for_species(pokemon_id):
		var mega_def := PokemonHelpers.mega_definition(mega_id)
		if str(mega_def.get("item_id", "")) == held_item:
			mega_def["mega_id"] = mega_id
			return mega_def
	return {}


func _refresh_mega_button() -> void:
	if mega_button != null and is_instance_valid(mega_button):
		mega_button.queue_free()
		mega_button = null
	if battle_over or capture_in_progress:
		return
	if int(player_pokemon.get("hp", 0)) <= 0:
		return
	var mega_def := _available_mega_for_player()
	if mega_def.is_empty():
		return
	var button_label := _text("primal_revert") if str(mega_def.get("category", "mega")) == "primal" else _text("mega_evolve")
	mega_button = UI.add_orange_button(self, button_label, Vector2(166, 322), Vector2(120, 26), Callable(self, "_mega_evolve"), "MegaEvolveButton")


# Mega Evolving is "free" the same way it is in the real games - it doesn't
# consume this turn by itself, just transforms the Pokemon immediately, so
# the player can Mega Evolve and then still pick a move via the Fight panel
# in the same turn. Reverts automatically at the end of the battle (or if
# switched out and the battle ends before switching back) - see
# _battle_pokemon_copy's strip_mega handling, the only place the "mega"
# flag and its stat bonus are ever cleared.
func _mega_evolve() -> void:
	if battle_over or capture_in_progress or int(player_pokemon.get("hp", 0)) <= 0:
		return
	var mega_def := _available_mega_for_player()
	if mega_def.is_empty():
		return
	var before_name := str(player_pokemon.get("name", player_pokemon.get("species", "Pokemon")))
	player_pokemon["mega"] = str(mega_def.get("mega_id", ""))
	var stats := PokemonHelpers.stats_for_level(str(player_pokemon.get("id", "")), int(player_pokemon.get("level", 1)), bool(player_pokemon.get("black", false)), bool(player_pokemon.get("alpha", false)), bool(player_pokemon.get("purified", false)), true)
	for stat_key in ["max_hp", "attack", "defense", "sp_attack", "sp_defense", "speed"]:
		player_pokemon[stat_key] = int(stats.get(stat_key, player_pokemon.get(stat_key, 1)))
	player_pokemon = PokemonHelpers.normalize_pokemon(player_pokemon)
	battle_team[player_team_index] = _battle_pokemon_copy(player_pokemon)
	_refresh_player_sprite()
	var mega_name := str(mega_def.get("name_pt" if _language() == "pt" else "name_en", ""))
	if str(mega_def.get("category", "mega")) == "primal":
		message_label.text = _text("primal_reverted_message") % mega_name
	else:
		message_label.text = _text("mega_evolved_message") % [before_name, mega_name]
	_update_status()


# ADAPTACAO DO POKERPG: real-game Dynamax is a trainer-wide unlock (every
# Galar trainer has a Dynamax Band), not a per-Pokemon held item like a Mega
# Stone - gated here on owning one Dynamax Band (never consumed) instead.
# Mutually exclusive with Mega Evolution (see _available_mega_for_player),
# matching the real games never combining the two mechanics.
const DYNAMAX_BAND_ID := "dynamax_band"


func _can_dynamax() -> bool:
	if str(player_pokemon.get("mega", "")) != "" or bool(player_pokemon.get("dynamax", false)) or bool(player_pokemon.get("terastallized", false)):
		return false
	return InventoryManager.get_item_amount(DYNAMAX_BAND_ID) > 0


func _refresh_dynamax_button() -> void:
	if dynamax_button != null and is_instance_valid(dynamax_button):
		dynamax_button.queue_free()
		dynamax_button = null
	if battle_over or capture_in_progress:
		return
	if int(player_pokemon.get("hp", 0)) <= 0:
		return
	if not _can_dynamax():
		return
	dynamax_button = UI.add_orange_button(self, _text("dynamax"), Vector2(166, 350), Vector2(120, 26), Callable(self, "_dynamax"), "DynamaxButton")


# Lasts 3 rounds (see the countdown in _apply_end_turn_effects), same as the
# real games, then reverts automatically - stat bonus is a stored HP delta
# (see PokemonHelpers.dynamax_hp_bonus) added to both max_hp and current hp
# so a Dynamaxed Pokemon is never left over/under its new max, and
# _revert_dynamax subtracts the exact same delta back out when it ends.
func _dynamax() -> void:
	if battle_over or capture_in_progress or int(player_pokemon.get("hp", 0)) <= 0:
		return
	if not _can_dynamax():
		return
	var before_name := str(player_pokemon.get("name", player_pokemon.get("species", "Pokemon")))
	var bonus := PokemonHelpers.dynamax_hp_bonus(str(player_pokemon.get("id", "")), int(player_pokemon.get("level", 1)), bool(player_pokemon.get("black", false)), bool(player_pokemon.get("alpha", false)), bool(player_pokemon.get("purified", false)))
	var gmax_id := ""
	if bool(player_pokemon.get("gmax_factor", false)):
		var gmax_ids := PokemonHelpers.gmax_ids_for_species(str(player_pokemon.get("id", "")))
		if not gmax_ids.is_empty():
			gmax_id = str(gmax_ids[0])
	player_pokemon["dynamax"] = true
	player_pokemon["dynamax_gmax_id"] = gmax_id
	player_pokemon["dynamax_bonus_hp"] = bonus
	player_pokemon["dynamax_turns_remaining"] = 3
	player_pokemon["max_hp"] = int(player_pokemon.get("max_hp", 1)) + bonus
	player_pokemon["hp"] = int(player_pokemon.get("hp", 1)) + bonus
	player_pokemon = PokemonHelpers.normalize_pokemon(player_pokemon)
	battle_team[player_team_index] = _battle_pokemon_copy(player_pokemon)
	_refresh_player_sprite()
	message_label.text = _text("dynamaxed_message") % before_name
	_update_status()


# ADAPTACAO DO POKERPG: real Terastalization is gated by charges in a
# trainer-wide Tera Orb that recharge over time/per gym badge, not simple
# ownership - simplified here to the same "own the item" gate as the
# Dynamax Band, for consistency. Mutually exclusive with Mega/Dynamax
# (matching the real games, which never combine Terastalization with
# either). Unlike Mega/Dynamax, Terastalization changes no stat at all -
# only the sprite's tint and (via normalize_pokemon) both original types
# collapsing into the single Tera Type for the rest of the battle.
const TERA_ORB_ID := "tera_orb"


func _can_terastallize() -> bool:
	if str(player_pokemon.get("mega", "")) != "" or bool(player_pokemon.get("dynamax", false)) or bool(player_pokemon.get("terastallized", false)):
		return false
	if str(player_pokemon.get("tera_type", "")) == "":
		return false
	return InventoryManager.get_item_amount(TERA_ORB_ID) > 0


func _refresh_tera_button() -> void:
	if tera_button != null and is_instance_valid(tera_button):
		tera_button.queue_free()
		tera_button = null
	if battle_over or capture_in_progress:
		return
	if int(player_pokemon.get("hp", 0)) <= 0:
		return
	if not _can_terastallize():
		return
	tera_button = UI.add_orange_button(self, _text("terastallize"), Vector2(166, 378), Vector2(120, 26), Callable(self, "_terastallize"), "TeraButton")


func _terastallize() -> void:
	if battle_over or capture_in_progress or int(player_pokemon.get("hp", 0)) <= 0:
		return
	if not _can_terastallize():
		return
	var before_name := str(player_pokemon.get("name", player_pokemon.get("species", "Pokemon")))
	var tera_type := str(player_pokemon.get("tera_type", ""))
	player_pokemon["terastallized"] = true
	player_pokemon = PokemonHelpers.normalize_pokemon(player_pokemon)
	battle_team[player_team_index] = _battle_pokemon_copy(player_pokemon)
	_refresh_player_sprite()
	message_label.text = _text("terastallized_message") % [before_name, tera_type]
	_update_status()


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
		"x_attack":
			return "X Ataque" if _language() == "pt" else "X Attack"
		"x_defense":
			return "X Defesa" if _language() == "pt" else "X Defense"
		"x_sp_attack":
			return "X Ataque Especial" if _language() == "pt" else "X Sp. Attack"
		"x_sp_defense":
			return "X Defesa Especial" if _language() == "pt" else "X Sp. Defense"
		"x_speed":
			return "X Velocidade" if _language() == "pt" else "X Speed"
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
	# One sprite slot, centered - the "before" sprite transforms in place into
	# the "after" sprite (see EvolutionAnimation.play) rather than a static
	# before/after side-by-side, so this reads as an actual transformation.
	var before_sprite := PokemonHelpers.add_animated_sprite(overlay, before, Vector2(141, 210), Vector2(96, 96), false, "BeforeSprite")
	var after_sprite := PokemonHelpers.add_animated_sprite(overlay, after, Vector2(141, 210), Vector2(96, 96), false, "AfterSprite")
	var flash := ColorRect.new()
	flash.name = "Flash"
	flash.position = Vector2(141, 210)
	flash.size = Vector2(96, 96)
	flash.color = Color(1, 1, 1, 1)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.modulate.a = 0.0
	overlay.add_child(flash)
	var done_text := UI.add_panel_label(overlay, _text("evolution_done") % [before_name, after_name], Vector2(38, 318), Vector2(284, 58), 15, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "DoneText")
	done_text.visible = false
	var close_callback = func():
		overlay.queue_free()
	var close_button := UI.add_orange_button(overlay, "OK", Vector2(70, 396), Vector2(220, 48), close_callback, "CloseEvolution")
	close_button.visible = false
	var reveal := func():
		done_text.visible = true
		close_button.visible = true
	EvolutionAnimation.play(before_sprite, after_sprite, flash, reveal)


func _show_move_learn_popup(move_name: String) -> void:
	var pokemon_name := str(player_pokemon.get("name", "Pokemon"))
	var new_move := PokemonHelpers.move_by_name(move_name)
	var current_moves: Array = player_pokemon.get("moves", [])

	var overlay := Control.new()
	overlay.name = "MoveLearnPopup"
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

	UI.add_texture(overlay, UI.POPUP_PANEL, Vector2(15, 90), Vector2(330, 460), "Panel", TextureRect.STRETCH_SCALE)
	UI.add_panel_label(overlay, _text("move_learn_wants") % [pokemon_name, move_name], Vector2(38, 112), Vector2(284, 42), 15, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "WantsText")
	var info_label := UI.add_panel_label(overlay, _text("move_learn_full") % [pokemon_name, move_name], Vector2(38, 156), Vector2(284, 56), 12, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "InfoText")
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	for i in range(current_moves.size()):
		var move: Dictionary = current_moves[i] if typeof(current_moves[i]) == TYPE_DICTIONARY else {}
		var row := Button.new()
		row.name = "MoveSlot%d" % i
		row.position = Vector2(38, 220.0 + float(i) * 52.0)
		row.size = Vector2(284, 46)
		row.focus_mode = Control.FOCUS_NONE
		UI.style_panel_button(row, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
		overlay.add_child(row)
		var move_text := "%s | %s | PP %d" % [str(move.get("name", "Move")), str(move.get("type", "Normal")), int(move.get("pp", 35))]
		var label := UI.add_panel_label(row, move_text, Vector2(10, 0), Vector2(264, 46), 12, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "MoveText")
		label.clip_text = true
		row.pressed.connect(Callable(self, "_resolve_move_learn").bind(overlay, i, new_move))

	var cancel_callback = func():
		message_label.text = "%s\n%s" % [message_label.text, _text("move_learn_cancelled") % [pokemon_name, move_name]]
		overlay.queue_free()
	UI.add_orange_button(overlay, _text("give_up_learning"), Vector2(70, 452), Vector2(220, 48), cancel_callback, "GiveUpLearning")


func _resolve_move_learn(overlay: Control, slot: int, new_move: Dictionary) -> void:
	var moves: Array = player_pokemon.get("moves", [])
	if slot < 0 or slot >= moves.size():
		overlay.queue_free()
		return
	var new_name := str(new_move.get("name", ""))
	for i in range(moves.size()):
		if i == slot:
			continue
		var other: Dictionary = moves[i] if typeof(moves[i]) == TYPE_DICTIONARY else {}
		if str(other.get("name", "")) == new_name:
			# The same move was already learned into another slot (e.g. queued
			# twice by grant_xp across two level-ups before either was resolved) -
			# never write a second copy of an identical move.
			message_label.text = "%s\n%s" % [message_label.text, _text("move_learn_already_known") % [str(player_pokemon.get("name", "Pokemon")), new_name]]
			overlay.queue_free()
			return
	var old_move: Dictionary = moves[slot] if typeof(moves[slot]) == TYPE_DICTIONARY else {}
	var old_name := str(old_move.get("name", "Move"))
	moves[slot] = new_move
	player_pokemon["moves"] = moves

	var pp_max = player_pokemon.get("pp_max", [])
	var pp_current = player_pokemon.get("pp_current", [])
	if typeof(pp_max) != TYPE_ARRAY:
		pp_max = []
	if typeof(pp_current) != TYPE_ARRAY:
		pp_current = []
	while pp_max.size() <= slot:
		pp_max.append(1)
	while pp_current.size() <= slot:
		pp_current.append(1)
	pp_max[slot] = int(new_move.get("pp", 35))
	pp_current[slot] = int(new_move.get("pp", 35))
	player_pokemon["pp_max"] = pp_max
	player_pokemon["pp_current"] = pp_current

	_persist_player_pokemon()
	message_label.text = "%s\n%s" % [message_label.text, _text("move_learn_replaced") % [str(player_pokemon.get("name", "Pokemon")), old_name, str(new_move.get("name", "Move"))]]
	overlay.queue_free()


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
