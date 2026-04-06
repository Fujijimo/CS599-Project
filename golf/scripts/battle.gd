extends Node3D

@onready var command_menu: VBoxContainer = $BattleHUD/CommandMenu
@onready var special_menu: VBoxContainer = $BattleHUD/SpecialMenu
@onready var item_menu: VBoxContainer = $BattleHUD/ItemMenu
@onready var attack: Button = $BattleHUD/CommandMenu/Attack
@onready var special: Button = $BattleHUD/CommandMenu/Special
@onready var items: Button = $BattleHUD/CommandMenu/Items
@onready var ability1: Button = $BattleHUD/SpecialMenu/Ability1
@onready var ability2: Button = $BattleHUD/SpecialMenu/Ability2
@onready var ability3: Button = $BattleHUD/SpecialMenu/Ability3
@onready var origin: Node3D = $Origin
@onready var ball: RigidBody3D = $Ball
@onready var ground_pound_target: Area3D = $Enemy/GroundPoundTarget
@onready var player_cam: Camera3D = $Origin/SpringArm3D/PlayerCam

signal player_turn_change

func _ready() -> void:
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
	if state.turn == state.Turns.ENEMY_TURN:
		enemy_turn()

func battle_setup():
	if state.turn == state.Turns.PLAYER_TURN:
		player_cam.current = true
		command_menu.show()
		set_input(false)
		disable_collisions()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func enemy_turn():
	ground_pound_target.hide()
	state.turn = state.Turns.PLAYER_TURN
	player_turn_change.emit()

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
	ground_pound_target.show()
	enable_collisions(ground_pound_target)
	set_input(true)

func ability2_button_pressed():
	print("ability2")
	
func ability3_button_pressed():
	print("ability3")

func item_button_pressed(button: Button):
	pass

func prepare_item_menu():
	for item in inventory.items:
		if item.data.usable == true:
			var usable_item: Button = Button.new()
			usable_item.text = item.data.name
			if item.data.amount > 1:
				usable_item.text += (" x" + str(item.data.amount))
				
			usable_item.pressed.connect(item_button_pressed.bind(usable_item))
			item_menu.add_child(usable_item)
			
func disable_collisions():
	for collision in ground_pound_target.get_children():
		if collision is CollisionShape3D:
			collision.set_deferred("disabled", true)

func enable_collisions(target: Area3D):
	for collision in target.get_children():
		if collision is CollisionShape3D:
			collision.set_deferred("disabled", false)

func set_input(input: bool):
	origin.set_process_unhandled_input(input)
	ball.set_physics_process(input)

func _on_player_turn_change() -> void:
	battle_setup()
