## Screen that contains the main gameplay loop.
class_name FaceScreen
extends BaseScreen


## Possible states the screen can be in.
enum States {
	BeforeStarting,      # <-- Game just started, the target face is being shown
	FaceEntering,        # <-- Face is sliding in.
	DraggingMask,        # <-- Mask object is instantiated and becomes draggable.
	EvaluatingMaskDrag,  # <-- Mask was just dropped, game determines whether it is a success or a fail
	Janking,             # <-- Player is removing the previously placed mask.
	NoHealth             # <-- Health reached 0.
}


############### Exported variables

## Reference to the mask scene
@export var mask_scene: PackedScene
## Minimum amount of faces the screen will show, the last one will be the "chosen one"
@export var min_face_amount := 4
## Maximum amount of faces the screen will show, the last one will be the "chosen one"
@export var max_face_amount := 7
## How much health the player has
@export var max_health := 6
## Color that the scren will be tinted under normal circumstances (white means no tint, since it is multiplicative).
@export var regular_canvas_modulate_color := Color.WHITE
## Color that the screen will be tinted when the "chosen one" is on the screen.
@export var mystical_canvas_modulate_color := Color.WHITE

## Game over screen path (fail condition)
@export_file("*.tscn") var game_over_screen_scene_path := ""
## Final screen path (win condition)
@export_file("*.tscn") var final_screen_scene_path := ""
## The BGM that will normally play on the screen
@export_file("*.wav") var bgm_path := ""
## The BGM that will play when the "chosen one" is shown.
@export_file("*.wav") var ominous_bgm_path := ""

@export_group("Node References")
@export var drop_region: DropRegion
@export var face: Face
@export var mask_start_position: Marker2D
@export var face_in_position: Marker2D
@export var face_out_position: Marker2D
@export var mask_on_face_pos: Marker2D
@export var out_of_bounds_target_preview_pos: Marker2D
@export var in_bounds_target_preview_pos: Marker2D
@export var screen_center_pos: Control
@export var face_randomizer: FaceRandomizer
@export var yank_indicator: YankIndicator
@export var health: Health
@export var target_preview: TargetPreview
@export var canvas_modulate: CanvasModulate
@export var ominous_overlay: TextureRect
@export var black_rip_color_cover_animation_player: AnimationPlayer
@export var heartbeat_player: AudioStreamPlayer
@export var drop_mask_player: AudioStreamPlayer
@export var error_player: AudioStreamPlayer
@export var drag_label: Label


############### Private variables

## Reference to the screen's current state. This works as a VERY basic state machine.
var _current_state := States.BeforeStarting
## Reference to the current mask that is being dropped on top of the active face.
var _current_mask: Mask
## Tween used to animate the face entering and exiting the screen.
var _face_slide_tween: Tween = null
## Tween used to animate the "target preview" card (shows who is the "chosen one")
var _target_preview_tween: Tween = null
## We preload a set of faces before starting the round, and this variable keeps track
## of which face we are currently displaying
var _current_face_offset := 0
## How much health the player has left. A "setter" method makes sure that the change is
## propagated to the health UI element.
var _current_health := 6:
	set(new_val):
		_current_health = new_val
		_sync_health()
## List of preloaded faces, calculated when the screen is added to the tree.
var _faces_to_show : Array[FaceRandomizer.FaceRandomizerResult] = []
## The face that will correspond to the "chosen one"
var _target_face : FaceRandomizer.FaceRandomizerResult = null


# ================================ Lifecycle ================================ #


