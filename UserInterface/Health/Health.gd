@tool
class_name Health
extends HBoxContainer


@export var max_health := 5:
	set(new_val):
		max_health = new_val
		_sync_health.call_deferred()
@export var current_health := 5:
	set(new_val):
		current_health = new_val
		_sync_health.call_deferred()

@export var full_health_texture: Texture
@export var empty_health_texture: Texture


func _ready() -> void:
	_sync_health()


func _sync_health() -> void:
	
	for child in get_children():
		child.queue_free()
	
	for i in range(max_health):
		var _texture := TextureRect.new()
		if i < current_health:
			_texture.texture = full_health_texture
		else:
			_texture.texture = empty_health_texture
		add_child(_texture)
