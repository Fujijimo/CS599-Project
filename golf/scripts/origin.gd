extends Node3D

var mouse_sensitivity: float = 0.005
var turn_speed: float = 5

@onready var ball: RigidBody3D = $"../Ball"
@onready var ball_model: MeshInstance3D = $"../BallTracker/BallModel"

func _unhandled_input(event):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		ball_model.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clampf(rotation.x, deg_to_rad(-45), deg_to_rad(45))
		rotation.y -= event.relative.x * mouse_sensitivity
	else:
		ball_model.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON

func _physics_process(delta: float) -> void:
	var cam_input_dir: Vector2 = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	var move_input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var camera_sensitivity: float = 1.0
	
	if ball.swing_phase == 0 and cam_input_dir == Vector2.ZERO:
		rotate_y(-move_input_dir.x * camera_sensitivity * delta)
	else:
		rotate_y(-cam_input_dir.x * camera_sensitivity * delta)

	$"../BallTracker".position = ball.position
	
	position = lerp(position, ball.position, 0.33)
	ball_model.look_at(get_viewport().get_camera_3d().global_position)
