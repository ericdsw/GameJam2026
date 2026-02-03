@tool  # <-- Reflect changes in the editor in real-time
class_name StrengthIndicator
extends Node2D


############### Exported properties

## How thick the bar will be
@export var width := 20.0:
	set(new_val):
		width = new_val
		_sync_sizes.call_deferred()
## How tall the bal will be
@export var height := 200.0:
	set(new_val):
		height = new_val
		_sync_sizes.call_deferred()
# Where the safe zone minimum value will be located
@export var min_safe_zone := 150.0:
	set(new_val):
		min_safe_zone = new_val
		_sync_sizes.call_deferred()
## Where the safe zone maximum value will be located
@export var max_safe_zone := 180.0:
	set(new_val):
		max_safe_zone = new_val
		_sync_sizes.call_deferred()
## Set of curves that specify how the indicator will move when the strenght indicator is "capturing".
## One will be chosen at random
@export var possible_position_curves: Array[CurveTexture]

## Button used to test the strength measuring logic startup in-editor
@export_tool_button("Try to measure strength", "Callable") var measure = start_measuring_strength
## Button used to test the strength measuring logic capture in-editor
@export_tool_button("Try to stop", "Callable") var measure_cur = measure_current_strength
## Button used to test the safe area randomization logic.
## Unlike the other two, I defined this one as an inline method (also called lambda) so that I could pass
## 60.0 as a parameter to the method.
@export_tool_button("Try to randomize_safe_area") var random_safe_area = func(): randomize_safe_area_with_size(60.0)

@export_group("Node References")
@export var background: NinePatchRect
@export var success_area: NinePatchRect
@export var arrow: TextureRect


############### Private variables

var _bottom_arrow_pos := Vector2.ZERO
var _top_arrow_pos := Vector2.ZERO
var _arrow_enter_tween: Tween = null
var _used_curve_texture: CurveTexture
var _moving_arrow := false
var _cur_movement_lifetime := 0.0
var _max_movement_lifetime := 1.0


############### Callbacks

signal success()
signal failed()


# ================================ Lifecycle ================================ #


func _ready() -> void:
	_sync_sizes()
	if Engine.is_editor_hint():  # <-- True if the scene is running inside the editor.
		arrow.modulate.a = 1.0
	else:
		arrow.modulate.a = 0.0


## In order to move the arrow using the selected curve, I'm manually moving it inside the _process
## method instead of using a simple tween.
func _process(delta: float) -> void:

	if _moving_arrow:
		
		## Step 1: Determine the current progress percent the movement is at.
		var _movement_percent := _cur_movement_lifetime / _max_movement_lifetime
		
		## Step 2: Use said progress to sample a point inside the selected curve texture. This basically means
		## "give me the "Y" value at the corresponding "X" value, and since the curve values are clamped to a
		## maximum of 1, we can directly use the progress percent for this sample.
		var _progress : float = _used_curve_texture.curve.sample_baked(_movement_percent)

		## Step 3: Position the arrow corresponding to the current "Y" value, multiplied by the max possible value.
		arrow.position = _bottom_arrow_pos + Vector2.UP * (_bottom_arrow_pos.distance_to(_top_arrow_pos)) * _progress
		
		## Update the current movmeent lifetime
		_cur_movement_lifetime += delta
		
		## Check if the arrow reached the maximum point, and emit the appropiate signal if true.
		if _cur_movement_lifetime >= _max_movement_lifetime:
			_moving_arrow = false
			failed.emit()


# ================================= Public ================================== #


## Auto-selects a random safe area zone inside the current bounds that will have a range of `safe_area_size`.
## Said safe are will always be located on the second half of the progress bar.
func randomize_safe_area_with_size(safe_area_size: float) -> void:
	min_safe_zone = randf_range(height / 2.0, height - safe_area_size)
	max_safe_zone = min_safe_zone + safe_area_size


## Forces the arrow back to the bottom position
func reset_arrow_pos() -> void:
	arrow.position = _bottom_arrow_pos
	arrow.reset_physics_interpolation()


## Start the strength capture logic, the arrow will start to move.
func start_measuring_strength() -> void:
	
	arrow.position = _bottom_arrow_pos

	if _arrow_enter_tween != null:
		_arrow_enter_tween.kill()
	_arrow_enter_tween = create_tween()
	_arrow_enter_tween.tween_property(arrow, "modulate:a", 1.0, 0.2)
	_arrow_enter_tween.tween_interval(0.2)
	## https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
	await _arrow_enter_tween.finished

	_moving_arrow = true
	_cur_movement_lifetime = 0.0
	_max_movement_lifetime = randf_range(0.7, 1.5)
	_used_curve_texture = possible_position_curves.pick_random()


## Stop the strength capturing logic and measure the result.
func measure_current_strength() -> void:
	_moving_arrow = false
	var _result := _bottom_arrow_pos.y - arrow.position.y
	if _result >= min_safe_zone and _result <= max_safe_zone:
		success.emit()
	else:
		failed.emit()


# ================================= Private ================================= #


func _sync_sizes() -> void:

	background.position = Vector2(-width / 2.0, -height)
	background.size = Vector2(width, height + 10.0)
	success_area.position = Vector2(-width / 2.0 - 5.0, -max_safe_zone)
	success_area.size = Vector2(width + 10.0, max_safe_zone - min_safe_zone)

	_bottom_arrow_pos = Vector2.RIGHT * (width / 2.0 + 10.0) - arrow.size / 2.0
	_top_arrow_pos = _bottom_arrow_pos + Vector2.UP * height

	if Engine.is_editor_hint():
		reset_arrow_pos()
