class_name Mask
extends Node2D


@export var shadow_texture_rect: TextureRect
@export var mask_texture: TextureRect


var draggable := true


var _dragging := false
var _initial_drag_position := Vector2.ZERO
var _initial_drag_self_pos := Vector2.ZERO


var _size_tween : Tween = null
var _mask_initial_position := Vector2.ZERO


signal dropped()


func _ready() -> void:
	_mask_initial_position = shadow_texture_rect.position


func _physics_process(_delta: float) -> void:
	_process_drag()


func _process_drag() -> void:
	if !draggable:
		return
	if _dragging:
		var _movement_vector := get_global_mouse_position() - _initial_drag_position
		global_position = _initial_drag_self_pos + _movement_vector


func _start_drag_mode() -> void:
	if draggable:
		_dragging = true
		modulate.a = 1.0
		_initial_drag_position = get_global_mouse_position()
		_initial_drag_self_pos = global_position
		if _size_tween != null:
			_size_tween.kill()
		_size_tween = create_tween()
		_size_tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.07).from(Vector2.ONE * 0.8)
		_size_tween.parallel().tween_property(shadow_texture_rect, "scale", Vector2.ONE * 1.04, 0.07)
		_size_tween.parallel()\
				.tween_property(mask_texture, "scale", Vector2.ONE * 1.02, 0.07)


func _stop_drag_mode() -> void:
	if draggable:
		_dragging = false
		_initial_drag_position = Vector2.ZERO
		_initial_drag_self_pos = Vector2.ZERO
		dropped.emit()


func _on_mask_sprite_gui_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton and
		(event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and
		event.is_pressed()
	):
		_start_drag_mode()
	
	if (
		event is InputEventMouseButton and
		(event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and
		!event.is_pressed()
	):
		_stop_drag_mode()
