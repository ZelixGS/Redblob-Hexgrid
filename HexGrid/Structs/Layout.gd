class_name Layout extends RefCounted

var orientation: Orientation
var size: Vector2i
var origin: Vector2i

func _init(orientation_: Orientation, size_: Vector2i, origin_: Vector2i) -> void:
	orientation = orientation_
	size = size_
	origin = origin_
