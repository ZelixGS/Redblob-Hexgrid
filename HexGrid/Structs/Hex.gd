class_name Hex extends RefCounted

var id: int

var q: int
var r: int
var s: int

var neighbors: Array[Hex] = []
var data: Dictionary = {}

func _init(q_: int, r_: int, s_: int) -> void:
	q = q_
	r = r_
	s = s_
	assert(q + r + s == 0)

func to_key() -> String:
	return "q_%s|r_%s|s_%s" % [q, r, s]
