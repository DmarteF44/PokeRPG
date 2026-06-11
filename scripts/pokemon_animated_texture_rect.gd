extends TextureRect

var frames: Array = []
var fps := 12.0

var _elapsed := 0.0
var _frame_index := 0
var _base_position := Vector2.ZERO
var _idle_elapsed := 0.0
var _idle_enabled := false


func set_frames(new_frames: Array, fallback_texture: Texture2D = null, target_fps: float = 12.0) -> void:
	frames = new_frames.duplicate()
	fps = maxf(1.0, target_fps)
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
