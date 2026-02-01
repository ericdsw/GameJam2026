@tool
class_name StrengthIndicator
extends Node2D


@export var width := 20.0:
	set(new_val):
		width = new_val
		_sync_sizes.call_deferred()
@export var height := 200.0:
	set(new_val):
		height = new_val
		_sync_sizes.call_deferred()

@export var min_safe_zone := 150.0:
	set(new_val):
		min_safe_zone = new_val
		_sync_sizes.call_deferred()
@export var max_safe_zone := 180.0:
	set(new_val):
		max_safe_zone = new_val
		_sync_sizes.call_deferred()

@export var possible_position_curves: Array[CurveTexture]

@export_tool_button("Try to measure strength", "Callable") var measure = start_measuring_strength
@export_tool_button("Try to stop", "Callable") var measure_cur = measure_current_strength
@export_tool_button("Try to randomize_safe_area") var random_safe_area = func(): randomize_safe_area_with_size(60.0)

@export_group("Node References")
@export var background: NinePatchRect
@export var success_area: NinePatchRect
@export var arrow: TextureRect


var _bottom_arrow_pos := Vector2.ZERO
var _top_arrow_pos := Vector2.ZERO
var _arrow_enter_tween: Tween = null
var _used_curve_texture: CurveTexture
var _moving_arrow := false
var _cur_movement_lifetime := 0.0
var _max_movement_lifetime := 1.0


signal success()
signal failed()


func _ready() -> void:
	_sync_sizes()
	if Engine.is_editor_hint():
		arrow.modulate.a = 1.0
	else:
		arrow.modulate.a = 0.0


func randomize_safe_area_with_size(safe_area_size: float) -> void:
	min_safe_zone = randf_range(height / 2.0, height - safe_area_size)
	max_safe_zone = min_safe_zone + safe_area_size


func _process(delta: float) -> void:
	if _moving_arrow:
		var _movement_percent := _cur_movement_lifetime / _max_movement_lifetime
		var _progress : float = _used_curve_texture.curve.sample_baked(_movement_percent)
		arrow.position = _bottom_arrow_pos + Vector2.UP * (_bottom_arrow_pos.distance_to(_top_arrow_pos)) * _progress
		_cur_movement_lifetime += delta
		if _cur_movement_lifetime >= _max_movement_lifetime:
			_moving_arrow = false
			failed.emit()


func reset_arrow_pos() -> void:
	arrow.position = _bottom_arrow_pos


func start_measuring_strength() -> void:
	
	arrow.position = _bottom_arrow_pos

	if _arrow_enter_tween != null:
		_arrow_enter_tween.kill()
	_arrow_enter_tween = create_tween()
	_arrow_enter_tween.tween_property(arrow, "modulate:a", 1.0, 0.2)
	_arrow_enter_tween.tween_interval(0.2)
	await _arrow_enter_tween.finished

	_moving_arrow = true
	_cur_movement_lifetime = 0.0
	_max_movement_lifetime = randf_range(0.7, 1.5)
	_used_curve_texture = possible_position_curves.pick_random()


func measure_current_strength() -> void:
	_moving_arrow = false
	var _result := _bottom_arrow_pos.y - arrow.position.y

	if _result >= min_safe_zone and _result <= max_safe_zone:
		success.emit()
	else:
		failed.emit()


func _sync_sizes() -> void:

	background.position = Vector2(-width / 2.0, -height)
	background.size = Vector2(width, height + 10.0)
	success_area.position = Vector2(-width / 2.0 - 5.0, -max_safe_zone)
	success_area.size = Vector2(width + 10.0, max_safe_zone - min_safe_zone)

	_bottom_arrow_pos = Vector2.RIGHT * (width / 2.0 + 10.0) - arrow.size / 2.0
	_top_arrow_pos = _bottom_arrow_pos + Vector2.UP * height

	if Engine.is_editor_hint():
		arrow.position = _bottom_arrow_pos
