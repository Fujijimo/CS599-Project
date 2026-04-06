extends CharacterBody3D

@onready var normal_target_collision: CollisionShape3D = $NormalTarget/NormalTargetCollision
@onready var ground_pound_target: Area3D = $GroundPoundTarget
@onready var ground_pound_normal_mesh: MeshInstance3D = $GroundPoundTarget/GroundPoundNormalMesh
@onready var ground_pound_collision: CollisionShape3D = $GroundPoundTarget/GroundPoundCollision
@onready var ground_pound_cam: Camera3D = $"../GroundPoundCam"
@export var health: int

func _on_normal_target_body_entered(body: Node3D) -> void:
	if body.name == "Ball":
		body.gravity_scale = 5
		health = health - randi_range(25, 30)
		body.apply_impulse(Vector3(-body.linear_velocity.x * 5, -body.linear_velocity.y, -body.linear_velocity.z * 5))
		normal_target_collision.set_deferred("disabled", true)
		print(health)

func _on_low_target_body_entered(body: Node3D) -> void:
	if body.name == "Ball":
		health = health - randi_range(10, 20)
		print(health)

func _on_ground_pound_target_body_entered(body: Node3D) -> void:
	#print(ground_pound_collision.global_position.distance_to(ground_pound_normal_mesh.get_aabb().size))
	#print(Vector2(body.global_position.y, body.global_position.z).length())
	#print(Vector2(ground_pound_collision.global_position.y, ground_pound_collision.global_position.z).length())
	if body.name == "Ball":
		if body.global_position.distance_to(ground_pound_collision.global_position) <= 1.0:
			ground_pound_cam.current = true
		elif body.global_position.distance_to(ground_pound_collision.global_position) >= 4.0 and body.global_position.distance_to(ground_pound_collision.global_position) <= 8.0:
			ground_pound_cam.current = true

#func _physics_process(delta: float) -> void:
	#if $"../Ball".global_position.distance_to(ground_pound_collision.global_position) <= 1.0:
		#$"../Ball".freeze = true
