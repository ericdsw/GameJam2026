class_name TargetPreview
extends Node2D


@export var face: Face


signal mouse_focused()
signal mouse_unfocused()


func apply_face_randomizer_result(result: FaceRandomizer.FaceRandomizerResult) -> void:
	face.apply_face_randomizer_result(result)


func _on_nine_patch_rect_mouse_entered() -> void:
	mouse_focused.emit()


func _on_nine_patch_rect_mouse_exited() -> void:
	mouse_unfocused.emit()
