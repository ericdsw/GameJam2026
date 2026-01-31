class_name FaceScreen
extends BaseScreen


enum States {
	Idle,
	DraggingMask,
	WaitingBeforeJank,
	Janking
}


@export var mask_scene: PackedScene
@export var out_of_bounds_mask_start_position: Marker2D
@export var mask_start_position: Marker2D


var _current_state := States.Idle
var _current_mask: Mask
var _mask_enter_tween: Tween = null


func _ready() -> void:
	await create_tween().tween_interval(1.0).finished
	_start_dragging_mask_state()


func _start_round() -> void:
	pass


func _start_dragging_mask_state() -> void:

	var _mask : Mask = mask_scene.instantiate()
	_mask.global_position = out_of_bounds_mask_start_position.global_position
	_mask.rotation = deg_to_rad(20.0)

	add_child(_mask)
	_current_mask = _mask

	if _mask_enter_tween != null:
		_mask_enter_tween.kill()
	_mask_enter_tween = create_tween()\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_mask_enter_tween.tween_property(_mask, "global_position", mask_start_position.global_position, 1.0)
	_mask_enter_tween.parallel().tween_property(_mask, "rotation", 0.0, 1.0)
	_mask_enter_tween.tween_callback(func(): _mask.draggable = true)
