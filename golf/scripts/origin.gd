extends Node3D
var mouse_sensitivity: float = 0.005
var turn_speed: float = 0.2

@onready var ball: RigidBody3D = $"../Ball"
@onready var ball_model: MeshInstance3D = $"../BallTracker/BallModel"

func _input(event):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("turn_left"):
		rotate_y(turn_speed * delta)
	if Input.is_action_pressed("turn_right"):
		rotate_y(-turn_speed * delta)
	
	$"../BallTracker".position = ball.position
	
	position = lerp(position, ball.position, 0.33)
	ball_model.look_at($SpringArm3D/PlayerCam.global_position)
