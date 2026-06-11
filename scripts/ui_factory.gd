extends RefCounted

const SCREEN_SIZE = Vector2(360, 640)
const BACKGROUND = "res://assets/backgrounds/gray_texture_360x640.png"
const TOPBAR = "res://assets/ui/topbar_360x44.png"
const POPUP_PANEL = "res://assets/ui/popup_panel_blue_330x520.png"
const LIST_SLOT = "res://assets/ui/list_slot_gray_320x54.png"
const PANEL_TEXT = Color(0.05, 0.12, 0.20)

static func setup_screen(root: Control) -> void:
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.custom_minimum_size = SCREEN_SIZE
	root.size = SCREEN_SIZE


static func add_background(parent: Node) -> TextureRect:
	var bg := add_texture(parent, BACKGROUND, Vector2.ZERO, SCREEN_SIZE, "GrayBackground", TextureRect.STRETCH_SCALE)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return bg


static func add_topbar(parent: Node) -> TextureRect:
	return add_texture(parent, TOPBAR, Vector2.ZERO, Vector2(360, 44), "Topbar", TextureRect.STRETCH_SCALE)


static func add_texture(parent: Node, path: String, pos: Vector2, node_size: Vector2, node_name: String, stretch_mode: int) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.name = node_name
	texture_rect.texture = load(path)
	texture_rect.position = pos
	texture_rect.size = node_size
	texture_rect.stretch_mode = stretch_mode
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture_rect)
	return texture_rect


