class_name MoveAnimation
extends RefCounted

# Reusable move-animation components, shared by every move through its
# type/category/effect metadata (see data/moves.json) instead of one
# bespoke animation per move. battle_scene.gd picks which component to
# play from a move's "category" (Physical/Special/Status) and its
# "effects" entries (modify_stat/apply_status/heal) - adding a new move,
# or a whole new generation of moves, needs no new animation code as long
# as it reuses these same fields.

const STATUS_COLORS := {
	"burn": Color(0.95, 0.35, 0.1),
	"freeze": Color(0.55, 0.85, 0.95),
	"paralysis": Color(0.95, 0.85, 0.15),
	"poison": Color(0.6, 0.25, 0.75),
	"sleep": Color(0.25, 0.35, 0.75),
	"confusion": Color(0.9, 0.4, 0.75),
}
# Plain-ASCII abbreviations (matching the classic status shorthand shown
# next to HP bars in the mainline games) so the glyph always renders,
# regardless of font glyph coverage.
const STATUS_GLYPHS := {
	"burn": "BRN",
	"freeze": "FRZ",
	"paralysis": "PAR",
	"poison": "PSN",
	"sleep": "SLP",
	"confusion": "CNF",
}

static func _sprite_center(sprite: TextureRect) -> Vector2:
	return sprite.position + sprite.size * 0.5


# Physical moves (Tackle, Scratch, Quick Attack, ...): the type icon punches
# onto the target in place - a quick, blunt pop with a jolt on the target
# sprite, reused for every physical move regardless of type.
static func play_impact(target_sprite: TextureRect, effect_layer: Control, texture: Texture2D) -> void:
	if target_sprite == null or not is_instance_valid(target_sprite) or effect_layer == null or not is_instance_valid(effect_layer) or texture == null:
		return
	var effect := TextureRect.new()
	effect.name = "MoveEffect"
	effect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	effect.texture = texture
	effect.size = Vector2(96, 96)
	effect.position = _sprite_center(target_sprite) - effect.size * 0.5
	effect.pivot_offset = effect.size * 0.5
	effect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.modulate = Color(1, 1, 1, 0.95)
	effect.scale = Vector2(0.72, 0.72)
	effect_layer.add_child(effect)

	var tween := effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "scale", Vector2(1.26, 1.26), 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "rotation", randf_range(-0.18, 0.18), 0.42)
	tween.tween_property(effect, "modulate", Color(1, 1, 1, 0.0), 0.42).set_delay(0.18)
	tween.set_parallel(false)
	tween.tween_callback(effect.queue_free)

	var original_pos := target_sprite.position
	var jolt := target_sprite.create_tween()
	jolt.tween_property(target_sprite, "position", original_pos + Vector2(6, 0), 0.08)
	jolt.tween_property(target_sprite, "position", original_pos - Vector2(6, 0), 0.10)
	jolt.tween_property(target_sprite, "position", original_pos, 0.08)


# Special moves (Ember, Water Gun, Ice Beam, Thunderbolt, Vine Whip, Gust,
# ...): the type icon travels from the user to the target before impacting,
# reading as a projectile/beam/blast rather than an instant pop - reused for
# every special move of every type.
static func play_projectile(attacker_sprite: TextureRect, target_sprite: TextureRect, effect_layer: Control, texture: Texture2D, on_impact: Callable) -> void:
	if attacker_sprite == null or not is_instance_valid(attacker_sprite) or target_sprite == null or not is_instance_valid(target_sprite):
		if on_impact.is_valid():
			on_impact.call()
		return
	if effect_layer == null or not is_instance_valid(effect_layer) or texture == null:
		if on_impact.is_valid():
			on_impact.call()
		return

	var effect := TextureRect.new()
	effect.name = "MoveProjectile"
	effect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	effect.texture = texture
	effect.size = Vector2(64, 64)
	effect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.pivot_offset = effect.size * 0.5
	effect.scale = Vector2(0.55, 0.55)
	var start := _sprite_center(attacker_sprite) - effect.size * 0.5
	var dest := _sprite_center(target_sprite) - effect.size * 0.5
	effect.position = start
	effect_layer.add_child(effect)

	var tween := effect.create_tween()
	tween.tween_property(effect, "position", dest, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(effect, "scale", Vector2(0.85, 0.85), 0.55)
	tween.tween_callback(func():
		effect.queue_free()
		if on_impact.is_valid():
			on_impact.call()
	)


# Status moves that inflict no damage (Growl, ...): a soft ring pulses out
# from the caster as it "casts" the move, distinct from the impact/
# projectile pop used by damaging moves.
static func play_status_wave(caster_sprite: TextureRect, effect_layer: Control) -> void:
	if caster_sprite == null or not is_instance_valid(caster_sprite) or effect_layer == null or not is_instance_valid(effect_layer):
		return
	var ring := _make_ring(_sprite_center(caster_sprite), Color(0.85, 0.85, 0.9, 0.75))
	effect_layer.add_child(ring)
	var tween := ring.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(2.2, 2.2), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.7)
	tween.set_parallel(false)
	tween.tween_callback(ring.queue_free)


