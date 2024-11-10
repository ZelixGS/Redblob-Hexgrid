@tool
class_name HexGrid3D extends Node3D

const HEX3D: PackedScene = preload("res://HexGrid/Nodes/Hex3D/Hex3D.tscn")

@export var generate: bool = false:
	set(value):
		generate = false
		setup()
@export var size: Vector2i = Vector2i(10, 10)


var grid: HexGrid
var hexes: Dictionary = {}
var selected: Array[Hex3D] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		setup()

func setup() -> void:
	grid = HexGrid.new(size)
	hexes = {}
	clear_meshes()
	add_meshes()

#region Mesh Functions

func clear_meshes() -> void:
	for child in get_children():
		child.queue_free()

func add_meshes() -> void:
	for cell in grid.cells:
		var hex: Hex = grid.cells[cell]
		if hex is not Hex:
			continue
		var new_mesh: Hex3D = HEX3D.instantiate()
		new_mesh.name = hex.to_key()
		hexes[new_mesh.name] = new_mesh
		add_child(new_mesh)
		var htp: Vector2 = grid.hex_to_pixel(hex) # + grid.cube_to_oddr(hex)
		new_mesh.position = Vector3(htp.x, 0, htp.y)
		new_mesh.col = hex.q
		new_mesh.row = hex.r
		new_mesh.update_label()
		#await get_tree().create_timer(0.01).timeout

#endregion

#region Helper Functions

func to_hex_data(hex_3d: Hex3D) -> Hex:
	return grid.get_hex(hex_3d.name)

func to_hex_3d(hex: Hex) -> Hex3D:
	return hexes.get(hex.to_key())

func array_to_hex_data(hexes_3d: Array[Hex3D]) -> Array[Hex]:
	var array: Array[Hex]
	for i in hexes_3d:
		array.append(to_hex_data(i))
	return array

func array_to_hex_3d(hexes: Array[Hex]) -> Array[Hex3D]:
	var array: Array[Hex3D]
	for i in hexes:
		array.append(to_hex_3d(i))
	return array

#endregion

func get_neighbors(hex_3d: Hex3D) -> Array[Hex3D]:
	var hex: Hex = to_hex_data(hex_3d)
	var neighbors_data: Array[Hex] = hex.neighbors
	var neighbors_3d: Array[Hex3D] = array_to_hex_3d(neighbors_data)
	return neighbors_3d

func get_radius(hex_3d: Hex3D, radius: int = 1) -> Array[Hex3D]:
	var hex: Hex = to_hex_data(hex_3d)
	var radius_data: Array[Hex] = grid.get_hex_in_radius(hex, radius)
	var radius_3d: Array[Hex3D] = array_to_hex_3d(radius_data)
	return radius_3d

func get_astar_path(a: Hex3D, b: Hex3D) -> Array[Vector3]:
	var hex_a: Hex = to_hex_data(a)
	var hex_b: Hex = to_hex_data(b)
	return grid.get_astar_path(hex_a, hex_b)

func paint_selected(color: Color = Color.RED) -> void:
	for hex: Hex3D in selected:
		hex.paint(color)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var target: Node3D = Global.get_node3d_under_mouse()
		if target is Hex3D:
			if selected.size() > 0:
				paint_selected(Color.WHITE)
			selected = get_radius(target, 3)
			paint_selected()
	if event.is_action_pressed("right_click"):
		if selected.size() > 0:
				paint_selected(Color.WHITE)
