@tool
class_name Face
extends Node2D


@export var base_sprite: Sprite2D
@export var eyes_sprite: Sprite2D
@export var hairs_sprite: Sprite2D
@export var mask_sprite: Sprite2D


@export_range(1, 3) var base_variant := 1:
	set(new_val):
		base_variant = new_val
		_sync_face.call_deferred()
@export_range(1, 3) var eyes_variant := 1:
	set(new_val):
		eyes_variant = new_val
		_sync_face.call_deferred()
@export_range(1, 3) var hair_variant := 1:
	set(new_val):
		hair_variant = new_val
		_sync_face.call_deferred()
@export var skin_color := 1:
	set(new_val):
		skin_color = new_val
		_sync_face.call_deferred()
@export var hair_color := 1:
	set(new_val):
		hair_color = new_val
		_sync_face.call_deferred()
@export var mask_visible := false:
	set(new_val):
		mask_visible = new_val
		_sync_face.call_deferred()
@export var skin_colors : Array[Color]
@export var hair_colors : Array[Color]

@export_tool_button("randomize", "Callable") var randomize_action = _randomize


func _sync_face() -> void:

	mask_sprite.visible = mask_visible

	base_sprite.frame = base_variant - 1
	eyes_sprite.frame = eyes_variant - 1
	hairs_sprite.frame = hair_variant - 1

	if skin_color - 1 >= skin_colors.size():
		base_sprite.modulate = Color.WHITE
	else:
		base_sprite.modulate = skin_colors[skin_color - 1]
	
	if hair_color - 1 >= hair_colors.size():
		hairs_sprite.modulate = Color.WHITE
	else:
		hairs_sprite.modulate = hair_colors[hair_color - 1]


func _randomize() -> void:
	base_variant = randi_range(1, 3)
	eyes_variant = randi_range(1, 3)
	hair_variant = randi_range(1, 3)
	skin_color = randi_range(1, skin_colors.size() + 1)
	hair_color = randi_range(1, hair_colors.size() + 1)
