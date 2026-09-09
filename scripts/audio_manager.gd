extends Node

const SFX_PATHS = {
	"click": "res://assets/audio/sfx/click.wav",
	"success": "res://assets/audio/sfx/success.wav",
	"fail": "res://assets/audio/sfx/fail.wav",
	"hit": "res://assets/audio/sfx/hit.wav",
	"heal": "res://assets/audio/sfx/heal.wav",
	"level_up": "res://assets/audio/sfx/level_up.wav",
	"throw": "res://assets/audio/sfx/throw.wav",
	"open": "res://assets/audio/sfx/open.wav",
	"close": "res://assets/audio/sfx/close.wav",
}
const MUSIC_PATH = "res://assets/audio/music/theme_loop.wav"

var _sfx_players: Array = []
var _next_sfx_player := 0
var _music_player: AudioStreamPlayer


func _ready() -> void:
	# A small pool so two SFX overlapping (e.g. a click right as a hit lands)
	# don't cut each other off - a single shared player would restart on reuse.
	for i in range(4):
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % i
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)

	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Master"
	add_child(_music_player)
	if ResourceLoader.exists(MUSIC_PATH):
		var stream = load(MUSIC_PATH)
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_music_player.stream = stream

	refresh_settings()


func refresh_settings() -> void:
	var settings := SaveManager.load_settings()
	var music_on := bool(settings.get("music_enabled", true))
	if music_on:
		if _music_player.stream != null and not _music_player.playing:
			_music_player.play()
	else:
		_music_player.stop()


func play_sfx(id: String) -> void:
	var settings := SaveManager.load_settings()
	if not bool(settings.get("sfx_enabled", true)):
		return
	var path := str(SFX_PATHS.get(id, ""))
	if path == "" or not ResourceLoader.exists(path):
		return
	var player: AudioStreamPlayer = _sfx_players[_next_sfx_player]
	_next_sfx_player = (_next_sfx_player + 1) % _sfx_players.size()
	player.stream = load(path)
	player.play()
