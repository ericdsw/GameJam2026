## Screen that will be shown after the player "wins" the game.
class_name FinalScreen
extends BaseScreen


############### Exported properties

## The BGM that will play.
@export_file("*.wav") var bgm_path := ""
## Path to the main screen
@export_file("*.tscn") var main_screen_path: String
@export_group("Node References")
@export var color_cover: ColorRect
@export var tbc_label: Label


############### Private variables

var _finished := false
var _started_navigation := false


# ================================ Lifecycle ================================ #


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


# ================================= Public ================================== #


func navigation_finished() -> void:

	var _tween := create_tween()
	_tween.tween_property(color_cover, "modulate:a", 0.0, 4.0)
	_tween.parallel().tween_callback(func(): update_bgm.emit(bgm_path, 0.0, 0.0, 0.5))\
			.set_delay(1.0)
	_tween.tween_property(tbc_label, "modulate:a", 1.0, 1.0)

	## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
	await _tween.finished

	_finished = true
