@tool
class_name MainMenuButton
extends Control


@export var button_text: String:
	set(new_val):
		button_text = new_val
		_sync_text.call_deferred()
@export var inactive_color: Color:
	set(new_val):
		inactive_color = new_val
		_sync_colors.call_deferred()
@export var active_color: Color:
	set(new_val):
		active_color = new_val
		_sync_colors.call_deferred()
@export var active := false:
	set(new_val):
		active = new_val
		_sync_colors.call_deferred(0.2)
@export var right_selection_offset := 0.0:
	set(new_val):
		right_selection_offset = new_val
		_sync_right_selection_offset.call_deferred()
@export_file("*.tscn") var screen_scene_path := ""
@export var selection_rect: TextureRect
@export var button_label: Label


var _animation_tween : Tween = null


func _ready() -> void:
	selection_rect.modulate = inactive_color
	_sync_text()
	_sync_colors(0.0)
	_sync_right_selection_offset()


func _sync_colors(animation_duration := 0.0) -> void:
	
	if _animation_tween != null:
		_animation_tween.kill()
	
	var _original_color := button_label.get_theme_color("font_color")
	var _target_color := active_color if active else inactive_color
	var _selection_modulate := 1.0 if active else 0.0

	if animation_duration <= 0.0:
		_apply_text_color(_target_color)
		selection_rect.modulate.a = _selection_modulate
	else:
		_animation_tween = create_tween()
		_animation_tween.tween_method(_apply_text_color, _original_color, _target_color, animation_duration)
		_animation_tween.parallel()\
				.tween_property(selection_rect, "modulate:a", _selection_modulate, animation_duration)\
				.from(selection_rect.modulate.a)
	

func _sync_right_selection_offset() -> void:
	var _diff_x : float = size.x - selection_rect.size.x
	selection_rect.position.x = _diff_x + right_selection_offset


func _sync_text() -> void:
	button_label.text = button_text


func _apply_text_color(new_color: Color) -> void:
	button_label.add_theme_color_override("font_color", new_color)
