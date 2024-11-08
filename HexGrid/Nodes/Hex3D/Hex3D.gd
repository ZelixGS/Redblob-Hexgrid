class_name Hex3D extends Node3D

const MATERIAL: StandardMaterial3D = preload("res://HexGrid/Nodes/Models/HexMaterial.tres")

var col: int = 0
var row: int = 0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var mesh: CylinderMesh = mesh_instance_3d.mesh
@onready var label_3d: Label3D = $Label3D

var material: StandardMaterial3D

func _ready() -> void:
	mesh.material = mesh.material.duplicate()

func paint(color_) -> void:
	mesh.material.albedo_color = color_

func update_label() -> void:
	if label_3d:
		label_3d.text = "Col:%s\nRow:%s" % [col, row]
