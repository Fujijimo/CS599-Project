extends Node3D

signal enemy_attacking
signal player_turn_change
signal win

const MAX_HEALTH: int = 100

var health: int = MAX_HEALTH
var amount: int
var enemy_number: int = randi_range(1, 3)
var enemies: Array[Node]
var mode_check: Array[String]
var enemy_scene: Resource = preload("res://golf/scenes/battle_enemy.tscn")
var enemy_instance: CharacterBody3D
var cam_enemy: CharacterBody3D
var cam_target: Vector3
var oneshot: bool = false

@onready var command_menu: VBoxContainer = $BattleHUD/CommandMenu
@onready var special_menu: VBoxContainer = $BattleHUD/SpecialMenu
@onready var item_menu: VBoxContainer = $BattleHUD/ItemMenu
@onready var attack: Button = $BattleHUD/CommandMenu/Attack
@onready var special: Button = $BattleHUD/CommandMenu/Special
@onready var items: Button = $BattleHUD/CommandMenu/Items
@onready var no_items: Label = $BattleHUD/NoItems
@onready var ability1: Button = $BattleHUD/SpecialMenu/Ability1
@onready var ability2: Button = $BattleHUD/SpecialMenu/Ability2
@onready var ability3: Button = $BattleHUD/SpecialMenu/Ability3
@onready var origin: Node3D = $Origin
@onready var ball: RigidBody3D = $Ball
@onready var player_cam: Camera3D = $Origin/SpringArm3D/PlayerCam

func _ready() -> void:
	spawn_enemies()
	attack.pressed.connect(attack_button_pressed)
	special.pressed.connect(special_button_pressed)
	items.pressed.connect(items_button_pressed)
	ability1.pressed.connect(ability1_button_pressed)
	ability2.pressed.connect(ability2_button_pressed)
	ability3.pressed.connect(ability3_button_pressed)
	prepare_item_menu()
	battle_setup()

func _process(_delta):
	if special_menu.is_visible() or item_menu.is_visible():
		if Input.is_action_just_pressed("cancel"):
			special_menu.hide()
			item_menu.hide()
			command_menu.show()
	#if ability1.is_hovered():
		#ground_pound_target.show()
	#else:
		#ground_pound_target.hide()
	if item_menu.get_child_count() == 0 and item_menu.visible == true:
		no_items.show()
	else:
		no_items.hide()
	
	enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty() and oneshot == false:
		state.turn = state.Turns.NO_TURN
		win.emit()

func _physics_process(_delta: float) -> void:
	if state.turn == state.Turns.ENEMY_TURN:
		enemy_turn()
	if cam_enemy != null and state.turn == state.Turns.ENEMY_TURN:
		$BattleCam.global_position = lerp($BattleCam.global_position, cam_target, 0.1)
		$BattleCam.look_at(cam_enemy.global_position)

func set_enemy_target_position(x) -> void:
	var spread = 100
	x.target_position = Vector3(randf_range(-spread, spread), 0, randf_range(-spread, spread))

func spawn_enemies() -> void:
	var distance: float = 30
	var angle: float = -10
	for enemy in enemy_number:
		enemy_instance = enemy_scene.instantiate()
		add_child(enemy_instance, true)
		angle += 10
		enemy_instance.position = Vector3(distance * cos(rad_to_deg(angle)), 0, distance * sin(rad_to_deg(angle)))
		set_enemy_target_position(enemy_instance)
		enemy_instance.look_at(ball.position, Vector3.UP, true)

func battle_setup() -> void:
	if state.turn == state.Turns.PLAYER_TURN:
		for node in get_children():
			if node is CharacterBody3D:
				node.get_node("NormalTarget/NormalTargetCollision").set_deferred("disabled", false)
				node.get_node("LowTarget/LeftFootCollision").set_deferred("disabled", false)
				node.get_node("LowTarget/RightFootCollision").set_deferred("disabled", false)
				node.get_node("GroundPoundTarget").hide()
		player_cam.current = true
		command_menu.show()
		set_input(false)
		#disable_collisions()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func enemy_turn() -> void:
	#ground_pound_target.hide()
	for enemy in enemies:
		if is_instance_valid(enemy) == false or enemy.health < 0:
			continue
			
		if enemy.mode == "Move":
			var direction = enemy.position.direction_to(ball.global_position + enemy.target_position)
			var speed = enemy.position.distance_to(ball.global_position + enemy.target_position)
			
			enemy.velocity = direction * speed
			enemy.move_and_slide()
			enemy.animation_import.play("Walk")
			
			if enemy.velocity.x != 0 and enemy.velocity.z != 0:
				enemy.rotation.y = lerp_angle(enemy.rotation.y,atan2(enemy.velocity.x,enemy.velocity.z),0.25)
			
			if enemy.position.distance_to(ball.global_position + enemy.target_position) <= 10:
				enemy.animation_import.stop()
				enemy.mode = "Attack"
			
		if enemy.mode == "Attack" and enemy.health > 0:
			enemy.look_at(ball.position, Vector3.UP, true)
			
		mode_check.append(enemy.mode)
			
	if mode_check.all(attack_check) == true and oneshot == false:
		enemy_attacking.emit()
	if mode_check.all(idle_check) == true:
		state.turn = state.Turns.PLAYER_TURN
		player_turn_change.emit()
		
	mode_check.clear()

