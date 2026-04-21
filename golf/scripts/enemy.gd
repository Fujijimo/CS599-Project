extends CharacterBody3D

const SPEED: float = 5.0

var distance_to_start: float
var start_position: Vector3
var direction: Vector3
var direction_picked: bool = false
var field_state: String = "wander"
var field_state_list: Array = ["idle", "wander"]

@export var max_distance: float = 10.0
@export var idle_time: float = 5.0
@export var wander_time: float = 5.0

func _ready() -> void:
	start_position = position
	set_state()

func _physics_process(delta: float) -> void:
	distance_to_start = position.distance_to(start_position)
	match field_state:
		"idle":
			state_idle()
		"wander":
			state_wander()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if velocity.x != 0 and velocity.z != 0:
		rotation.y = lerp_angle(rotation.y,atan2(velocity.x,velocity.z),0.25)
		
	move_and_slide()
	
func set_state():
	while true:
		await get_tree().create_timer(wander_time).timeout
		field_state = "idle"
		direction_picked = false
		await get_tree().create_timer(idle_time).timeout
		field_state = "wander"

func state_idle():
	velocity = Vector3.ZERO
	$dh_orange/AnimationPlayer.stop()

func state_wander():
	pick_direction()
	
	$dh_orange/AnimationPlayer.play("Walk")
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func pick_direction():
	if direction_picked == false:
		if distance_to_start > max_distance:
			direction = Vector3(start_position.x - position.x, 0, start_position.z - position.z).normalized()
		else:
			direction = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
		direction_picked = true
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Ball":
		visible = false
		body.animation.play("Attack")
	
		Engine.time_scale = 0.1
		await get_tree().create_timer(0.1).timeout
		Engine.time_scale = 1.0
		
		body.ability_used.jump += 2
		body.ability_used.air_control += 2.0
		
		queue_free()
		
		get_tree().change_scene_to_file("res://golf/scenes/battle.tscn")
