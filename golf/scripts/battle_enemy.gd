extends CharacterBody3D

@onready var ground_pound_critical: CollisionShape3D = $GroundPoundTarget/GroundPoundCritical
@onready var ground_pound_normal: CollisionShape3D = $GroundPoundTarget/GroundPoundNormal
@onready var ground_pound_miss: CollisionShape3D = $GroundPoundTarget/GroundPoundMiss
@export var health: int

func _on_normal_target_body_entered(body: Node3D) -> void:
	if body.name == "Ball":
		health = health - 10
		print(health)

func _on_low_target_body_entered(body: Node3D) -> void:
	if body.name == "Ball":
		health = health - 5
		print(health)

func _on_ground_pound_target_area_entered(area: Area3D) -> void:
	if area.name == "BallArea":
		#if area.overlaps_area(ground_pound_critical):
			#health = health - 50
		#if area.overlaps_area(ground_pound_miss):
			#pass
		#if area.overlaps_area(ground_pound_normal) and not area.overlaps_area(ground_pound_critical) and not area.overlaps_area(ground_pound_miss):
			#health = health - 20
		print(health)
