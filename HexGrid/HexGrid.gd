class_name HexGrid extends RefCounted

var LAYOUT_POINTY: Orientation = Orientation.new(sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 0.5);
var LAYOUT_FLAT: Orientation = Orientation.new(3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0), 2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0, 0.0);
var DIRECTIONS: Array[Hex] = [Hex.new(1, 0, -1), Hex.new(1, -1, 0), Hex.new(0, -1, 1), Hex.new(-1, 0, 1), Hex.new(-1, 1, 0), Hex.new(0, 1, -1)]

var cells: Dictionary = {}

var current_grid_size: Vector2i = Vector2i(10, 10)
var current_layout: Layout

func _init(size_: Vector2i) -> void:
	current_grid_size = size_
	current_layout = Layout.new(LAYOUT_POINTY, Vector2i(1, 1), Vector2i(0, 0))
	clear_cells()
	create_cells()
	create_neighbors()

#region Math Functions

func add(a: Hex, b: Hex) -> Hex:
	return Hex.new(a.q + b.q, a.r + b.r, a.s + b.s)

func subtract(a: Hex, b: Hex) -> Hex:
	return Hex.new(a.q - b.q, a.r - b.r, a.s - b.s)

func multiply(a: Hex, k: int) -> Hex:
	return Hex.new(a.q * k, a.r * k, a.s * k)

#endregion

#region Cell Maniuplation

func get_hex(key: String) -> Hex:
	print(key)
	return cells.get(key)

#endregion

func get_length(hex: Hex) -> int:
	return int( abs(hex.q) + abs(hex.r) + abs(hex.s) / 2 )

func get_distance(a: Hex, b: Hex) -> int:
	return get_length(subtract(a, b))

func get_direction(direction: int) -> Hex:
	return DIRECTIONS[(6 + (direction % 6)) % 6]

func get_neighbor(hex: Hex, direction: int) -> Hex:
	return add(hex, get_direction(direction))

func get_hex_in_radius(origin: Hex, N: int) -> Array[Hex]:
	var array: Array[Hex]
	for q in range(-N, N +1):
		for r in range(max(-N, -q - N), min(N, -q + N) + 1):
			var s = -q - r
			var key: String = add(origin, Hex.new(q, r, s)).to_key()
			var hex: Hex = get_hex(key)
			if hex:
				array.append(hex)
	return array

func hex_to_pixel(hex: Hex, layout: Layout = current_layout) -> Vector2:
	var orientation = layout.orientation
	var x: float = (orientation.f0 * hex.q + orientation.f1 * hex.r) * layout.size.x
	var y: float = (orientation.f2 * hex.q + orientation.f3 * hex.r) * layout.size.y
	return Vector2(x, y)

func pixel_to_hex(p: Vector2, layout: Layout = current_layout) -> FractionalHex:
	var orientation = layout.orientation
	var pt = Vector2( (p.x - layout.origin.x) / layout.size.x, (p.y - layout.origin.y) / layout.size.y )
	var q: float = orientation.b0 * pt.x + orientation.b1 * pt.y
	var r: float = orientation.b2 * pt.x + orientation.b3 * pt.y
	return FractionalHex.new(q, r, -q - r)

func get_cornet_offset(corner: int, layout: Layout = current_layout) -> Vector2:
	var size: Vector2 = layout.size
	var angle: float = 2.0 * PI * (layout.orientation.start_angle + corner) / 6
	return Vector2(size.x * cos(angle), size.y * sin(angle))

func polygon_corners(hex: Hex, layout: Layout = current_layout) -> Array[Vector2]:
	var corners: Array[Vector2] = []
	var center: Vector2 = hex_to_pixel(hex, layout)
	for i in range(6):
		var offset: Vector2 = get_cornet_offset(i, layout)
		corners.push_back(Vector2((center.x + offset.x), (center.y + offset.y)))
	return corners

func hex_round(frac_hex: FractionalHex) -> Hex:
	var q = int(roundi(frac_hex.q))
	var r = int(roundi(frac_hex.r))
	var s = int(roundi(frac_hex.s))
	var q_diff: float = abs(q - frac_hex.q)
	var r_diff: float = abs(r - frac_hex.r)
	var s_diff: float = abs(s - frac_hex.s)
	if q_diff > r_diff and q_diff > s_diff:
		q = -r - s
	elif r_diff > s_diff:
		r = -q - s
	else:
		s = -q - r
	return Hex.new(q, r, s)

func hex_lerp(a: Hex, b: Hex, t: float) -> FractionalHex:
	return FractionalHex.new(lerpf(a.q, b.q, t), lerpf(a.r, b.r, t), lerpf(a.s, b.s, t))

func get_line(a: Hex, b: Hex) -> Array[Hex]:
	var n: int = get_distance(a, b)
	var results: Array[Hex] = []
	var step: float = 1.0 / max(n, 1)
	for i in range(n):
		results.push_back(hex_round(hex_lerp(a, b, step * i)))
	return results

func rotate_left(hex: Hex) -> Hex:
	return Hex.new(-hex.s, -hex.q, -hex.r)

func rotate_right(hex: Hex) -> Hex:
	return Hex.new(-hex.r, -hex.s, -hex.q)

#region Create Cells

func clear_cells() -> void:
	cells = {}

func create_cells() -> void:
	var index: int = 0
	for q in range(current_grid_size.x):
		for r in range(current_grid_size.y):
			var hex: Hex = Hex.new(q, r, -q - r)
			hex.id = index
			cells[hex.to_key()] = hex
			index += 1

func create_neighbors() -> void:
	for i in cells:
		var hex: Hex = cells[i]
		for direction in DIRECTIONS.size():
			var neighbor: String = get_neighbor(hex, direction).to_key()
			if cells.has(neighbor):
				hex.neighbors.append(cells[neighbor])

#endregion
