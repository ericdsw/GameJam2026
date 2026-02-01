class_name GameOverScreen
extends BaseScreen


@export_file("*.tscn") var main_menu_screen_path := ""
@export_file("*.tscn") var face_screen_path := ""


func _on_try_again_pressed() -> void:
	navigate_to_screen.emit(load(face_screen_path))


func _on_quit_pressed() -> void:
	navigate_to_screen.emit(load(main_menu_screen_path))
