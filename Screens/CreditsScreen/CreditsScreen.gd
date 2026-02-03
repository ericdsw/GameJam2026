## Screen that contains the game's credits.
class_name CreditsScreen
extends BaseScreen


## Path to the main menu screen
@export_file("*.tscn") var main_menu_screen_path: String


# ================================ Callbacks ================================ #


func _on_back_button_pressed() -> void:
	navigate_to_screen.emit(load(main_menu_screen_path))
