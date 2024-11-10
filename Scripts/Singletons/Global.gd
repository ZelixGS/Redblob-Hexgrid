extends Node

const RAY_LENGTH: float = 1000

var _camera: Camera3D
var debug: DebugConsole

func get_mouse_node3d(skip_warning: bool = false) -> Node3D:
	var result = mouse_ray(skip_warning)
	if not result.is_empty():
		return result["collider"].owner
	return null

func get_mouse_position_3d(skip_warning: bool = false) -> Vector2:
	var result = mouse_ray(skip_warning)
	if not result.is_empty():
		var position: Vector3 = result["position"]
		return Vector2(position.x, position.z)
	return Vector2(0, 0)

func mouse_ray(skip_warning: bool = false) -> Dictionary:
	if not _camera:
		push_error("Global.camera is not set.")
		return {}
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var space: PhysicsDirectSpaceState3D = _camera.get_world_3d().direct_space_state
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	ray_query.from = _camera.project_ray_origin(mouse_position)
	ray_query.to = ray_query.from + _camera.project_ray_normal(mouse_position) * RAY_LENGTH
	var result: Dictionary = space.intersect_ray(ray_query)
	if result.is_empty():
		if not skip_warning:
			push_warning("Node3D under mouse is missing collision of sometype.")
		return {}
	return result
