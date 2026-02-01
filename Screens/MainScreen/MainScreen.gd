class_name MainScreen
extends BaseScreen


@export var buttons: Array[MainMenuButton]
@export_file("*.wav") var bgm_path := ""


var _active_button: MainMenuButton


func _ready() -> void:
	for button in buttons:
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.gui_input.connect(_on_button_gui_input.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
	update_bgm.emit(bgm_path, 0.3, 0.0, 0.3)


func _on_button_mouse_entered(which_button: MainMenuButton) -> void:
	if which_button != _active_button:
		_active_button = which_button
		for button in buttons:
			button.active = button == _active_button


func _on_button_mouse_exited(which_button: MainMenuButton) -> void:
	if _active_button == which_button:
		_active_button = null
		for button in buttons:
			button.active = false


func _on_button_gui_input(input_event: InputEvent, which_button: MainMenuButton) -> void:
	if input_event is InputEventMouseButton:
		if input_event.button_index == MOUSE_BUTTON_LEFT and input_event.is_pressed():
			if which_button.name == "QuitGame":
				get_tree().quit()
			else:
				navigate_to_screen.emit(load(which_button.screen_scene_path))
