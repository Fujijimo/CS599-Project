extends RigidBody3D

@onready var strength_meter: CanvasLayer = $"../HUD"
@onready var progress_bar: ProgressBar = $"../HUD/ProgressBar"
@onready var origin: Node3D = $"../Origin"
@onready var raycast: RayCast3D = $"../BallTracker/RayCast3D"
@onready var animation: AnimationPlayer = $"../BallTracker/AnimationPlayer"
@onready var hit_buffer: Timer = $HitBuffer
var stroke: int = 0
var swing_phase: int = 0
var swung_already: bool = false
var touched_floor: bool = false
var touched: bool = true
var club_list: Array = ["Driver", "Putter"]
var club: String = "Driver"
var strength: float = 0.0
var curve: float = 0.0
var apply_wind: bool = false
var wind_modifier: float = randf_range(0.0, 12.0)
var wind_direction: Vector3
var wind_speed: float
var last_basis: Basis
var last_origin: Vector3
var state_copy: PhysicsDirectBodyState3D
var dropping: bool = false
var hit_buffer_timeout: bool = true
var ability_limit: Dictionary = {
	"drop": 1,
	"jump": 3,
	"air_control": 4.0,
}
var ability_used: Dictionary

func _ready() -> void:
	set_wind_direction()
	next_stroke_setup()

func _process(_delta):
	club_select()

func _physics_process(delta):
	swing(delta)
	decelerate_ball_and_end_stroke()

func _integrate_forces(state):
	state_copy = state
	if position.y <= -30.0:
		freeze = true
		state.transform = Transform3D(last_basis, last_origin)
		next_stroke_setup()

func club_select():
	if Input.is_action_just_pressed("select_club_up"):
		club = "Driver"
	if Input.is_action_just_pressed("select_club_down"):
		club = "Putter"

func swing(delta):
	if swing_phase == 1:
		strength_meter.hit_timer_play("strength_meter")
	
	if Input.is_action_just_pressed("cancel") and swung_already == false:
		swing_phase = 0
		strength_meter.hit_timer_stop()
		progress_bar.value = 0
		
	if Input.is_action_just_pressed("hit") and swung_already == false:
		match swing_phase:
			0:
				get_last_position()
				swing_phase = 1
			1:
				strength_meter.hit_timer_stop()
				$"../BallTracker/SFXHit".play()
				strength = progress_bar.value
				freeze = false
				club_hit(club)
				hit_buffer.start()
				apply_wind = true
				swung_already = true
				swing_phase = 2
				#strength_meter.set_curve_timer_value()
				#strength_meter.hit_timer_play("curve_meter")
			#2:
				#strength_meter.hit_timer_stop()
				#if get_node("../HUD/Control/ProgressBar2").value > 0:
					#curve = get_node("../HUD/Control/ProgressBar2").valueClick to View Comme
				#else:
					#curve = -get_node("../HUD/Control/ProgressBar").value
					#if curve < -10.0:
						#curve = -10.0
				#club_hit(club)
				#swing_phase = 0
				#swung_already = true
	if swing_phase == 2:
		ability_drop()
		ability_jump()
		ability_air_control(delta)

func club_hit(_club):
	match club: 
		"Driver":
			#apply_torque(Vector3(0, 0, 40))
			apply_impulse(Vector3(-origin.basis.z.x * strength, strength, -origin.basis.z.z * strength))
		"Putter":
			apply_impulse(Vector3(-origin.basis.z.x * strength, 3, -origin.basis.z.z * strength))

func ability_drop():
	if ability_used.drop != 0:
		if Input.is_action_just_pressed("ability1") and touched == false and dropping == false:
			apply_wind = false
			linear_velocity *= Vector3.ZERO
			gravity_scale = 50.0
			physics_material_override.bounce = 0
			dropping = true
			ability_used.drop -= 1
	if dropping == true and touched == true:
		$"../BallTracker/SFXDrop".play()
		next_stroke_setup()

