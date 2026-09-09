extends TextureRect

var frames: Array = []
var fps := 12.0

var _elapsed := 0.0
var _frame_index := 0
var _base_position := Vector2.ZERO
var _idle_elapsed := 0.0
var _idle_enabled := false


func set_frames(new_frames: Array, fallback_texture: Texture2D = null, target_loop_seconds: float = 1.2) -> void:
	frames = new_frames.duplicate()
	# A fixed frames-per-second rate made the idle loop's actual cadence
	# depend on how many frames a species happened to have - when the
	# extractor's per-species frame cap dropped (16 -> 8 -> 4, for APK
	# size), every sprite's idle animation got proportionally faster along
	# with it, which read as "way too fast" even though nothing about the
	# intended pace changed. Deriving fps from a fixed loop duration instead
	# keeps the perceived speed constant no matter how many frames a given
	# species ends up with, now or after any future re-extraction.
	fps = maxf(1.0, float(new_frames.size()) / maxf(0.1, target_loop_seconds))
	_elapsed = 0.0
	_frame_index = 0
	_base_position = position
	_idle_elapsed = 0.0
	_idle_enabled = frames.size() <= 1

	if frames.is_empty():
		texture = fallback_texture
		set_process(_idle_enabled and fallback_texture != null)
		return

	texture = frames[0]
	set_process(frames.size() > 1 or _idle_enabled)


func _process(delta: float) -> void:
	if _idle_enabled:
		_idle_elapsed += delta
		position = _base_position + Vector2(0.0, sin(_idle_elapsed * TAU * 0.8) * 2.0)
		if frames.size() <= 1:
			return

	_elapsed += minf(delta, 0.1)
	var frame_time := 1.0 / fps
	while _elapsed >= frame_time:
		_elapsed -= frame_time
		_frame_index = (_frame_index + 1) % frames.size()
		texture = frames[_frame_index]
