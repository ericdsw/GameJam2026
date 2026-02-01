class_name FinalScreen
extends BaseScreen


@export var color_cover: ColorRect
@export var tbc_label: Label
@export_file("*.wav") var bgm_path := ""
@export_file("*.tscn") var main_screen_path: String


var _finished := false
var _started_navigation := false


func _ready() -> void:
	color_cover.modulate.a = 1.0
	tbc_label.modulate.a = 0.0


func _input(event: InputEvent) -> void:
	if _finished and !_started_navigation:
		if (
			event is InputEventMouseButton or
			event is InputEventKey
		) and event.is_pressed() and !event.is_echo():
			_started_navigation = true
			navigate_to_screen.emit(load(main_screen_path))


func navigation_finished() -> void:
	var _tween := create_tween()
	_tween.tween_property(color_cover, "modulate:a", 0.0, 4.0)
	_tween.parallel().tween_callback(func(): update_bgm.emit(bgm_path, 0.0, 0.0, 0.5))\
			.set_delay(1.0)
	_tween.tween_property(tbc_label, "modulate:a", 1.0, 1.0)
	await _tween.finished
	_finished = true
