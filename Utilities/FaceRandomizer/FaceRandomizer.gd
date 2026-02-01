class_name FaceRandomizer
extends Node


func generate_random_face() -> FaceRandomizerResult:
	return FaceRandomizerResult.new({
		"face": randi_range(1, 3),
		"eyes": randi_range(1, 3),
		"hair": randi_range(1, 3),
		"skin_color": randi_range(1, 5),
		"hair_color": randi_range(1, 6)
	})


func generate_random_face_set(amount: int) -> Array[FaceRandomizerResult]:
	var _result : Array[FaceRandomizerResult] = []
	for i in range(amount):
		_result.append(generate_random_face())
	return _result


class FaceRandomizerResult extends RefCounted:
	var face := 1
	var eyes := 1
	var hair := 1
	var skin_color := 1
	var hair_color := 1
	func _init(props := {}) -> void:
		for prop_name in props.keys():
			if prop_name in self:
				set(prop_name, props[prop_name])
