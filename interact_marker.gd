extends MeshInstance3D

func _physics_process(_delta: float) -> void:
	self.rotate_y(-0.05)
