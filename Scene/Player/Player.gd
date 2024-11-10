class_name Player extends Node3D

@export_category("Speed")
@export var move_speed: float = 10.0
@export var zoom_speed: float = 0.1
@export var rotate_speed: float = 5.0

@export_category("Zoom")
@export var min_zoom: float = 0.4
@export var max_zoom: float = 3.0

@onready var gimbal: Node3D = $Gimbal
@onready var camera_3d: Camera3D = $Gimbal/Camera3D

var current_rotation: float = 0.0
var current_zoom: float = 1.0

func _ready() -> void:
	Global._camera = camera_3d

func _process(delta: float) -> void:
	move_camera(delta)
	adjust_zoom()
	adjust_rotation(delta)

func get_input() -> Vector2:
	return Input.get_vector("camera_move_left", "camera_move_right", "camera_move_backward", "camera_move_forward")


func adjust_rotation(delta) -> void:
	if Input.is_action_pressed("camera_rotate_left"):
		gimbal.rotation.y -= rotate_speed * delta
	if Input.is_action_pressed("camera_rotate_right"):
		gimbal.rotation.y += rotate_speed * delta

func adjust_zoom() -> void:
	scale = lerp(scale, Vector3.ONE * current_zoom, zoom_speed)

func move_camera(delta) -> void:
	var input: Vector2 = get_input().normalized()
	var camera_transform: Transform3D = gimbal.global_transform
	var forward = -camera_transform.basis.z.normalized()
	var right = camera_transform.basis.x.normalized()

	var direction: Vector3 = Vector3((right * input.x) + (forward * input.y)).normalized()
	global_position += direction * move_speed * delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		current_zoom -= zoom_speed
		current_zoom = clampf(current_zoom, min_zoom, max_zoom)
	if event.is_action_pressed("camera_zoom_out"):
		current_zoom += zoom_speed
		current_zoom = clampf(current_zoom, min_zoom, max_zoom)
