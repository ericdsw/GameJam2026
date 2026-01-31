class_name Mask
extends Node2D


@export var shadow_texture_rect: TextureRect
@export var mask_texture_button: TextureButton


var draggable := false


var _dragging := false
var _initial_drag_position := Vector2.ZERO
var _initial_drag_self_pos := Vector2.ZERO


var _size_tween : Tween = null
var _mask_initial_position := Vector2.ZERO


signal dropped()


func _ready() -> void:
	_mask_initial_position = shadow_texture_rect.position


func _process(_delta: float) -> void:
	if _dragging:
		var _movement_vector := get_global_mouse_position() - _initial_drag_position
		global_position = _initial_drag_self_pos + _movement_vector


func _on_sprite_2d_button_down() -> void:
	if draggable:
		_dragging = true
		_initial_drag_position = get_global_mouse_position()
		_initial_drag_self_pos = global_position
		if _size_tween != null:
			_size_tween.kill()
		_size_tween = create_tween()
		_size_tween.tween_property(shadow_texture_rect, "scale", Vector2.ONE * 1.1, 0.1)
		_size_tween.parallel()\
				.tween_property(mask_texture_button, "scale", Vector2.ONE * 1.05, 0.1)
		_size_tween.parallel()\
				.tween_property(mask_texture_button, "position", _mask_initial_position + Vector2.ONE * 10, 0.1)


func _on_sprite_2d_button_up() -> void:
	if draggable:
		_dragging = false
		_initial_drag_position = Vector2.ZERO
		_initial_drag_self_pos = Vector2.ZERO
		if _size_tween != null:
			_size_tween.kill()
		_size_tween = create_tween()
		_size_tween.tween_property(shadow_texture_rect, "scale", Vector2.ONE, 0.1)
		_size_tween.parallel()\
				.tween_property(mask_texture_button, "scale", Vector2.ONE, 0.1)
		_size_tween.tween_callback(func(): dropped.emit())
		_size_tween.parallel()\
				.tween_property(mask_texture_button, "position", _mask_initial_position, 0.1)
