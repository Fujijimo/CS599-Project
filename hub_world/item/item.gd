extends StaticBody3D
class_name Item

@export var data: Resource

func _ready() -> void:
	$MeshInstance3D.mesh = data.mesh
	$CollisionShape3D.shape = data.collision
