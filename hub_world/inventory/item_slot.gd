extends Button
class_name ItemSlot

@onready var texture_rect: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/Name
@onready var name_details_label: Label = $"../../../DetailsScreen/MarginContainer/VBoxContainer/DetailsName"
@onready var basic_description_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/BasicDescription
@onready var description_label: Label = $"../../../DetailsScreen/MarginContainer/VBoxContainer/DetailsDescription"

@export var texture: Texture2D
@export var item_name: String
@export var basic_description: String
@export var item_description: String

func _ready() -> void:
	texture_rect.texture = texture
	name_label.text = item_name
	name_details_label.text = item_name
	basic_description_label.text = basic_description
	description_label.text = item_description
