class_name HexPathfinding extends RefCounted

var astar: AStar3D

func create_paths(grid: HexGrid) -> void:
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