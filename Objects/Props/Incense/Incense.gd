## Prop that animates a series of smoke nodes.
@tool
class_name Incense
extends Sprite2D


############### Exported properties

@export var smokes : Array[Smoke]
@export var regular_smoke_color := Color.WHITE
@export var mystical_smoke_color := Color.WHITE
@export var mystical := false:
	set(new_val):
		mystical = new_val
		if mystical:
			make_mystical(1.0)
		else:
			make_normal(1.0)


############### Private variables

var _color_swap_tween : Tween = null


# ================================ Lifecycle ================================ #


func _ready() -> void:
	if mystical:
		make_mystical(0.0)
	else:
		make_normal(0.0)


# ================================= Public ================================== #


func make_normal(duration := 0.0) -> void:
	if _color_swap_tween != null:
		_color_swap_tween.kill()
	_color_swap_tween = create_tween()
	_color_swap_tween.tween_interval(duration)
	for smoke in smokes:
		_color_swap_tween.parallel()\
				.tween_property(smoke, "smoke_color", regular_smoke_color, duration)
	_color_swap_tween.parallel().tween_property(self, "self_modulate", Color.WHITE, duration)


func make_mystical(duration := 0.0) -> void:
	if _color_swap_tween != null:
		_color_swap_tween.kill()
	_color_swap_tween = create_tween()
	_color_swap_tween.tween_interval(duration)
	for smoke in smokes:
		_color_swap_tween.parallel()\
				.tween_property(smoke, "smoke_color", mystical_smoke_color, duration)
	_color_swap_tween.parallel().tween_property(self, "self_modulate", mystical_smoke_color, duration)
