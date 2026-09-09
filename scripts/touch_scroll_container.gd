extends ScrollContainer
class_name TouchScrollContainer

# Buttons/panels inside a ScrollContainer default to mouse_filter=STOP, which
# captures the whole touch gesture for themselves and never lets Godot's own
# gesture recognition hand a drag off to the ScrollContainer - on a screen
# that's almost entirely buttons (like the debug menu), that leaves nothing
# in the ScrollContainer's default drag-to-scroll to actually trigger.
# InputEventScreenDrag arrives through the separate raw-input channel
# regardless of which control captured the GUI click, so listening for it
# directly here scrolls reliably no matter what's underneath the finger.
var _drag_active := false


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and get_global_rect().has_point(event.position):
			_drag_active = true
		elif not event.pressed:
			_drag_active = false
	elif event is InputEventScreenDrag and _drag_active:
		scroll_vertical -= int(event.relative.y)
		scroll_horizontal -= int(event.relative.x)