# A stat change lands on its target: a gold ring rising (buff) or a dull
# violet ring sinking (debuff), shared by every stat-modifying move and by
# temp stat-boost items (X Attack, etc.).
static func play_stat_aura(target_sprite: TextureRect, effect_layer: Control, is_buff: bool) -> void:
	if target_sprite == null or not is_instance_valid(target_sprite) or effect_layer == null or not is_instance_valid(effect_layer):
		return
	var color := Color(0.95, 0.8, 0.2, 0.85) if is_buff else Color(0.45, 0.25, 0.55, 0.85)
	var center := _sprite_center(target_sprite)
	var ring := _make_ring(center, color)
	effect_layer.add_child(ring)
	var drift := Vector2(0, -18) if is_buff else Vector2(0, 18)
	var tween := ring.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(1.6, 1.6), 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "position", ring.position + drift, 0.85).set_trans(Tween.TRANS_SINE)
	tween.tween_property(ring, "modulate:a", 0.0, 0.85)
	tween.set_parallel(false)
	tween.tween_callback(ring.queue_free)


# A status condition (Burn/Freeze/Paralysis/Poison/Sleep/Confusion) is
# applied: the sprite flashes the status' color and a small glyph pops
# above it - one shared, data-driven treatment for every status key
# instead of a bespoke effect per status or per move.
static func play_status_condition(target_sprite: TextureRect, effect_layer: Control, status_key: String) -> void:
	if target_sprite == null or not is_instance_valid(target_sprite) or effect_layer == null or not is_instance_valid(effect_layer):
		return
	var color: Color = STATUS_COLORS.get(status_key, Color(0.8, 0.8, 0.8))
	var original_modulate := target_sprite.modulate
	var flash := target_sprite.create_tween()
	for i in range(2):
		flash.tween_property(target_sprite, "modulate", color, 0.16)
		flash.tween_property(target_sprite, "modulate", original_modulate, 0.16)

	var glyph_text: String = STATUS_GLYPHS.get(status_key, "?")
	var glyph := Label.new()
	glyph.name = "StatusGlyph"
	glyph.text = glyph_text
	glyph.add_theme_font_size_override("font_size", 16)
	glyph.add_theme_color_override("font_color", color)
	glyph.size = Vector2(56, 26)
	glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glyph.position = _sprite_center(target_sprite) - Vector2(28, target_sprite.size.y * 0.5 + 30)
	glyph.modulate.a = 0.0
	effect_layer.add_child(glyph)
	var tween := glyph.create_tween()
	tween.tween_property(glyph, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(glyph, "position", glyph.position + Vector2(0, -14), 0.9).set_trans(Tween.TRANS_SINE)
	tween.tween_property(glyph, "modulate:a", 0.0, 0.35)
	tween.tween_callback(glyph.queue_free)


# A Pokemon heals (potions, drain moves, ...): soft green motes rise past
# the sprite while it flashes green, shared by every healing source.
static func play_heal_glow(target_sprite: TextureRect, effect_layer: Control) -> void:
	if target_sprite == null or not is_instance_valid(target_sprite) or effect_layer == null or not is_instance_valid(effect_layer):
		return
	AudioManager.play_sfx("heal")
	var color := Color(0.35, 0.9, 0.45)
	var original_modulate := target_sprite.modulate
	var flash := target_sprite.create_tween()
	flash.tween_property(target_sprite, "modulate", color.lerp(original_modulate, 0.35), 0.2)
	flash.tween_property(target_sprite, "modulate", original_modulate, 0.45)

	var base := _sprite_center(target_sprite)
	for i in range(4):
		var mote := ColorRect.new()
		mote.name = "HealMote%d" % i
		mote.color = color
		mote.size = Vector2(6, 6)
		mote.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mote.position = base + Vector2(randf_range(-30, 30), randf_range(-10, 20))
		mote.modulate.a = 0.0
		effect_layer.add_child(mote)
		var tween := mote.create_tween()
		tween.tween_interval(randf_range(0.0, 0.2))
		tween.tween_property(mote, "modulate:a", 0.9, 0.15)
		tween.parallel().tween_property(mote, "position", mote.position + Vector2(0, -46), 0.8).set_trans(Tween.TRANS_SINE)
		tween.tween_property(mote, "modulate:a", 0.0, 0.3)
		tween.tween_callback(mote.queue_free)


# A team switch (voluntary or forced): the outgoing sprite slides down and
# fades out ("recalled") while the incoming one slides up into place and
# fades in ("sent out") - species/variant-agnostic since it only ever
# touches the two sprite nodes handed to it.
static func play_switch_transition(old_sprite: TextureRect, new_sprite: TextureRect) -> void:
	if old_sprite != null and is_instance_valid(old_sprite):
		var old_tween := old_sprite.create_tween()
		old_tween.set_parallel(true)
		old_tween.tween_property(old_sprite, "position:y", old_sprite.position.y + 24, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		old_tween.tween_property(old_sprite, "modulate:a", 0.0, 0.4)
		old_tween.set_parallel(false)
		old_tween.tween_callback(old_sprite.queue_free)

	if new_sprite != null and is_instance_valid(new_sprite):
		var original_pos := new_sprite.position
		new_sprite.position.y += 24
		new_sprite.modulate.a = 0.0
		var new_tween := new_sprite.create_tween()
		new_tween.tween_interval(0.25)
		new_tween.set_parallel(true)
		new_tween.tween_property(new_sprite, "position", original_pos, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		new_tween.tween_property(new_sprite, "modulate:a", 1.0, 0.45)


static func _make_ring(center: Vector2, color: Color) -> Control:
	var ring := Control.new()
	ring.name = "Ring"
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.size = Vector2(48, 48)
	ring.pivot_offset = ring.size * 0.5
	ring.position = center - ring.size * 0.5

	var box := StyleBoxFlat.new()
	box.bg_color = Color(color.r, color.g, color.b, 0.0)
	box.border_color = color
	box.set_border_width_all(3)
	box.set_corner_radius_all(24)
	var panel := Panel.new()
	panel.size = ring.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", box)
	ring.add_child(panel)
	return ring
