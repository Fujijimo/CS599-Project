extends CharacterBody3D

@export_enum("Idle", "Move", "Attack") var mode: String = "Idle"

@export var move: Array = ["Blink", "Shoot"]
@export var health: int
@export var target_position: Vector3

@onready var normal_target_collision: CollisionShape3D = $NormalTarget/NormalTargetCollision
@onready var left_foot_collision: CollisionShape3D = $LowTarget/LeftFootCollision
@onready var right_foot_collision: CollisionShape3D = $LowTarget/RightFootCollision
@onready var ground_pound_target: Area3D = $GroundPoundTarget
@onready var ground_pound_normal_mesh: MeshInstance3D = $GroundPoundTarget/GroundPoundNormalMesh
@onready var ground_pound_collision: CollisionShape3D = $GroundPoundTarget/GroundPoundCollision
@onready var animation_import: AnimationPlayer = $dh_orange/AnimationPlayer
@onready var animation = $dh_orange/AnimationPlayer2

func _process(_delta: float) -> void:
	$HealthBar/SubViewport/ProgressBar.value = health
	if health <= 0:
		animation.play("Death")
		await animation.animation_finished
		queue_free()

func _on_normal_target_body_entered(body: Node3D) -> void:
	if body.name == "Ball" and state.turn == state.Turns.PLAYER_TURN:
		health = health - randi_range(35, 40)
		body.apply_impulse(Vector3(-body.linear_velocity.x * 5, -body.linear_velocity.y, -body.linear_velocity.z * 5))
		disable_collisions()
		print(health)

func _on_low_target_body_entered(body: Node3D) -> void:
	if body.name == "Ball" and state.turn == state.Turns.PLAYER_TURN:
		health = health - randi_range(10, 20)
		disable_collisions()
		print(health)

func _on_ground_pound_target_body_entered(body: Node3D) -> void:
	if body.name == "Ball":
		disable_collisions()
		if body.global_position.distance_to(ground_pound_collision.global_position) <= 0.8:
			body.specials.play("ground_pound")
			health -= 100
			print("poop")
		elif body.global_position.distance_to(ground_pound_collision.global_position) >= 2.1 and body.global_position.distance_to(ground_pound_collision.global_position) <= 4.25:
			body.specials.play("ground_pound")
			health -= randi_range(65, 70)
			print("pee")

func attack(picked_move) -> void:
	animation.play(picked_move)
	await animation.animation_finished

func disable_collisions() -> void:
	normal_target_collision.set_deferred("disabled", true)
	left_foot_collision.set_deferred("disabled", true)
	right_foot_collision.set_deferred("disabled", true)
	
#func _physics_process(delta: float) -> void:
	#if $"../Ball".global_position.distance_to(ground_pound_collision.global_position) >= 2.0 and $"../Ball".global_position.distance_to(ground_pound_collision.global_position) <= 2.1:
		#$"../Ball".freeze = true
