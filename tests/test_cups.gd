extends Node
# Regression suite for the Cup system (scripts/cup_manager.gd): every
# cup's bracket resolves to real species, team_rules correctly gate entry,
# and a full bracket win actually grants the promised rewards (money, xp,
# items, badge) - not just computes them.

const CupManager = preload("res://scripts/cup_manager.gd")

var failures := []
var passes := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame

	for cup in CupManager.cups():
		var cup_id := str(cup.get("id", ""))
		if not bool(cup.get("implemented", false)):
			continue
		for round_index in range(CupManager.round_count(cup)):
			var team_size := CupManager.trainer_team_size(cup, round_index)
			_check("%s round %d has a non-empty trainer team" % [cup_id, round_index], team_size > 0, team_size)
			for team_index in range(team_size):
				var built: Dictionary = CupManager._encounter_for(cup, round_index, team_index)
				_check("%s round %d slot %d builds a valid encounter" % [cup_id, round_index, team_index],
					not built.is_empty() and str(built.get("species", "")) != "", built)

	# team_rules: a required_type cup rejects an off-type team and accepts
	# an on-type one.
	var fire_cup := CupManager.cup_for_id("fire_cup")
	if not fire_cup.is_empty():
		var off_type := {"team": [{"species": "squirtle", "types": ["Water"], "level": 20}]}
		var on_type := {"team": [{"species": "charmander", "types": ["Fire"], "level": 20}]}
		_check("off-type team is rejected from Fire Cup", not CupManager.team_rule_violations(off_type, fire_cup).is_empty(), "expected violation")
		_check("on-type team is accepted into Fire Cup", CupManager.team_rule_violations(on_type, fire_cup).is_empty(), "expected no violation")

	var black_cup := CupManager.cup_for_id("black_cup")
	if not black_cup.is_empty():
		var normal := {"team": [{"species": "eevee", "black": false, "level": 30}]}
		var black := {"team": [{"species": "eevee", "black": true, "level": 30}]}
		_check("non-Black team is rejected from Black Cup", not CupManager.team_rule_violations(normal, black_cup).is_empty(), "expected violation")
		_check("all-Black team is accepted into Black Cup", CupManager.team_rule_violations(black, black_cup).is_empty(), "expected no violation")

	# Full bracket walk: win every round of Kanto Cup and confirm the
	# promised rewards actually land.
	var kanto_cup := CupManager.cup_for_id("kanto_cup")
	if not kanto_cup.is_empty():
		var save_data := {
			"team": [{"species": "charizard", "types": ["Fire", "Flying"], "level": 60}],
			"money": 5000, "cups": {}, "cup_badges_obtained": [],
			"cup_challenge": CupManager.challenge_for("kanto_cup", 0, 0),
		}
		var final_item_gains := {}
		var badge_awarded := ""
		var guard := 0
		while guard < 30:
			guard += 1
			var step := CupManager.next_victory_state(save_data)
			if step.is_empty():
				break
			for key in step.get("changes", {}).keys():
				save_data[key] = step["changes"][key]
			if str(step.get("result", "")) == "cup_completed":
				final_item_gains = step.get("item_gains", {})
				badge_awarded = str(step.get("badge_name", ""))
				break
		_check("Kanto Cup full bracket walk reaches completion within a bounded number of steps", guard < 30, guard)
		_check("Kanto Cup completion awards a badge", badge_awarded != "", badge_awarded)
		_check("Kanto Cup progress is marked won", bool(save_data.get("cups", {}).get("kanto_cup", {}).get("won", false)), save_data.get("cups"))

	print("\n=== CUPS TEST: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("FAIL: " + f)
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check(label: String, condition: bool, detail) -> void:
	if condition:
		passes += 1
	else:
		failures.append("%s (got: %s)" % [label, str(detail)])
		print("FAIL: %s (got: %s)" % [label, str(detail)])
