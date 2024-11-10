@icon("./icon_grid.png")
class_name HexGrid3D extends Node3D

const HEX3D: PackedScene = preload("res://HexGrid/Nodes/3D/Hex3D/Hex3D.tscn")

@export var cursor: Cursor
@export var character: Character

@export var noise: FastNoiseLite
@export var size: Vector2i = Vector2i(10, 10)

var grid: HexGrid
var pathfinding: HexPathfinding

var hexes: Dictionary = {}
var selected: Array[Hex3D] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		setup()

func setup() -> void:
	grid = HexGrid.new(size)
	pathfinding = HexPathfinding.new(grid, self)
	hexes = {}
	clear_meshes()
	add_meshes()

func _process(_delta: float) -> void:
	move_cursor()
	debug_char()
	display_distance()

func move_cursor() -> void:
	var hex: Hex = grid.get_hex_by_position(Global.get_mouse_position_3d(true))
	var hex_position: Vector2 = grid.hex_to_pixel(hex)
	cursor.position = Vector3(hex_position.x, get_height(Vector2(hex_position.x, hex_position.y)), hex_position.y)
	Global.debug.add_property("Cursor", str("(%s, %s)" % [hex.q, hex.r]), 1)

func debug_char() -> void:
	var char_pos: Vector3 = character.position
	var hex: Hex = grid.get_hex_by_position(Vector2(char_pos.x, char_pos.z))
	Global.debug.add_property("Character", str("(%s, %s)" % [hex.q, hex.r]), 2)

func display_distance() -> void:
	var char_hex: Hex = get_character_hex()
	var cursor_hex: Hex = get_cursor_hex()
	var distance: int = grid.get_distance(char_hex, cursor_hex)
	Global.debug.add_property("Distance", str("%s" % distance), 2)

func get_height(pos: Vector2) -> float:
	return roundf(noise.get_noise_2dv(pos) * 5)

#region Common Functions

func get_character_hex() -> Hex:
	return grid.get_hex_by_position(character.position)

func get_cursor_hex() -> Hex:
	return grid.get_hex_by_position(cursor.position)

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
		new_mesh.position = Vector3(htp.x, get_height(htp), htp.y)

#endregion

#region Helper Functions

func to_hex_data(hex_3d: Hex3D) -> Hex:
	return grid.get_hex_by_key(hex_3d.name)

func to_hex_3d(hex: Hex) -> Hex3D:
	return hexes.get(hex.to_key())

func array_to_hex_data(hexes_3d: Array[Hex3D]) -> Array[Hex]:
	var array: Array[Hex]
	for i in hexes_3d:
		array.append(to_hex_data(i))
	return array

func array_to_hex_3d(passed_array: Array[Hex]) -> Array[Hex3D]:
	var array: Array[Hex3D]
	for i in passed_array:
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
		var char_hex: Hex = get_character_hex()
		var cursor_hex: Hex = get_cursor_hex()
		var path: PackedVector3Array = pathfinding.get_path(char_hex, cursor_hex)
		character.move(path)
	if event.is_action_pressed("right_click"):
		if selected.size() > 0:
				paint_selected(Color.WHITE)
