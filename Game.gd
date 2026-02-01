class_name Game
extends Node


@export var main_screen_scene: PackedScene
@export var transition_cover_scene: PackedScene
@export var audio_stream_player: AudioStreamPlayer


var _current_screen: BaseScreen
var _cur_cover: TransitionCover
var _music_transition_tween : Tween = null


func _ready() -> void:
	_go_to_screen(main_screen_scene, false)


func _go_to_screen(screen_resource: PackedScene, with_transition := true) -> void:
	if !with_transition:
		_delete_previous_screen()
		var _new_screen := screen_resource.instantiate() as BaseScreen
		_new_screen.navigate_to_screen.connect(_on_navigate_to_screen)
		_new_screen.update_bgm.connect(_on_update_bgm)
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
	_new_screen.update_bgm.connect(_on_update_bgm)
	add_child(_new_screen)
	_current_screen = _new_screen


func _delete_previous_screen() -> void:
	if _current_screen != null and is_instance_valid(_current_screen):
		if _current_screen.navigate_to_screen.is_connected(_on_navigate_to_screen):
			_current_screen.navigate_to_screen.disconnect(_on_navigate_to_screen)
		if _current_screen.update_bgm.is_connected(_on_update_bgm):
			_current_screen.update_bgm.disconnect(_on_update_bgm)
		_current_screen.queue_free()


func _on_navigate_to_screen(screen_resource: PackedScene) -> void:
	_go_to_screen(screen_resource)


func _on_cover_peaked(new_screen_scene: PackedScene) -> void:
	_perform_swap(new_screen_scene)


func _on_transition_finished() -> void:
	_current_screen.screen_is_ready = true
	_current_screen.navigation_finished()
	_cur_cover.queue_free()


func _on_update_bgm(
	bgm_path: String,
	fade_duration: float,
	silence_duration: float,
	fade_in_duration: float
) -> void:

	if audio_stream_player.stream != null:
		if audio_stream_player.stream.resource_path == bgm_path:
			return
	
	if _music_transition_tween != null:
		_music_transition_tween.kill()

	_music_transition_tween = create_tween()
	_music_transition_tween.tween_property(audio_stream_player, "volume_db", -80.0, fade_duration)
	_music_transition_tween.tween_callback(func():
		if bgm_path != "":
			audio_stream_player.stream = load(bgm_path)
			audio_stream_player.play()
		else:
			audio_stream_player.stop()
	)
	_music_transition_tween.tween_interval(silence_duration)
	_music_transition_tween.tween_property(audio_stream_player, "volume_db", 0.0, fade_in_duration)