func _ready() -> void:

	## First, define the set of faces that will be shown, and set the last one as the "chosen one"
	## since you either kill them and win, or fail enough times for your health to reach 0.
	_faces_to_show = face_randomizer.generate_random_face_set(randi_range(min_face_amount, max_face_amount))
	_target_face = _faces_to_show[_faces_to_show.size() - 1]

	## Configuer the UI to the initial state, which includes:
	## - Hiding the instructions label
	## - Making sure the health UI reflects the current health on screen load, before the setter is called.
	## - Hide the yank indicator
	## - Position the face outside the screen
	## - Initialize the target preview.
	drag_label.modulate.a = 0.0
	_current_health = max_health
	_sync_health()	

	yank_indicator.modulate.a = 0.0
	yank_indicator.success.connect(_on_jank_indicator_success)
	yank_indicator.fail.connect(_on_jank_indicator_failed)

	face.global_position = face_out_position.global_position
	face.mask_visible = false
	face.reset_physics_interpolation()

	target_preview.global_position = screen_center_pos.global_position + Vector2.DOWN * 10.0
	target_preview.scale = Vector2.ONE * 2.0
	target_preview.modulate.a = 0.0
	target_preview.apply_face_randomizer_result(_target_face)
	target_preview.reset_physics_interpolation()

	ominous_overlay.modulate.a = 0.0

	## Make sure we can show/hide the target preview when the mouse overs over it.
	target_preview.mouse_focused.connect(_on_target_preview_mouse_focused)
	target_preview.mouse_unfocused.connect(_on_target_preview_mouse_unfocused)


# ================================= Public ================================== #


# @Overwrite
# The TransitionCover finished navigating, start showing the face in the target_preview node.
func navigation_finished() -> void:

	## Wait 0.5 seconds before continuing the logic. More info on how this works on the Coroutines section
	## of the documentation:
	## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
	await create_tween().tween_interval(0.5).finished

	target_preview.global_position = screen_center_pos.global_position + Vector2.DOWN * 10.0

	if _target_preview_tween != null:
		_target_preview_tween.kill()
	_target_preview_tween = create_tween()
	_target_preview_tween.tween_property(target_preview, "global_position", screen_center_pos.global_position, 0.5)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_target_preview_tween.parallel()\
			.tween_property(target_preview, "modulate:a", 1.0, 0.5)
	_target_preview_tween.tween_interval(2.0)
	_target_preview_tween\
			.tween_property(target_preview, "global_position", out_of_bounds_target_preview_pos.global_position, 0.7)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_target_preview_tween.parallel()\
			.tween_property(target_preview, "scale", Vector2.ONE, 0.7)
	
	## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
	await _target_preview_tween.finished
	
	_start_round()


# ================================= Private ================================= #


############### Methods that configure each individual state.


## Starts a new "round". Each round is defined by the following set of events:
## Face slides in -> Mask is draggable -> mask was dropped -> mask is being janked -> mask was janked.
func _start_round() -> void:
	_current_state = States.FaceEntering
	_slide_face_in()


## Mask object is created and becomes draggable
func _start_dragging_mask_state() -> void:

	_current_state = States.DraggingMask

	create_tween().tween_property(drag_label, "modulate:a", 1.0, 0.3)

	var _mask : Mask = mask_scene.instantiate()
	_mask.global_position = mask_start_position.global_position
	_mask.modulate.a = 0.0
	_mask.dropped.connect(_on_mask_dropped)

	add_child(_mask)
	_current_mask = _mask
	_mask.draggable = true


## Jank logic is executed.
func _start_jank_state() -> void:

	_current_state = States.Janking

	var _ind_tween := create_tween()
	_ind_tween.tween_property(yank_indicator, "modulate:a", 1.0, 0.3)

	## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
	await _ind_tween.finished

	yank_indicator.start_detecting_click()


func _start_mask_evaluation_state() -> void:

	_current_state = States.EvaluatingMaskDrag

	create_tween().tween_property(drag_label, "modulate:a", 0.0, 0.3)

	var _success := drop_region.overlaps_drop_region(_current_mask.drop_region)
	_current_mask.draggable = false
	_current_mask.queue_free()

	if _success:
		_mask_dropped_successfully()
		drop_mask_player.play()
	else:
		_mask_failed()


func _go_to_game_over() -> void:
	_current_state = States.NoHealth
	## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
	await create_tween().tween_interval(0.7).finished
	navigate_to_screen.emit(load(game_over_screen_scene_path))


############### Additional Methods


## Face starts to slide in at the beginning of the round.
func _slide_face_in() -> void:
	face.reset_mask()
	face.scale = Vector2.ONE * 1.04
	face.apply_face_randomizer_result(_faces_to_show[_current_face_offset])
	if _face_slide_tween != null:
		_face_slide_tween.kill()
	_face_slide_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_face_slide_tween.tween_property(face, "global_position", face_in_position.global_position, 0.7)
	_face_slide_tween.parallel()\
			.tween_property(face, "scale", Vector2.ONE, 0.3)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_delay(0.5)
	_face_slide_tween.tween_callback(_on_face_slide_tween_completed)


