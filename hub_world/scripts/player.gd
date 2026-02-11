extends CharacterBody3D

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)
@onready var camera = $CameraPivot/SpringArm3D/Camera3D
const SPEED = 5.0
const SPRINT_SPEED = 15.0
const JUMP_VELOCITY = 4.5*2

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta: float) -> void:
	if is_on_floor() == false:
		velocity += get_gravity() * delta
		
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	
	if velocity.x != 0 and velocity.z != 0:
		$MeshInstance3D.rotation.y = lerp_angle($MeshInstance3D.rotation.y,atan2(velocity.x,velocity.z),0.25)
		
	if direction:
		if Input.is_action_pressed("sprint") and is_on_floor():
			velocity.x = direction.x * SPRINT_SPEED
			velocity.z = direction.z * SPRINT_SPEED
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	if Input.is_joy_known(0) == true:
		var cam_input_dir = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
		var cam_sensitivity = 0.075
	
		$CameraPivot.rotation.x -= cam_input_dir.y * cam_sensitivity
		$CameraPivot.rotation.x = clampf($CameraPivot.rotation.x, deg_to_rad(-89), deg_to_rad(45))
		$CameraPivot.rotation.y -= cam_input_dir.x * cam_sensitivity
	
func _unhandled_input(event: InputEvent) -> void:
	capture_mouse(event)
	hub_camera(event)
	if Input.is_action_pressed("save"):
		save_game()
	if Input.is_action_pressed("load"):
		load_game()

func hub_camera(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$CameraPivot.rotation.x -= event.relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		$CameraPivot.rotation.x = clampf($CameraPivot.rotation.x, deg_to_rad(-89), deg_to_rad(45))
		$CameraPivot.rotation.y -= event.relative.x * mouse_sensitivity

func capture_mouse(event):
	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func save_game() -> void:
	saveload.data.global_position = global_position
	saveload.write_savegame()
	
func load_game() -> void:
	saveload.load_savegame()
	global_position = saveload.data.global_position