func attack_check(enemy_mode) -> bool:
	return enemy_mode == "Attack"

func idle_check(enemy_mode) -> bool:
	return enemy_mode == "Idle"

func attack_button_pressed():
	command_menu.hide()
	set_input(true)

func special_button_pressed():
	command_menu.hide()
	special_menu.show()

func items_button_pressed():
	command_menu.hide()
	item_menu.show()

func ability1_button_pressed():
	special_menu.hide()
	for node in get_children():
		if node is CharacterBody3D:
			node.get_node("GroundPoundTarget").show()
	#ground_pound_target.show()
	#enable_collisions(ground_pound_target)
	set_input(true)

func ability2_button_pressed():
	print("ability2")
	
func ability3_button_pressed():
	print("ability3")

func item_button_pressed(button: Button):
	if button.text.begins_with("Health Potion"):
		health += 100
		remove_item("Health Potion")
		button.text = "Health Potion x" + str(amount)
	if button.text.begins_with("Monkey Ball"):
		health -= 100
		remove_item("Monkey Ball")
		button.text = "Monkey Ball x" + str(amount)
	if amount == 0:
		button.queue_free()

func prepare_item_menu():
	for item in inventory.items:
		if item.data.usable == true:
			var usable_item: Button = Button.new()
			usable_item.text = item.data.name
			if item.data.amount > 1:
				usable_item.text += (" x" + str(item.data.amount))
				
			usable_item.pressed.connect(item_button_pressed.bind(usable_item))
			item_menu.add_child(usable_item)

#func disable_collisions():
	#for collision in ground_pound_target.get_children():
		#if collision is CollisionShape3D:
			#collision.set_deferred("disabled", true)

func enable_collisions(target: Area3D):
	for collision in target.get_children():
		if collision is CollisionShape3D:
			collision.set_deferred("disabled", false)

func remove_item(item_name: String):
	for item in inventory.items:
		if item.data.name == item_name:
			item.data.amount -= 1
			amount = item.data.amount
			if item.data.amount == 0:
				inventory.items.erase(item)

func set_input(input: bool):
	origin.set_process_unhandled_input(input)
	ball.set_physics_process(input)

func _on_player_turn_change() -> void:
	battle_setup()

func _on_ball_next_stroke() -> void:
	state.turn = state.Turns.ENEMY_TURN
	for enemy in enemies:
		if is_instance_valid(enemy) == false or enemy.health < 0:
			continue
			
		set_enemy_target_position(enemy)
		enemy.mode = "Move"

func _on_enemy_attacking() -> void:
	oneshot = true
	set_input(false)
	$BattleCam.make_current()
	
	for enemy in enemies:
		if is_instance_valid(enemy) == false or enemy.health < 0:
			continue
		
		var picked_move = enemy.move.pick_random()
		
		$BattleHUD/BattleStatus.text = "Enemy uses " + picked_move + "!"
		cam_enemy = enemy
		cam_target = Vector3(
			randf_range(cam_enemy.global_position.x - 30, cam_enemy.global_position.x + 30), 
			randf_range(cam_enemy.global_position.y + 10, cam_enemy.global_position.y + 30), 
			randf_range(cam_enemy.global_position.z - 30, cam_enemy.global_position.z + 30)
		)
		await enemy.attack(picked_move)
		enemy.mode = "Idle"
	
	$BattleHUD/BattleStatus.text = ""
	oneshot = false

func _on_win() -> void:
	oneshot = true
	set_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$BattleHUD/WinMenu.show()
	await $BattleHUD/WinMenu/Button.pressed
	oneshot = false
