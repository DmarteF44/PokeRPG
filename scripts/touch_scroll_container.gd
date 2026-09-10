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
var _total_drag_distance := 0.0
var _suppress_next_release := false

# How far a touch has to move before it reads as "the user is scrolling,
# not tapping" - past this, the eventual finger-lift must not fire whatever
# button happened to be underneath it.
const DRAG_CANCEL_THRESHOLD := 14.0


func _ready() -> void:
	# Every screen in this app uses this container for a purely vertical
	# list - nothing here ever intends horizontal scrolling. Disabling the
	# axis outright (not just refraining from driving it below) is what
	# actually stops it: if some row's content is even a couple pixels
	# wider than the container (an oversized child, a border, autowrap
	# rounding), Godot still creates a real - if tiny - horizontal scroll
	# range on its own, and a vertical drag's natural left/right wobble was
	# enough to visibly nudge into it on exactly those screens (never on
	# ones with no such overflow), reading as "some screens drift sideways
	# when I scroll down and others don't".
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and get_global_rect().has_point(event.position):
			_drag_active = true
			_total_drag_distance = 0.0
			_suppress_next_release = false
		elif not event.pressed:
			if _suppress_next_release:
				# The finger moved like a scroll, not a tap, before lifting -
				# consume this release so whatever button is underneath the
				# final position never sees it and never fires "pressed".
				# Godot also emits a synthesized mouse click from the same
				# touch (emulate_mouse_from_touch defaults on), so that has
				# to be swallowed too, not just this raw touch event.
				get_viewport().set_input_as_handled()
			_drag_active = false
			_suppress_next_release = false
	elif event is InputEventScreenDrag and _drag_active:
		scroll_vertical -= int(event.relative.y)
		_total_drag_distance += event.relative.length()
		if _total_drag_distance > DRAG_CANCEL_THRESHOLD:
			_suppress_next_release = true
	elif event is InputEventMouseButton and not event.pressed and _suppress_next_release:
		# The touch-emulated mouse click for this same gesture - swallow it
		# too, or the button still receives a click via the mouse path.
		get_viewport().set_input_as_handled()
