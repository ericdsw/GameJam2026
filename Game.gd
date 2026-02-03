## The root node for the game, has the following functionalities:
## - Provies an entry point for the game, automatically loading the first screen
## - Provides a global API to manage the background music (this logic needs to be done
##   in a node that won't be removed from the tree at any point of the game's lifecycle,
##   as that would cause the song to be abruptly interrupted)
## - Provides a navigation API to change between screens.
##
## Both of these functionalities are called by the screen components via signals, 
class_name Game
extends Node


############### Exported properties

## Scene of the first screen that the game will load.
@export var main_screen_scene: PackedScene
## Scene of the transition cover that will be used when navigating between screens.
@export var transition_cover_scene: PackedScene
@export_group("Node Properties")   # <-- @export_group is just a utility that groups exported variables under a title in the inspector panel.
@export var audio_stream_player: AudioStreamPlayer


############### Private variables

var _current_screen: BaseScreen
var _cur_cover: TransitionCover
var _music_transition_tween : Tween = null


# ================================ Lifecycle ================================ #


func _ready() -> void:
	_go_to_screen(main_screen_scene, false)


# ================================= Private ================================= #


## Start the screen swapping logic, can be used both with transition for regular swaps) or
## without (used when the game first loads).
func _go_to_screen(screen_resource: PackedScene, with_transition := true) -> void:
	if !with_transition:
		_perform_swap(screen_resource)
	else:
		var _cover := transition_cover_scene.instantiate() as TransitionCover
		_cover.peaked.connect(_on_cover_peaked.bind(screen_resource))
		_cover.transition_finished.connect(_on_transition_finished)
		add_child(_cover)
		_cur_cover = _cover


func _perform_swap(screen_resource: PackedScene, fast := false) -> void:

	## Step 1: delete the previous screen
	_delete_previous_screen()

	## Step 2: Instantiate the new screen and connect the appropiate signals
	var _new_screen := screen_resource.instantiate() as BaseScreen
	_new_screen.navigate_to_screen.connect(_on_navigate_to_screen)
	_new_screen.update_bgm.connect(_on_update_bgm)

	## Step 3: Add the new screen to the tree
	add_child(_new_screen)

	## Step 4: Keep a reference to the screen, will be used to free it later.
	_current_screen = _new_screen

	## Step 5: Replicate the final state after the TransitionCover disappears,
	## but only if it was skipped.
	if fast:
		_current_screen.screen_is_ready = true
		_current_screen.navigation_finished()


## Disconnects any existing singal from the active screen before destroying it.
func _delete_previous_screen() -> void:
	if _current_screen != null and is_instance_valid(_current_screen):
		if _current_screen.navigate_to_screen.is_connected(_on_navigate_to_screen):
			_current_screen.navigate_to_screen.disconnect(_on_navigate_to_screen)
		if _current_screen.update_bgm.is_connected(_on_update_bgm):
			_current_screen.update_bgm.disconnect(_on_update_bgm)
		_current_screen.queue_free()


# ================================ Callbacks ================================ #


## Callback invoked by the "navigate_to_screen" signal of the active BaseScreen.
func _on_navigate_to_screen(screen_resource: PackedScene) -> void:
	_go_to_screen(screen_resource)


## Callback invoked by the TransitionCover's "peaked" signal, which happens when the screen
## is fully black.
## Note: TransitionCover is a utility node used to briefly cover the screen when swapping screens.
func _on_cover_peaked(new_screen_scene: PackedScene) -> void:
	_perform_swap(new_screen_scene)


## Callback invoked by the TransitionCover's "transition_finished" signal, which happens after the cover
## fully disappears (The new screen should already be loaded).
func _on_transition_finished() -> void:
	_current_screen.screen_is_ready = true
	_current_screen.navigation_finished()
	_cur_cover.queue_free()


## Callback invoked by the "update_bgm" signal of the active BaseScreen.
func _on_update_bgm(
	bgm_path: String,
	fade_duration: float,
	silence_duration: float,
	fade_in_duration: float
) -> void:

	## Try to skip the bgm update logic if the new song is the same as the current one
	if audio_stream_player.stream != null:
		if audio_stream_player.stream.resource_path == bgm_path:
			return
	
	if _music_transition_tween != null:
		_music_transition_tween.kill()

	_music_transition_tween = create_tween()

	## Step 1: lower the current bgm volume, -80db should be inaudible enough
	_music_transition_tween.tween_property(audio_stream_player, "volume_db", -80.0, fade_duration)
	
	## Step 2: After the fade out, load the new bgm song (or stop the bgm player, if the new path
	## is an empty string)
	_music_transition_tween.tween_callback(func():
		if bgm_path != "":
			audio_stream_player.stream = load(bgm_path)
			audio_stream_player.play()
		else:
			audio_stream_player.stop()
	)
	
	## Step 3: Wait the silence duration
	_music_transition_tween.tween_interval(silence_duration)
	
	## Step 4: Fade in the volume with the new song playing.
	_music_transition_tween.tween_property(audio_stream_player, "volume_db", 0.0, fade_in_duration)
