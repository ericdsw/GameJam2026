## Starting screen for the game.
class_name MainScreen
extends BaseScreen


############### Exported properties

@export_file("*.wav") var bgm_path := ""
@export_group("Node References")
@export var buttons: Array[MainMenuButton]
@export var move_player: AudioStreamPlayer
@export var click_player: AudioStreamPlayer


############### Private variables

## Reference to the button the mouse is currently hoveing over.
var _active_button: MainMenuButton


# ================================ Lifecycle ================================ #


func _ready() -> void:
	
	## Here, I'm connecting some signals (which are defined in the Control node class) and
	## binding the corresponding button instance using the Callable.bind method.
	## - mouse_entered = the mouse entered the clickable area of the button
	## - mouse_exited = the mouse exited the clickable area of the button
	## - gui_input = the button detected some input from the player (detects ALL inputs, will be
	##   filtered in the corresponding method.)
	for button in buttons:
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.gui_input.connect(_on_button_gui_input.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
	
	## Update the BGM
	update_bgm.emit(bgm_path, 0.3, 0.0, 0.3)


# ================================ Callbacks ================================ #


## Called when the mouse hovers over a button
func _on_button_mouse_entered(which_button: MainMenuButton) -> void:
	if which_button != _active_button:
		_active_button = which_button
		for button in buttons:
			button.active = button == _active_button
		move_player.play()


## Called when no longer hovering over a button
func _on_button_mouse_exited(which_button: MainMenuButton) -> void:
	if _active_button == which_button:
		_active_button = null
		for button in buttons:
			button.active = false


## GUI input was detected, make sure that we can detect the left click by doing the following checks:
## - The event is an instance of InputEventMouseButton
## - The button_index matches MOUSE_BUTTON_LEFT
## - The event.is_pressed() returned true (will be false when the button is released)
func _on_button_gui_input(input_event: InputEvent, which_button: MainMenuButton) -> void:
	if input_event is InputEventMouseButton:
		if input_event.button_index == MOUSE_BUTTON_LEFT and input_event.is_pressed():
			click_player.play()
			if which_button.name == "QuitGame":
				## Since quit game has no screen, we need to treat it as a special case.
				get_tree().quit()
			else:
				navigate_to_screen.emit(load(which_button.screen_scene_path))
