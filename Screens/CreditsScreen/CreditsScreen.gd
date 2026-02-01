class_name CreditsScreen
extends BaseScreen


@export_file("*.tscn") var main_menu_screen_path: String


func _on_back_button_pressed() -> void:
	navigate_to_screen.emit(load(main_menu_screen_path))
