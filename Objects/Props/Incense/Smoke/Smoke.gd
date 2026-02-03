## Individual smoke clouds placed on top of the incense node.
@tool
class_name Smoke
extends Node2D


############### Exported properties

@export var smoke_sprite: Sprite2D
@export var apparent_motion_raycast: RayCast2D
@export var smoke_color := Color.WHITE:
	set(new_val):
		smoke_color = new_val
		_sync_smoke_color.call_deferred()
@export var animate_in_editor := false:
	set(new_val):
		animate_in_editor = new_val
		_sync_animate_in_editor.call_deferred()


############### Private variables

var _visibility_tween : Tween = null
var _initial_position := Vector2.ZERO


# ================================ Lifecycle ================================ #

func _ready() -> void:

	_sync_smoke_color()

	smoke_sprite.self_modulate.a = 0.0
	_initial_position = Vector2.ZERO
	if !Engine.is_editor_hint() or animate_in_editor:
		_start()
	else:
		if _visibility_tween != null:
			_visibility_tween.kill()
		smoke_sprite.self_modulate.a = 1.0
		smoke_sprite.position = _initial_position


# ================================= Private ================================= #


func _sync_animate_in_editor() -> void:
	if animate_in_editor and Engine.is_editor_hint():
		_start()
	else:
		if _visibility_tween != null:
			_visibility_tween.kill()
		smoke_sprite.self_modulate.a = 1.0
		smoke_sprite.position = _initial_position


func _start() -> void:
	await create_tween().tween_interval(randf_range(0.0, 0.5)).finished
	_phase_in_out()


func _sync_smoke_color() -> void:
	smoke_sprite.modulate = smoke_color


func _phase_in_out() -> void:

	if _visibility_tween != null:
		_visibility_tween.kill()
	
	smoke_sprite.position = _initial_position
	reset_physics_interpolation()
	
	var _random_duration := randf_range(0.9, 2.0)
	var _max_modulate := randf_range(0.5, 1.0)
	var _stay_duration := randf_range(0.3, 0.8)
	var _hidden_duration := randf_range(0.2, 0.6)

	var _movement_duration := _random_duration * 2.0 + _stay_duration
	var _motion := apparent_motion_raycast.target_position.normalized().rotated(randf_range(-PI / 8.0, PI / 8.0))
	var _final_pos : Vector2 = smoke_sprite.position + _motion * randf_range(12.0, 24.0)
	
	_visibility_tween = create_tween()
	_visibility_tween.set_loops()
	
	_visibility_tween.tween_property(smoke_sprite, "self_modulate:a", _max_modulate, _random_duration)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)
	_visibility_tween.parallel()\
			.tween_property(smoke_sprite, "position", _final_pos, _movement_duration)\
			.from(_initial_position)
	_visibility_tween.parallel().tween_property(smoke_sprite, "self_modulate:a", 0.0, _random_duration)\
			.set_delay(_random_duration + _stay_duration)
	_visibility_tween.parallel().tween_interval(_hidden_duration + _random_duration + _stay_duration)
