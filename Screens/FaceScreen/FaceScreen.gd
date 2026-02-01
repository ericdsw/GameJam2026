class_name FaceScreen
extends BaseScreen


enum States {
	Idle,
	FaceEntering,
	DraggingMask,
	EvaluatingMaskDrag,
	WaitingBeforeJank,
	Janking
}


@export var mask_scene: PackedScene
@export var mask_start_position: Marker2D

@export var face: Face
@export var face_in_position: Marker2D
@export var face_out_position: Marker2D
@export var mask_on_face_pos: Marker2D


var _current_state := States.Idle
var _current_mask: Mask
var _face_slide_tween: Tween = null
var _current_health := 10


# ================================ Lifecycle ================================ #


func _ready() -> void:
	face.global_position = face_out_position.global_position
	face.mask_visible = false
	face.reset_physics_interpolation()
	navigation_finished()


# ================================= Public ================================== #


func navigation_finished() -> void:
	await create_tween().tween_interval(1.0).finished
	_start_round()


# ================================= Private ================================= #


func _start_round() -> void:
	_current_state = States.FaceEntering
	_slide_face_in()


func _start_dragging_mask_state() -> void:

	_current_state = States.DraggingMask

	var _mask : Mask = mask_scene.instantiate()
	_mask.global_position = mask_start_position.global_position
	_mask.modulate.a = 0.0
	_mask.dropped.connect(_on_mask_dropped)

	add_child(_mask)
	_current_mask = _mask
	_mask.draggable = true


func _slide_face_in() -> void:
	face.scale = Vector2.ONE * 1.04
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


func _mask_dropped_successfully() -> void:
	face.mask_visible = true
	await create_tween().tween_interval(0.7).finished
	if _face_slide_tween != null:
		_face_slide_tween.kill()
	_face_slide_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_face_slide_tween.tween_property(face, "global_position", face_out_position.global_position, 0.7)
	_face_slide_tween.tween_callback(func(): face.mask_visible = false)
	_face_slide_tween.tween_interval(0.7)
	_face_slide_tween.tween_callback(_on_face_slide_out_tween_completed)


func _mask_failed() -> void:
	face.mask_visible = false
	_start_dragging_mask_state()


# ================================ Callbacks ================================ #


func _on_face_slide_tween_completed() -> void:
	_start_dragging_mask_state()


func _on_mask_dropped() -> void:

	_current_state = States.EvaluatingMaskDrag

	_current_mask.draggable = false
	_current_mask.queue_free()

	var _mask_pos := _current_mask.global_position
	var _face_pos := mask_on_face_pos.global_position
	var _distance := _mask_pos.distance_to(_face_pos)

	if _distance <= 20.0:
		_mask_dropped_successfully()
	else:
		_mask_failed()


func _on_face_slide_out_tween_completed() -> void:
	_slide_face_in()
