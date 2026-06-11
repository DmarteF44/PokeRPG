extends Node

var current_save_slot := 0
var player_name := ""
var avatar_id := 1
var money := 0
var level := 0
var badges := 0
var energy_current := 30
var energy_max := 30
var last_energy_reset := ""
var starter_name := ""
var starter_id := ""
var starter_generation := 1
var starter_dex_number := 4


func apply_save(save_data: Dictionary) -> void:
	current_save_slot = int(save_data.get("slot", 0))
	player_name = str(save_data.get("player_name", ""))
	avatar_id = int(save_data.get("avatar_id", 1))
	money = int(save_data.get("money", 0))
	level = int(save_data.get("level", 0))
	badges = int(save_data.get("badges", 0))
	energy_current = int(save_data.get("energy_current", 30))
	energy_max = int(save_data.get("energy_max", 30))
	last_energy_reset = str(save_data.get("last_energy_reset", ""))
	starter_id = str(save_data.get("starter_id", "charmander"))
	starter_name = str(save_data.get("starter_name", "Charmander"))
	starter_generation = int(save_data.get("starter_generation", 1))
	starter_dex_number = int(save_data.get("starter_dex_number", 4))


func clear() -> void:
	current_save_slot = 0
	player_name = ""
	avatar_id = 1
	money = 0
	level = 0
	badges = 0
	energy_current = 30
	energy_max = 30
	last_energy_reset = ""
	starter_id = ""
	starter_name = ""
	starter_generation = 1
	starter_dex_number = 4
