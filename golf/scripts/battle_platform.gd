extends StaticBody3D

@export var target: Node3D

func _physics_process(_delta: float) -> void:
	if target == $"../Ball":
		global_position = Vector3(target.global_position.x, 0, target.global_position.z)
	if target == $"../Enemy":
		global_position = Vector3(target.global_position.x, 0, target.global_position.z)
