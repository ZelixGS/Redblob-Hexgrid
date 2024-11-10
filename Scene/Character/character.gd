class_name Character extends CharacterBody3D

var is_moving: bool = false

func move(points: PackedVector3Array) -> void:
	if is_moving:
		return
	is_moving = true
	for p in points:
		var tween: Tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "position", p, 0.25)
		await tween.finished
	is_moving = false
