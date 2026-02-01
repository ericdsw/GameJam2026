class_name Game
extends Node


@export var main_screen_scene: PackedScene
@export var transition_cover_scene: PackedScene


var _current_screen: BaseScreen
var _cur_cover: TransitionCover


func _ready() -> void:
	_go_to_screen(main_screen_scene, false)


func _go_to_screen(screen_resource: PackedScene, with_transition := true) -> void:
	if !with_transition:
		_delete_previous_screen()
		var _new_screen := screen_resource.instantiate() as BaseScreen
		_new_screen.navigate_to_screen.connect(_on_navigate_to_screen)
		add_child(_new_screen)
		_current_screen = _new_screen
	else:
		var _cover := transition_cover_scene.instantiate() as TransitionCover
		_cover.peaked.connect(_on_cover_peaked.bind(screen_resource))
		_cover.transition_finished.connect(_on_transition_finished)
		
		get_tree().get_root().add_child(_cover)
		_cur_cover = _cover


func _perform_swap(screen_resource: PackedScene) -> void:
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


func _on_cover_peaked(new_screen_scene: PackedScene) -> void:
	_perform_swap(new_screen_scene)


func _on_transition_finished() -> void:
	_current_screen.screen_is_ready = true
	_current_screen.navigation_finished()
	_cur_cover.queue_free()
