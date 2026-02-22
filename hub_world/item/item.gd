class_name Item
extends StaticBody3D

@export var item: Resource

func _ready() -> void:
	$MeshInstance3D.mesh = item.mesh
	$CollisionShape3D.shape = item.collision