## Mask was dropped correctly over the face area.
func _mask_dropped_successfully() -> void:
	face.mask_visible = true
	## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
	await create_tween().tween_interval(0.7).finished
	_start_jank_state()


## Mask was dropped outside of the valid face area.
func _mask_failed() -> void:
	face.mask_visible = false
	_substract_health()
	if _current_health > 0:
		_start_dragging_mask_state()
	else:
		_go_to_game_over()


## Face starts to slide out at the end of the round.
func _slide_face_out_after_round() -> void:
	if _face_slide_tween != null:
		_face_slide_tween.kill()
	_face_slide_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_face_slide_tween.tween_property(face, "global_position", face_out_position.global_position, 0.7)
	_face_slide_tween.tween_callback(func(): face.mask_visible = false)
	_face_slide_tween.tween_interval(0.7)
	_face_slide_tween.tween_callback(_on_face_slide_out_tween_completed)


## Substracts one health and plays the "damage" sound
func _substract_health() -> void:
	_current_health -= 1
	error_player.play()


## Ensures that the local health values are synchronized to the health UI.
func _sync_health() -> void:
	health.max_health = max_health
	health.current_health = _current_health


# ================================ Callbacks ================================ #


############### Tween callbacks


func _on_face_slide_tween_completed() -> void:
	if face.matches_result(_target_face):
		update_bgm.emit(ominous_bgm_path, 0.1, 0.0, 0.5)
		heartbeat_player.play()
		var _tween := create_tween()
		_tween.tween_property(canvas_modulate, "color", mystical_canvas_modulate_color, 0.5)
		_tween.parallel()\
				.tween_property(ominous_overlay, "modulate:a", 1.0, 0.5)
		## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
		await _tween.finished
	_start_dragging_mask_state()


func _on_face_slide_out_tween_completed() -> void:
	_current_face_offset += 1
	if _current_face_offset < _faces_to_show.size():
		_slide_face_in()
	else:
		navigate_to_screen.emit(load(final_screen_scene_path))


############### Mask signal callbacks


func _on_mask_dropped() -> void:
	_start_mask_evaluation_state()	


############### JankIndicator signal callbacks


func _on_jank_indicator_success() -> void:	

	if face.matches_result(_target_face):
		update_bgm.emit("", 0.0, 0.0, 0.0)
		face.yank_mask_off_hard()
		black_rip_color_cover_animation_player.play("enter")
		## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
		await create_tween().tween_interval(2.0).finished
		navigate_to_screen.emit(load(final_screen_scene_path))
	else:
		face.yank_mask_off()
		## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
		await create_tween().tween_interval(0.7).finished
		var _ind_tween := create_tween()
		_ind_tween.tween_property(yank_indicator, "modulate:a", 0.0, 0.3)
		_slide_face_out_after_round()


func _on_jank_indicator_failed() -> void:

	_substract_health()

	if _current_health > 0:
		## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
		await create_tween().tween_interval(0.7).finished
		var _ind_tween := create_tween()
		_ind_tween.tween_property(yank_indicator, "modulate:a", 0.0, 0.3)
		_start_jank_state()
	else:
		_go_to_game_over()


############### TargetPreview signal callbacks


func _on_target_preview_mouse_focused() -> void:
	if _current_state != States.BeforeStarting:
		if _target_preview_tween != null:
			_target_preview_tween.kill()
		_target_preview_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_target_preview_tween.\
				tween_property(target_preview, "global_position", in_bounds_target_preview_pos.global_position, 0.3)
		_target_preview_tween.parallel()\
				.tween_property(target_preview, "scale", Vector2.ONE * 1.5, 0.3)


func _on_target_preview_mouse_unfocused() -> void:
	if _current_state != States.BeforeStarting:
		if _target_preview_tween != null:
			_target_preview_tween.kill()
		_target_preview_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_target_preview_tween.\
				tween_property(target_preview, "global_position", out_of_bounds_target_preview_pos.global_position, 0.3)
		_target_preview_tween.parallel()\
				.tween_property(target_preview, "scale", Vector2.ONE, 0.3)
