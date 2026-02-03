class_name TransitionCover
extends Control


############### Exported properties

@export var cover: ColorRect


############### Private variables

var _transition_tween: Tween = null


############### Signals

signal peaked()
signal transition_finished()


# ================================ Lifecycle ================================ #


func _ready() -> void:
	_transition_tween = create_tween()
	_transition_tween\
			.tween_method(_apply_shader_cutoff, 0.0, 1.0, 0.3)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
	_transition_tween.tween_interval(0.2)
	_transition_tween.tween_callback(func(): peaked.emit())
	_transition_tween.tween_method(_apply_shader_cutoff, 1.0, 0.0, 0.3)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)
	_transition_tween.tween_callback(func(): transition_finished.emit())


# ================================= Private ================================= #


func _apply_shader_cutoff(new_val: float) -> void:
	cover.material.set_shader_parameter("cutoff", new_val)