static func add_label(parent: Node, text: String, pos: Vector2, node_size: Vector2, font_size: int, color: Color, align: int, valign: int, node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.position = pos
	label.size = node_size
	label.horizontal_alignment = align
	label.vertical_alignment = valign
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("outline_size", 2)
	parent.add_child(label)
	return label


static func add_panel_label(parent: Node, text: String, pos: Vector2, node_size: Vector2, font_size: int, align: int, valign: int, node_name: String) -> Label:
	var label := add_label(parent, text, pos, node_size, font_size, PANEL_TEXT, align, valign, node_name)
	label.add_theme_constant_override("outline_size", 0)
	return label


static func add_icon_button(parent: Node, icon_path: String, pos: Vector2, callback: Callable, node_name: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.texture_normal = load(icon_path)
	button.texture_pressed = load(icon_path)
	button.position = pos
	button.size = Vector2(32, 32)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.focus_mode = Control.FOCUS_NONE
	parent.add_child(button)
	if callback.is_valid():
		button.pressed.connect(callback)
	return button


static func add_orange_button(parent: Node, text: String, pos: Vector2, node_size: Vector2, callback: Callable, node_name: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.texture_normal = load(_orange_normal_for_size(node_size))
	button.texture_pressed = load(_orange_pressed_for_size(node_size))
	button.position = pos
	button.size = node_size
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.focus_mode = Control.FOCUS_NONE
	parent.add_child(button)
	if callback.is_valid():
		button.pressed.connect(callback)

	var label := add_label(button, text, Vector2.ZERO, node_size, 17, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Text")
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return button


static func add_list_button(parent: Node, text: String, icon_path: String, pos: Vector2, callback: Callable, node_name: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.texture_normal = load(LIST_SLOT)
	button.texture_pressed = load(LIST_SLOT)
	button.position = pos
	button.size = Vector2(320, 54)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.focus_mode = Control.FOCUS_NONE
	parent.add_child(button)
	if callback.is_valid():
		button.pressed.connect(callback)

	var label_x := 0.0
	var label_width := 320.0
	if icon_path != "":
		var icon := add_texture(button, icon_path, Vector2(12, 7), Vector2(40, 40), "Icon", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label_x = 62.0
		label_width = 238.0

	var label := add_label(button, text, Vector2(label_x, 0), Vector2(label_width, 54), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Text")
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return button


static func show_message_popup(parent: Node, title: String, message: String) -> Control:
	var overlay := Control.new()
	overlay.name = "MessagePopup"
	overlay.position = Vector2.ZERO
	overlay.size = SCREEN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(overlay)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.45)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)

	add_texture(overlay, POPUP_PANEL, Vector2(15, 110), Vector2(330, 360), "PopupPanel", TextureRect.STRETCH_SCALE)
	add_panel_label(overlay, title, Vector2(44, 140), Vector2(272, 36), 22, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Title")
	add_panel_label(overlay, message, Vector2(42, 205), Vector2(276, 110), 18, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Message")

	var close := add_icon_button(overlay, "res://assets/icons/icon_close_32.png", Vector2(298, 128), Callable(), "Close")
	close.pressed.connect(func():
		overlay.queue_free()
	)

	var ok_callback = func():
		overlay.queue_free()
	add_orange_button(overlay, "OK", Vector2(70, 370), Vector2(220, 48), ok_callback, "OkButton")
	return overlay


static func show_confirm_popup(parent: Node, title: String, message: String, yes_text: String, no_text: String, on_yes: Callable) -> Control:
	var overlay := Control.new()
	overlay.name = "ConfirmPopup"
	overlay.position = Vector2.ZERO
	overlay.size = SCREEN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(overlay)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.45)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)

	add_texture(overlay, POPUP_PANEL, Vector2(15, 150), Vector2(330, 300), "PopupPanel", TextureRect.STRETCH_SCALE)
	add_panel_label(overlay, title, Vector2(44, 184), Vector2(272, 34), 22, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Title")
	add_panel_label(overlay, message, Vector2(42, 246), Vector2(276, 72), 18, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Message")

	var yes_callback = func():
		if on_yes.is_valid():
			on_yes.call()
		overlay.queue_free()
	add_orange_button(overlay, yes_text, Vector2(38, 356), Vector2(140, 44), yes_callback, "YesButton")

	var no_callback = func():
		overlay.queue_free()
	add_orange_button(overlay, no_text, Vector2(182, 356), Vector2(140, 44), no_callback, "NoButton")
	return overlay


static func show_options_popup(parent: Node, title: String, labels: Dictionary, on_apply: Callable) -> Control:
	var overlay := Control.new()
	overlay.name = "OptionsPopup"
	overlay.position = Vector2.ZERO
	overlay.size = SCREEN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(overlay)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.45)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)

	add_texture(overlay, POPUP_PANEL, Vector2(15, 92), Vector2(330, 420), "PopupPanel", TextureRect.STRETCH_SCALE)
	add_panel_label(overlay, title, Vector2(50, 120), Vector2(260, 34), 23, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Title")

	var close := add_icon_button(overlay, "res://assets/icons/icon_close_32.png", Vector2(298, 112), Callable(), "Close")
	close.pressed.connect(func():
		overlay.queue_free()
	)

	var settings := SaveManager.get_settings()
	var music_check := CheckBox.new()
	music_check.name = "MusicCheck"
	music_check.text = str(labels.get("music", "Music"))
	music_check.position = Vector2(46, 164)
	music_check.size = Vector2(268, 40)
	music_check.button_pressed = bool(settings.get("music_enabled", true))
	_style_panel_check(music_check)
	overlay.add_child(music_check)

	var sfx_check := CheckBox.new()
	sfx_check.name = "SfxCheck"
	sfx_check.text = str(labels.get("sfx", "Sound Effects"))
	sfx_check.position = Vector2(46, 214)
	sfx_check.size = Vector2(268, 40)
	sfx_check.button_pressed = bool(settings.get("sfx_enabled", true))
	_style_panel_check(sfx_check)
	overlay.add_child(sfx_check)

	add_panel_label(overlay, str(labels.get("language", "Language")), Vector2(46, 276), Vector2(120, 30), 16, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "LanguageLabel")

	var language_option := OptionButton.new()
	language_option.name = "LanguageOption"
	language_option.position = Vector2(166, 274)
	language_option.size = Vector2(148, 36)
	language_option.add_item("English", 0)
	language_option.add_item("Portugues", 1)
	language_option.select(1 if str(settings.get("language", "en")) == "pt" else 0)
	language_option.add_theme_font_size_override("font_size", 15)
	language_option.add_theme_color_override("font_color", PANEL_TEXT)
	overlay.add_child(language_option)

	var apply_callback = func():
		var language := "pt" if language_option.selected == 1 else "en"
		SaveManager.save_settings({
			"music_enabled": music_check.button_pressed,
			"sfx_enabled": sfx_check.button_pressed,
			"language": language,
		})
		if on_apply.is_valid():
			on_apply.call(SaveManager.get_settings())
		overlay.queue_free()
	add_orange_button(overlay, str(labels.get("apply", "Apply")), Vector2(38, 398), Vector2(140, 44), apply_callback, "ApplyOptions")

	var cancel_callback = func():
		overlay.queue_free()
	add_orange_button(overlay, str(labels.get("cancel", "Cancel")), Vector2(182, 398), Vector2(140, 44), cancel_callback, "CancelOptions")
	return overlay


static func style_panel_button(control: Control, fill: Color, border: Color, border_width: int = 2) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = fill
	normal.border_color = border
	normal.set_border_width_all(border_width)
	normal.set_corner_radius_all(6)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = fill.lightened(0.05)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = fill.darkened(0.07)

	control.add_theme_stylebox_override("panel", normal)
	control.add_theme_stylebox_override("normal", normal)
	control.add_theme_stylebox_override("hover", hover)
	control.add_theme_stylebox_override("pressed", pressed)
	control.add_theme_stylebox_override("focus", normal)


static func _style_panel_check(check_box: CheckBox) -> void:
	check_box.focus_mode = Control.FOCUS_NONE
	check_box.add_theme_font_size_override("font_size", 16)
	check_box.add_theme_color_override("font_color", PANEL_TEXT)
	check_box.add_theme_color_override("font_hover_color", PANEL_TEXT)
	check_box.add_theme_color_override("font_pressed_color", PANEL_TEXT)


static func _orange_normal_for_size(node_size: Vector2) -> String:
	if node_size.x <= 190.0:
		return "res://assets/ui/button_orange_180x40.png"
	if node_size.x >= 240.0:
		return "res://assets/ui/button_orange_250x52.png"
	return "res://assets/ui/button_orange_220x48.png"


static func _orange_pressed_for_size(node_size: Vector2) -> String:
	if node_size.x <= 190.0:
		return "res://assets/ui/button_orange_180x40_pressed.png"
	if node_size.x >= 240.0:
		return "res://assets/ui/button_orange_250x52_pressed.png"
	return "res://assets/ui/button_orange_220x48_pressed.png"
