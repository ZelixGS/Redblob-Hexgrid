class_name FractionalHex extends RefCounted

var q: float
var r: float
var s: float

func _init(q_: float, r_: float, s_: float) -> void:
	q = q_
	r = r_
	s = s_
	assert(q + r + s == 0)

func to_key() -> String:
	return "q:%s|r:%s|s:%s" % [q, r, s]

func to_vector3() -> Vector3:
	return Vector3(q, r, s)
