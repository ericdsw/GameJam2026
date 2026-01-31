class_name Game
extends Node


@export var main_screen_scene: PackedScene


var _current_screen: BaseScreen


func _ready() -> void:
	_go_to_screen(main_screen_scene)


func _go_to_screen(screen_resource: PackedScene) -> void:
	_delete_previous_screen()
	var _new_screen := screen_resource.instantiate() as BaseScreen
	_new_screen.navigate_to_screen.connect(_on_navigate_to_screen)
	add_child(_new_screen)
	_current_screen = _new_screen


func _delete_previous_screen() -> void:
	if _current_screen != null and is_instance_valid(_current_screen):
		if _current_screen.navigate_to_screen.is_connected(_on_navigate_to_screen):
			_current_screen.navigate_to_screen.disconnect(_on_navigate_to_screen)
		_current_screen.queue_free()


func _on_navigate_to_screen(screen_resource: PackedScene) -> void:
	_go_to_screen(screen_resource)
