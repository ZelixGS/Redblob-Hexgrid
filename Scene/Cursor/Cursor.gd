class_name Cursor extends Node3D

@export var color: Color = Color.YELLOW

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var mesh: ArrayMesh = mesh_instance_3d.mesh

var material: StandardMaterial3D

#func _ready() -> void:
	#mesh_instance_3d.get_surface_override_material(0).albedo_color = color

func paint(color_) -> void:
	mesh_instance_3d.get_surface_override_material(0).albedo_color = color_
