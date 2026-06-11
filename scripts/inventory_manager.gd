extends Node

const DEFAULT_INVENTORY = {
	"poke_ball": 5,
	"potion": 3,
	"town_map": 1,
}

var _inventory: Dictionary = {}


func ensure_default_inventory() -> void:
	var save_data := SaveManager.get_current_save()
	if save_data.is_empty():
		_inventory = DEFAULT_INVENTORY.duplicate(true)
		return

	var source = save_data.get("inventory", {})
	if typeof(source) == TYPE_DICTIONARY:
		_inventory = _sanitize_inventory(source)
	else:
		_inventory = {}

	if _inventory.is_empty():
		_inventory = DEFAULT_INVENTORY.duplicate(true)

	save_inventory_to_current_save()


func get_inventory() -> Dictionary:
	ensure_default_inventory()
	return _inventory.duplicate(true)


func get_item_amount(item_id: String) -> int:
	ensure_default_inventory()
	return int(_inventory.get(item_id, 0))


func add_item(item_id: String, amount: int) -> void:
	if item_id == "" or amount <= 0:
		return

	ensure_default_inventory()
	_inventory[item_id] = get_item_amount(item_id) + amount
	save_inventory_to_current_save()


func remove_item(item_id: String, amount: int) -> bool:
	if item_id == "" or amount <= 0:
		return false

	ensure_default_inventory()
	var current_amount := get_item_amount(item_id)
	if current_amount < amount:
		return false

	_inventory[item_id] = current_amount - amount
	save_inventory_to_current_save()
	return true


func save_inventory_to_current_save() -> void:
	var save_data := SaveManager.get_current_save()
	if save_data.is_empty():
		return

	SaveManager.update_current_save({"inventory": _inventory.duplicate(true)})


func _sanitize_inventory(source: Dictionary) -> Dictionary:
	var sanitized := {}
	for item_id in source.keys():
		sanitized[str(item_id)] = max(0, int(source[item_id]))
	return sanitized
