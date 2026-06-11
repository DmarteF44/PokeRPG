extends TextureRect

var frames: Array = []
var fps := 12.0

var _elapsed := 0.0
var _frame_index := 0


func set_frames(new_frames: Array, fallback_texture: Texture2D = null, target_fps: float = 12.0) -> void:
	frames = new_frames.duplicate()
	fps = maxf(1.0, target_fps)
	_elapsed = 0.0
	_frame_index = 0

	if frames.is_empty():
		texture = fallback_texture
		set_process(false)
		return

	texture = frames[0]
	set_process(frames.size() > 1)


func _process(delta: float) -> void:
	if frames.size() <= 1:
		set_process(false)
		return

	_elapsed += minf(delta, 0.1)
	var frame_time := 1.0 / fps
	while _elapsed >= frame_time:
		_elapsed -= frame_time
		_frame_index = (_frame_index + 1) % frames.size()
		texture = frames[_frame_index]
