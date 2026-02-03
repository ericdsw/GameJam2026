## Node that shows the "chosen one"'s face
class_name TargetPreview
extends Node2D


############### Exported properties

@export_group("Node References")
@export var face: Face


############### Signals

signal mouse_focused()
signal mouse_unfocused()


# ================================= Public ================================== #


func apply_face_randomizer_result(result: FaceRandomizer.FaceRandomizerResult) -> void:
	face.apply_face_randomizer_result(result)


# ================================ Callbacks ================================ #


func _on_nine_patch_rect_mouse_entered() -> void:
	mouse_focused.emit()


func _on_nine_patch_rect_mouse_exited() -> void:
	mouse_unfocused.emit()
