extends Node

const DEFAULT_INVENTORY = {
	"poke_ball": 5,
	"potion": 3,
	"town_map": 1,
}

var _inventory: Dictionary = {}

# Which save _inventory currently reflects, so ensure_default_inventory()
# - called on every single read (get_item_amount(), get_inventory()), often
# many times per screen (once per Bag row, once per owned-item check) - can
# skip re-deriving from the save and, critically, skip writing back to disk
# when nothing actually changed. InventoryManager is the sole writer of the
# save's "inventory" field (see save_inventory_to_current_save()), so once
# synced to a given save, the in-memory copy stays authoritative for it.
#
# Save slots are reused fixed numbers (1..MAX_SAVE_SLOTS), so slot alone
# isn't a stable identity: delete the save in slot 1, then start a new game
# in that same slot within the same app session, and slot-only tracking
# would see "still slot 1" and skip re-syncing, leaking the deleted
# playthrough's item counts into the new one. create_save() always stamps a
# fresh created_at even when reusing a slot, so pairing it with the slot
# catches that case.
var _synced_slot := -1
var _synced_created_at := ""
var _has_synced := false


func ensure_default_inventory() -> void:
	var save_data := SaveManager.get_current_save()
	if save_data.is_empty():
		if not _has_synced or _synced_slot != -1:
			_inventory = DEFAULT_INVENTORY.duplicate(true)
			_synced_slot = -1
			_synced_created_at = ""
			_has_synced = true
		return

	var slot := int(save_data.get("slot", 0))
	var created_at := str(save_data.get("created_at", ""))
	if _has_synced and slot == _synced_slot and created_at == _synced_created_at:
		return

	var needs_write := false
	var source = save_data.get("inventory", {})
	if typeof(source) == TYPE_DICTIONARY:
		_inventory = _sanitize_inventory(source)
	else:
		_inventory = {}
		needs_write = true

	if _inventory.is_empty():
		_inventory = DEFAULT_INVENTORY.duplicate(true)
		needs_write = true

	_synced_slot = slot
	_synced_created_at = created_at
	_has_synced = true
	if needs_write:
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
	_inventory[item_id] = int(_inventory.get(item_id, 0)) + amount
	save_inventory_to_current_save()


func remove_item(item_id: String, amount: int) -> bool:
	if item_id == "" or amount <= 0:
		return false

	ensure_default_inventory()
	var current_amount := int(_inventory.get(item_id, 0))
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
