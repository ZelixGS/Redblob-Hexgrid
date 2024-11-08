class_name OffsetCoord extends RefCounted

var col: int
var row: int

func _init(col_: int, row_: int) -> void:
	col = col_
	row = row_

func to_key() -> String:
	return "col:%s|row:%s" % [col, row]

func to_vector2() -> Vector2i:
	return Vector2i(col, row)
