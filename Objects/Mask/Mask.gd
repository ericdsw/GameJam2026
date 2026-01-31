class_name Mask
extends Node2D


var _dragging := false
var _initial_drag_position := Vector2.ZERO
var _initial_drag_self_pos := Vector2.ZERO


func _on_sprite_2d_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !_dragging and event.is_pressed():
			_dragging = true
			_initial_drag_position = get_global_mouse_position()
			_initial_drag_self_pos = global_position
		elif event.button_index == MOUSE_BUTTON_LEFT and _dragging and !event.is_pressed():
			_dragging = false
	elif event is InputEventMouseMotion:
		if _dragging:
			var _movement_vector := get_global_mouse_position() - _initial_drag_position
			global_position = _initial_drag_self_pos + _movement_vector


func _on_sprite_2d_button_down() -> void:
	_dragging = true
	_initial_drag_position = get_global_mouse_position()
	_initial_drag_self_pos = global_position


func _on_sprite_2d_button_up() -> void:
	_dragging = false
	_initial_drag_position = Vector2.ZERO
	_initial_drag_self_pos = Vector2.ZERO
