extends StaticBody3D

@export var exit_teleport: Node3D
var teleport_entered: bool = false
@onready var ball: RigidBody3D = $"../Ball"

func _on_area_3d_body_entered(body: Node3D) -> void:
	if "Ball" in body.name:
		teleport_entered = true
		ball.state_copy.transform = Transform3D(basis, exit_teleport.global_position)
		$AudioStreamPlayer.play()
		teleport_entered = false
