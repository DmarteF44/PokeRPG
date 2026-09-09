class_name EvolutionAnimation
extends RefCounted

# Reusable evolution transformation sequence: preparation glow -> energy
# flash -> old sprite fades out -> new sprite scales/fades in -> settle.
# Species/generation/variant-agnostic: it only ever touches the two
# TextureRect nodes and the flash overlay handed to it, never Pokemon data,
# so it works unchanged for any current or future species - including
# Shiny/Black, whose recolor shader is already applied to the sprites by
# PokemonHelpers.add_animated_sprite before play() is called.

const PREP_PULSES := 4
const PREP_PULSE_DURATION := 0.42
const FLASH_DURATION := 0.32
const REVEAL_DURATION := 1.0

static func play(before_sprite: TextureRect, after_sprite: TextureRect, flash: ColorRect, on_done: Callable) -> void:
	before_sprite.pivot_offset = before_sprite.size / 2.0
	after_sprite.pivot_offset = after_sprite.size / 2.0
	after_sprite.modulate = Color(1, 1, 1, 0)
	after_sprite.scale = Vector2.ONE
	flash.modulate.a = 0.0

	var tween := before_sprite.create_tween()

	# Preparation: the pre-evolution sprite pulses brighter and bigger, as if
	# building up energy for the change.
	for i in range(PREP_PULSES):
		tween.tween_property(before_sprite, "scale", Vector2(1.12, 1.12), PREP_PULSE_DURATION).set_trans(Tween.TRANS_SINE)
		tween.parallel().tween_property(before_sprite, "modulate", Color(1.6, 1.6, 1.6, 1.0), PREP_PULSE_DURATION).set_trans(Tween.TRANS_SINE)
		tween.tween_property(before_sprite, "scale", Vector2.ONE, PREP_PULSE_DURATION).set_trans(Tween.TRANS_SINE)
		tween.parallel().tween_property(before_sprite, "modulate", Color(1, 1, 1, 1), PREP_PULSE_DURATION).set_trans(Tween.TRANS_SINE)

	# Transformation: a bright flash covers the panel while the old sprite
	# disappears and the new one takes its place underneath the flash.
	tween.tween_property(flash, "modulate:a", 1.0, FLASH_DURATION).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		before_sprite.modulate = Color(1, 1, 1, 0)
		after_sprite.modulate = Color(1, 1, 1, 1)
		after_sprite.scale = Vector2(0.5, 0.5)
		AudioManager.play_sfx("success")
	)
	tween.tween_property(flash, "modulate:a", 0.0, FLASH_DURATION).set_trans(Tween.TRANS_QUAD)

	# Reveal: the new sprite grows in with a small overshoot, then settles.
	tween.tween_property(after_sprite, "scale", Vector2(1.15, 1.15), REVEAL_DURATION * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(after_sprite, "scale", Vector2.ONE, REVEAL_DURATION * 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(on_done)
