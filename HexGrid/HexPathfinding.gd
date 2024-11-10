class_name HexPathfinding extends RefCounted

var grid: HexGrid
var grid_3d: HexGrid3D
var astar: AStar3D

func _init(grid_: HexGrid, grid_3d_: HexGrid3D) -> void:
	grid = grid_
	grid_3d = grid_3d_
	create_paths()

func create_paths() -> void:
	astar = AStar3D.new()
	# Add Points
	for key: String in grid.cells:
		var hex: Hex = grid.cells[key]
		var position: Vector2 = grid.hex_to_pixel(hex)
		astar.add_point(hex.id, Vector3(position.x, 0, position.y))
	# Connect Points
	for key: String in grid.cells:
		var hex: Hex = grid.cells[key]
		for neighbor: Hex in hex.neighbors:
			astar.connect_points(hex.id, neighbor.id)

func get_path(a: Hex, b: Hex) -> PackedVector3Array:
	var hex_a: int = grid.get_hex_by_key(a.to_key()).id
	var hex_b: int = grid.get_hex_by_key(b.to_key()).id
	var points: PackedVector3Array = astar.get_point_path(hex_a, hex_b)
	var new_array: PackedVector3Array = []
	for p: Vector3 in points:
		new_array.append(Vector3(p.x, grid_3d.get_height(Vector2(p.x, p.z)), p.z))
	return new_array
