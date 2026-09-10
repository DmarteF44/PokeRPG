extends Node
# Regression suite for the "some screens drift sideways while scrolling
# down" bug: TouchScrollContainer used to mirror a drag's raw x-relative
# motion into scroll_horizontal, which was invisible on screens with no
# horizontal overflow but became a real, visible sideways nudge on the few
# screens where some row's content was even a couple pixels wider than the
# container - human vertical swipes are never perfectly vertical, so the
# incidental x wobble was always there, just usually harmless.

var failures := []
var passes := 0


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame

	var scroll := TouchScrollContainer.new()
	scroll.position = Vector2(20, 20)
	scroll.size = Vector2(100, 200)
	get_tree().root.add_child(scroll)

	# Deliberately oversized content (wider than the container) so a real,
	# non-zero horizontal scroll range exists - this is exactly the
	# condition that made the bug visible on some screens and not others.
	var content := Control.new()
	content.custom_minimum_size = Vector2(400, 1000)
	scroll.add_child(content)
	await get_tree().process_frame
	# Same quirk this codebase already works around elsewhere (Button,
	# CheckBox, ...): a container's assigned .size can get overridden by a
	# child's minimum size once it enters the tree - reassert the small
	# viewport size so there's an actual, real scroll range to test against
	# instead of the container just growing to fit the oversized content.
	scroll.size = Vector2(100, 200)
	await get_tree().process_frame

	_check("horizontal scrolling is structurally disabled on this container",
		scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, scroll.horizontal_scroll_mode)

	# Simulate a real touch-drag-release gesture that isn't perfectly
	# vertical (every human swipe has some x wobble) directly through
	# _input(), the same path real touch input arrives through.
	var press := InputEventScreenTouch.new()
	press.pressed = true
	press.position = scroll.global_position + Vector2(10, 10)
	scroll._input(press)

	var before_h := scroll.scroll_horizontal
	var before_v := scroll.scroll_vertical

	for i in range(10):
		var drag := InputEventScreenDrag.new()
		# Negative y (finger moving up the screen) scrolls further down the
		# list from the starting top position - mostly vertical, but with
		# real x wobble, like any actual human swipe.
		drag.relative = Vector2(3, -15)
		scroll._input(drag)

	var release := InputEventScreenTouch.new()
	release.pressed = false
	release.position = scroll.global_position + Vector2(40, 160)
	scroll._input(release)

	_check("a diagonal drag actually moved the vertical scroll", scroll.scroll_vertical != before_v, scroll.scroll_vertical)
	_check("a diagonal drag's x wobble never moves scroll_horizontal, even with real horizontal overflow available",
		scroll.scroll_horizontal == before_h and scroll.scroll_horizontal == 0, scroll.scroll_horizontal)

	print("\n=== TOUCH SCROLL NO-HORIZONTAL-DRIFT TEST: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("FAIL: " + f)
	get_tree().quit(1 if not failures.is_empty() else 0)


func _check(label: String, condition: bool, detail) -> void:
	if condition:
		passes += 1
	else:
		failures.append("%s (got: %s)" % [label, str(detail)])
		print("FAIL: %s (got: %s)" % [label, str(detail)])
