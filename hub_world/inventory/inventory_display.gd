extends Control

const ITEM_SLOT = preload("res://hub_world/inventory/item_slot.tscn")
@onready var inventory_v_box: VBoxContainer = $HBoxContainer/ScrollContainer/InventoryVBox

@onready var details_name: Label = $HBoxContainer/DetailsScreen/MarginContainer/VBoxContainer/DetailsName
@onready var details_description: Label = $HBoxContainer/DetailsScreen/MarginContainer/VBoxContainer/DetailsDescription
var index: int = 0

func _ready() -> void:
	for i in inventory_v_box.get_children():
		i.queue_free()
		

func _process(_delta) -> void:
	pass
	#await inventory.item_pick_up
	#add_to_inventory()

func button_pressed(button_item: ItemSlot):
	print(button_item)
	details_name.text = button_item.item_name
	details_description.text = button_item.item_description

func add_to_inventory():
	var new_item: ItemSlot = ITEM_SLOT.instantiate()
	new_item.item_name = inventory.items[index].item.name
	new_item.item_description = inventory.items[index].item.description
	new_item.basic_description = inventory.items[index].item.basic_description
	new_item.texture = inventory.items[index].item.texture
		
	new_item.pressed.connect(button_pressed.bind(new_item))
		
	inventory_v_box.add_child(new_item)
