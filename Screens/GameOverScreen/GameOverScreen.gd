## The screen that will be shown after the player's health reaches 0.
class_name GameOverScreen
extends BaseScreen


############### Exported properties

## Note: I'm referencing these two scenes as strings and using the `load` method when
## navigating to them, since defining an exported PackedScene will also load their
## their exported PackedScenes, and the way the navigation is laid out can cause this
## to start a circular dependency load loop.

## Main screen scene path.
@export_file("*.tscn") var main_menu_screen_path := ""

## Face screen path.
@export_file("*.tscn") var face_screen_path := ""


# ================================ Callbacks ================================ #


func _on_try_again_pressed() -> void:
	navigate_to_screen.emit(load(face_screen_path))


func _on_quit_pressed() -> void:
	navigate_to_screen.emit(load(main_menu_screen_path))
