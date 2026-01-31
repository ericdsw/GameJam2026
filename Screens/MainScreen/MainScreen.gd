class_name MainScreen
extends BaseScreen


func _on_button_pressed() -> void:
	navigate_to_screen.emit("face_screen")
