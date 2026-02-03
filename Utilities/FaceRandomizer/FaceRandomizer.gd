## Utility node that can generate either a random face or a set of random aces.
class_name FaceRandomizer
extends Node


# ================================= Public ================================== #


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


############### Internal FaceRandomizerResult class


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
	
	func is_same(other_result: FaceRandomizerResult) -> bool:
		return (
			face == other_result.face and
			eyes == other_result.eyes and
			hair == other_result.hair and
			skin_color == other_result.skin_color and
			hair_color == other_result.hair_color
		)
