extends StaticBody3D

@onready var ball: RigidBody3D = $"../Ball"
@export var speed_boost: float = 300.0

func _process(_delta: float) -> void:
	rotate_y(0.001)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if "Ball" in body.name:
		body.apply_impulse(Vector3(basis.z.x * speed_boost, 0, basis.x.x * speed_boost))
