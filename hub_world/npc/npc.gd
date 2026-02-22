class_name NPC
extends CharacterBody3D

@export var npc: Resource

func _ready() -> void:
	$MeshInstance3D.mesh = npc.mesh
	$CollisionShape3D.shape = npc.collision