func ability_jump():
	var jump_height: float = 50.0
	if ability_used.jump != 0:
		if Input.is_action_just_pressed("ability2") and dropping == false:
			apply_central_impulse(Vector3(0,-linear_velocity.y + jump_height,0))
			animation.stop()
			animation.play("Jump")
			ability_used.jump -= 1

func ability_air_control(delta):
	var air_speed: float = 30.0
	var controlling: bool = false
	if touched == false and ability_used.air_control >= 0.01 and dropping == false:
		if Input.is_action_pressed("move_up"):
			apply_central_impulse(Vector3(-origin.basis.z.x * air_speed, 0, -origin.basis.z.z * air_speed) * delta)
			controlling = true
		if Input.is_action_pressed("move_down"):
			apply_central_impulse(Vector3(origin.basis.z.x * air_speed, 0, origin.basis.z.z * air_speed) * delta)
			controlling = true
		if Input.is_action_pressed("move_left"):
			apply_central_impulse(Vector3(-origin.basis.x.x * air_speed, 0, -origin.basis.x.z * air_speed) * delta)
			controlling = true
		if Input.is_action_pressed("move_right"):
			apply_central_impulse(Vector3(origin.basis.x.x * air_speed, 0, origin.basis.x.z * air_speed) * delta)
			controlling = true
			
	if controlling == true:
		ability_used.air_control -= delta

func decelerate_ball_and_end_stroke():
	if touched == true and swung_already == true and hit_buffer_timeout == false:
		if club == "Driver":
			linear_damp += 0.01
			if (linear_velocity <= Vector3(0.4, 0.0, 0.0) and linear_velocity.z >= -1.0) or (linear_velocity <= Vector3(0.0, 0.0, 0.4) and linear_velocity.x >= -1.0):
				linear_damp += 0.1
			if linear_damp >= 20.0:
				next_stroke_setup()
		if club == "Putter":
			linear_damp += 0.005
			if linear_damp >= 4.0:
				next_stroke_setup()
	if raycast.is_colliding() == false:
		touched = 0
		linear_damp = 0.0
	if touched == true or apply_wind == false:
		constant_force = Vector3.ZERO
	else:
		constant_force = wind_direction * wind_modifier
	#if swung_already == true and (linear_velocity <= Vector3(0.05, 0.0, 0.05) or linear_velocity >= Vector3(-0.05, -0.05, -0.05)):

func next_stroke_setup():
	freeze = true
	touched = 1
	linear_damp = 0.0
	gravity_scale = 5.0
	linear_velocity *= Vector3.ZERO
	angular_velocity *= Vector3.ZERO
	apply_wind = false
	swung_already = false
	touched_floor = false
	physics_material_override.bounce = 0.4
	dropping = false
	hit_buffer_timeout = true
	ability_used = ability_limit.duplicate()
	strength_meter.hit_timer_reset()
	origin.position = lerp(origin.position, position, 0.1)
	stroke += 1
	swing_phase = 0

func set_wind_direction():
	wind_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	wind_speed = (abs(wind_direction.x) + abs(wind_direction.z)) * wind_modifier

func get_last_position():
	last_basis = basis
	last_origin = position

func _on_body_entered(_body: Node3D) -> void:
	touched = 1
	if linear_velocity.y > 1.75 and hit_buffer_timeout == false:
		$"../BallTracker/SFXBounce".volume_db = -50.0 / linear_velocity.y
		$"../BallTracker/SFXBounce".play()

func _on_hit_buffer_timeout() -> void:
	hit_buffer_timeout = false

#func ball_curve(curve_multiplier):
	#var radius = 0.1;
	#var air_density = 1.225;
	#var magnitude = (4.0 / 3.0) * PI * air_density * pow(radius, 3);
	#var magnus_force = magnitude * linear_velocity.cross(angular_velocity);
	#if touched == 1:
		#touched_floor = true
	#if touched_floor == false:
		#apply_force(curve_multiplier * magnus_force)
