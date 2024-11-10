class_name Hex3D extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func paint(color_) -> void:
	mesh_instance_3d.get_surface_override_material(0).albedo_color = color_
