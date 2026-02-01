class_name YankIndicator
extends Node2D


@export var click_detector: Button
@export var animation_player: AnimationPlayer
@export var scale_animation_player: AnimationPlayer
@export var strength_indicator: StrengthIndicator
@export var click_player: AudioStreamPlayer


signal success()
signal fail()


var _bar_visibility_tween: Tween = null


func _ready() -> void:
	click_detector.disabled = true
	if !Engine.is_editor_hint():
		strength_indicator.modulate.a = 0.0
	animation_player.play("release")
	scale_animation_player.play("off")


func start_detecting_click() -> void:
	click_detector.disabled = false
	animation_player.play("default")
	scale_animation_player.play("default")


func stop_detecting_click() -> void:
	click_detector.disabled = true


func _on_click_detector_button_down() -> void:
	animation_player.play("hold")
	scale_animation_player.play("off")
	
	click_player.play()
	
	if _bar_visibility_tween != null:
		_bar_visibility_tween.kill()
	_bar_visibility_tween = create_tween()
	
	strength_indicator.randomize_safe_area_with_size(100.0)
	strength_indicator.reset_arrow_pos()
	_bar_visibility_tween.tween_property(strength_indicator, "modulate:a", 1.0, 0.3)
	await _bar_visibility_tween.finished
	strength_indicator.start_measuring_strength()


func _on_click_detector_button_up() -> void:
	
	if _bar_visibility_tween != null:
		_bar_visibility_tween.kill()
	
	animation_player.play("release")
	scale_animation_player.play("off")
	strength_indicator.measure_current_strength()


func _on_strength_indicator_failed() -> void:
	fail.emit()
	if _bar_visibility_tween != null:
		_bar_visibility_tween.kill()
	_bar_visibility_tween = create_tween()
	_bar_visibility_tween.tween_interval(0.7)
	_bar_visibility_tween.tween_property(strength_indicator, "modulate:a", 0.0, 0.3)


func _on_strength_indicator_success() -> void:
	success.emit()
	_bar_visibility_tween = create_tween()
	_bar_visibility_tween.tween_interval(0.7)
	_bar_visibility_tween.tween_property(strength_indicator, "modulate:a", 0.0, 0.3)
