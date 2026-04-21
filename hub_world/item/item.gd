class_name Item
extends StaticBody3D

@export var data: Resource

func _ready() -> void:
	$MeshInstance3D.mesh = data.mesh
	$CollisionShape3D.shape = data.collision
