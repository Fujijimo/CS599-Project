extends CharacterBody3D

@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.01
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var dialogue_ui: CanvasLayer = $"../DialogueUI"
@onready var scroller = $"../LevelSelectCam/Scroller"
@onready var scroller_label = $"../LevelSelectCam/Scroller/Label"
const SPEED: float = 5.0
const SPRINT_SPEED: float = 15.0
const JUMP_VELOCITY: float = 4.5*2
var mode: String = "hub"
var dialogue_data: Dictionary
var end_dialogue_timer: Timer = Timer.new()
var timeout: bool = false
var already_in_inventory: bool = false

const INTERACT_MARKER: Resource = preload("res://interact_marker.tscn")
var interact_marker_instance: MeshInstance3D = INTERACT_MARKER.instantiate()
var interactable: Node3D
var last_interactable: Node3D

var customize_focused: bool = false
var inventory_open = true

signal toggle_inventory()
signal pickup()

func _ready() -> void:
	var file = FileAccess.open("res://hub_world/dialogue.json", FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue file")
		return
	var content = file.get_as_text()
	dialogue_data = JSON.parse_string(content)
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	end_dialogue_timer.timeout.connect(_on_end_dialogue_timer_timeout)
	add_child(end_dialogue_timer)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	scroller.process_mode = Node.PROCESS_MODE_DISABLED
	
func _physics_process(delta: float) -> void:
	mode_setup(delta)
	enable_interaction()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory") and (mode == "hub" or mode == "inventory"):
		toggle_inventory.emit()
	elif Input.is_action_just_pressed("ui_cancel") and mode == "inventory":
		toggle_inventory.emit()

func _unhandled_input(event: InputEvent) -> void:
	capture_mouse(event)
	hub_camera(event)
	if Input.is_action_pressed("save"):
		save_game()
	if Input.is_action_pressed("load"):
		load_game()

func hub_camera(event):
	if mode == "hub":
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

func mode_setup(delta) -> void:
	match mode:
		"hub":
			mode_hub(delta)
		"level_select":
			mode_level_select(delta)
		"customize":
			mode_customize()
		"inventory":
			pass

func mode_hub(delta) -> void:
	$CameraPivot/SpringArm3D/Camera3D.current = true
	if is_on_floor() == false:
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	
	if Input.is_joy_known(0) == true:
		var cam_input_dir = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
		var camera_sensitivity = 0.065
	
		$CameraPivot.rotation.x -= cam_input_dir.y * camera_sensitivity
		$CameraPivot.rotation.x = clampf($CameraPivot.rotation.x, deg_to_rad(-89), deg_to_rad(45))
		$CameraPivot.rotation.y -= cam_input_dir.x * camera_sensitivity
	
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

func mode_level_select(delta) -> void:
	$"../LevelSelectCam".current = true
	scroller.visible = true
	scroller_label.visible = true
	
	scroller.level_select_input(delta)
	if Input.is_action_just_pressed("ui_cancel"):
		$"../LevelSelectCam".current = false
		scroller.visible = false
		scroller_label.visible = false
		mode = "hub"

func mode_customize() -> void:
	if customize_focused == false:
		%CustomizeCam/CustomizeUI/Categories.grab_focus()
		customize_focused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	%CustomizeCam.current = true
	%CustomizeCam/BallTracker.show()
	%CustomizeCam/CustomizeUI.show()
	%CustomizeCam/CustomizeUI.customize()
	if Input.is_action_just_pressed("ui_cancel"):
		customize_focused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		%CustomizeCam.current = false
		%CustomizeCam/BallTracker.hide()
		%CustomizeCam/CustomizeUI.hide()
		mode = "hub"

func save_game() -> void:
	saveload.data.global_position = global_position
	saveload.write_savegame()
	
func load_game() -> void:
	saveload.load_savegame()
	global_position = saveload.data.global_position

func enable_interaction() -> void:
	if $DetectInteractable.has_overlapping_bodies() and $"../Inventory".visible == false:
		var new_array: Array[float]
		var new_index: int
		
		if $DetectInteractable.get_overlapping_bodies().size() > 1:
			for i in $DetectInteractable.get_overlapping_bodies():
				new_array.append(position.distance_to(i.position))
				new_index = new_array.find(new_array.min())
				interactable = $DetectInteractable.get_overlapping_bodies().get(new_index)
		else:
			interactable = $DetectInteractable.get_overlapping_bodies().get(0)
			
		if last_interactable != interactable:
			if is_instance_valid(interact_marker_instance):
				interact_marker_instance.queue_free()
			
		if interactable.is_in_group("interactable") and is_instance_valid(interact_marker_instance) == false:
			interact_marker_instance = INTERACT_MARKER.instantiate()
			interactable.get_parent().add_child(interact_marker_instance)
			if interactable.is_in_group("pickup"):
				interact_marker_instance.global_position = interactable.global_position + Vector3(0, interactable.data.marker_height, 0)
			if interactable.is_in_group("dialogue"):
				interact_marker_instance.global_position = interactable.global_position + Vector3(0, interactable.npc.marker_height, 0)
			if interactable.is_in_group("appliance"):
				interact_marker_instance.global_position = interactable.global_position + Vector3(0, interactable.appliance.marker_height, 0)
			last_interactable = interactable
		
		if interactable.is_in_group("pickup"):
			enable_pickup()
			
		if interactable.is_in_group("dialogue"):
			enable_dialogue()
		
		if interactable.is_in_group("appliance"):
			enable_appliance()
	
	elif last_interactable != null:
		if is_instance_valid(interact_marker_instance):
				interact_marker_instance.queue_free()

func enable_pickup() -> void:
	if $DetectInteractable.overlaps_body(interactable) and Input.is_action_just_pressed("interact"):
		for item in inventory.items:
			if interactable.data.name == item.data.name:
				already_in_inventory = true
				if interactable.data.stackable == true:
					item.data.amount += 1
					break
				else:
					inventory.items.append(interactable.duplicate())
					break
		if already_in_inventory == false:
			inventory.items.append(interactable.duplicate())
			inventory.items[inventory.items.size() - 1].data.amount += 1
		else:
			already_in_inventory = false
		print(inventory.items)
		if is_instance_valid(interact_marker_instance):
			interact_marker_instance.queue_free()
		interactable.queue_free()
		pickup.emit()

func enable_dialogue() -> void:
	if $DetectInteractable.overlaps_body(interactable) and Input.is_action_just_pressed("interact"):
		self.set_process_unhandled_input(false)
		self.set_physics_process(false)
		dialogue_ui.start(dialogue_data, interactable.npc.dialogue_id)

func enable_appliance() -> void:
	if $DetectInteractable.overlaps_body(interactable) and Input.is_action_just_pressed("interact"):
		if interactable.appliance.mode != "":
			mode = interactable.appliance.mode

func _on_dialogue_finished():
	timeout = true
	end_dialogue_timer.start(0.1)

func _on_end_dialogue_timer_timeout():
	if timeout == true:
		self.set_process_unhandled_input(true)
		self.set_physics_process(true)
		timeout = false

func _on_inventory_inventory_open() -> void:
	if mode == "hub":
		mode = "inventory"

func _on_inventory_inventory_closed() -> void:
	if mode == "inventory":
		mode = "hub"
