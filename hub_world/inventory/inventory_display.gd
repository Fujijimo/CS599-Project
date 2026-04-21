extends Control

signal inventory_open
signal inventory_closed

const ITEM_SLOT = preload("res://hub_world/inventory/item_slot.tscn")

@onready var inventory_v_box: VBoxContainer = $HBoxContainer/ScrollContainer/InventoryVBox
@onready var details_name: Label = $HBoxContainer/DetailsScreen/MarginContainer/VBoxContainer/DetailsName
@onready var details_description: Label = $HBoxContainer/DetailsScreen/MarginContainer/VBoxContainer/DetailsDescription

func _ready() -> void:
	refresh_inventory()

func button_pressed(button_item: ItemSlot):
	details_name.text = button_item.item_name
	details_description.text = button_item.item_description

func add_to_inventory():
	for item in inventory.items:
		var new_item: ItemSlot = ITEM_SLOT.instantiate()
		new_item.item_name = item.data.name
		new_item.item_description = item.data.description
		new_item.basic_description = item.data.basic_description
		new_item.texture = item.data.texture
		
		new_item.pressed.connect(button_pressed.bind(new_item))
	
		inventory_v_box.add_child(new_item)

func refresh_inventory():
	if visible == false:
		for i in inventory_v_box.get_children():
			inventory_v_box.remove_child(i)
			i.queue_free()
		add_to_inventory()

func _on_player_pickup() -> void:
	refresh_inventory()

func _on_player_toggle_inventory() -> void:
	if visible == false:
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		inventory_open.emit()
	elif visible == true:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		inventory_closed.emit()
