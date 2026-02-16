extends StaticBody3D

@onready var ball: RigidBody3D = $"../Ball"

@export var jump_height: float = 100.0
@export var jump_boost: float = 3.0


func _on_area_3d_body_entered(body: Node3D) -> void:
	if "Ball" in body.name:
		body.apply_impulse(Vector3(ball.linear_velocity.x * jump_boost, jump_height, ball.linear_velocity.z * jump_boost))
