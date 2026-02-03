## Utility area that makes it easier to detect when the mask and the face are close
## enough to be considered as "overlapping".
@tool  # <-- Reflect changes in the editor in real-time
class_name DropRegion
extends Node2D


############### Exported properties

## How large the detection circle will be
@export var radius := 30.0:
	set(new_val):
		radius = new_val
		_sync_radius.call_deferred()
@export_group("Node References")
@export var drop_collision_shape: CollisionShape2D
@export var drop_area: Area2D


# ================================ Lifecycle ================================ #


func _ready() -> void:
	drop_collision_shape.shape = CircleShape2D.new()
	_sync_radius()


# ================================= Public ================================== #


func overlaps_drop_region(which_region: DropRegion) -> bool:
	return drop_area.get_overlapping_areas().has(which_region.drop_area)


# ================================= Private ================================= #


func _sync_radius() -> void:
	(drop_collision_shape.shape as CircleShape2D).radius = radius
