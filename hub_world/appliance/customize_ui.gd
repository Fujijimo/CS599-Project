class_name customization
extends Control

@onready var accessory_selector = $AccessoryProperties/HBoxContainer/AccessorySelector
@onready var mesh_selector = $AccessoryProperties/MeshSelector
@onready var ball_tracker = $"../BallTracker"
@onready var ball_model = $"../BallTracker/BallModel"

@onready var accessory_dict: Dictionary = {
	0:{"name":"None","mesh":%Accessories/None},
	1:{"name":"Monkey","mesh":%Accessories/Monkey},
	2:{"name":"GorfCube","mesh":%Accessories/GorfCube},
}

var ball_tracker_clone: Node3D

func _ready() -> void:
	$AccessoryProperties/AccessoryRotation/XSlider.value = 0
	$AccessoryProperties/AccessoryRotation/YSlider.value = 0
	$AccessoryProperties/AccessoryRotation/ZSlider.value = 0

func customize() -> void:
	var new_color: Color = Color(
		$ColorProperties/RedSlider.value,
		$ColorProperties/GreenSlider.value,
		$ColorProperties/BlueSlider.value,
	)
	
	var mesh_position: Vector3 = Vector3(
		-$AccessoryProperties/AccessoryPosition/XSlider.value,
		$AccessoryProperties/AccessoryPosition/YSlider.value,
		$AccessoryProperties/AccessoryPosition/ZSlider.value,
		)
	var mesh_rotation: Vector3 = Vector3(
		$AccessoryProperties/AccessoryRotation/XSlider.value,
		$AccessoryProperties/AccessoryRotation/YSlider.value,
		$AccessoryProperties/AccessoryRotation/ZSlider.value,
		)
	var mesh_scale: Vector3 = Vector3(
		$AccessoryProperties/AccessoryScale/XSlider.value,
		$AccessoryProperties/AccessoryScale/YSlider.value,
		$AccessoryProperties/AccessoryScale/ZSlider.value,
		)
	
	if ball_model.get_child_count() != 0:
		ball_model.get_child(0).position = mesh_position
		ball_model.get_child(0).rotation = mesh_rotation
		ball_model.get_child(0).scale = mesh_scale
	
	ball_model.mesh.material.albedo_color = Color(new_color.r,new_color.g,new_color.b)
	
	$ColorProperties/RedValueLabel.text = str("%0.2f" % new_color.r)
	$ColorProperties/GreenValueLabel.text = str("%0.2f" % new_color.g)
	$ColorProperties/BlueValueLabel.text = str("%0.2f" % new_color.b)
	$AccessoryProperties/AccessoryPosition/XValueLabel.text = str("%0.2f" % (mesh_position.x*-1))
	$AccessoryProperties/AccessoryPosition/YValueLabel.text = str("%0.2f" % mesh_position.y)
	$AccessoryProperties/AccessoryPosition/ZValueLabel.text = str("%0.2f" % mesh_position.z)
	$AccessoryProperties/AccessoryRotation/XValueLabel.text = str("%0.2f" % mesh_rotation.x)
	$AccessoryProperties/AccessoryRotation/YValueLabel.text = str("%0.2f" % mesh_rotation.y)
	$AccessoryProperties/AccessoryRotation/ZValueLabel.text = str("%0.2f" % mesh_rotation.z)
	$AccessoryProperties/AccessoryScale/XValueLabel.text = str("%0.2f" % mesh_scale.x)
	$AccessoryProperties/AccessoryScale/YValueLabel.text = str("%0.2f" % mesh_scale.y)
	$AccessoryProperties/AccessoryScale/ZValueLabel.text = str("%0.2f" % mesh_scale.z)
	
	
	if $Categories.current_tab == 0:
		$ColorProperties.show()
		$AccessoryProperties.hide()
	else:
		$ColorProperties.hide()
		$AccessoryProperties.show()

func _on_add_pressed() -> void:
	var accessory = Accessory.new()
	ball_model.add_child(accessory)
	accessory.data.id += 1
	accessory_selector.add_item(str("Accessory ", accessory_selector.item_count), accessory.data.id)
	accessory_selector.select(accessory_selector.get_item_index(accessory.data.id))

func _on_remove_pressed() -> void:
	var index = accessory_selector.get_item_index(accessory_selector.get_selected_id())
	if accessory_selector.get_selected_id() != 0:
		accessory_selector.remove_item(index)
		accessory_selector.select(index - 1)
		for i in range(1, accessory_selector.item_count):
			accessory_selector.set_item_text(i, str("Accessory ", i))

func _on_mesh_selector_pressed() -> void:
	var index = mesh_selector.get_item_index(mesh_selector.get_selected_id())
	mesh_selector.clear()
	for i in range(accessory_dict.keys().size()):
		mesh_selector.add_item(accessory_dict[i].name, accessory_dict.keys()[i])
	mesh_selector.select(index)
	
func _on_mesh_selector_item_selected(index: int) -> void:
	var id = mesh_selector.get_item_id(index)
	if ball_model.get_child_count() != 0:
		ball_model.remove_child(ball_model.get_child(0))
	if accessory_dict[id].mesh != null:
		var new_mesh = accessory_dict[id].mesh.duplicate()
		ball_model.add_child(new_mesh)

func _on_save_button_pressed() -> void:
	save_accessories()

func save_accessories():
	var save = PackedScene.new()
	for i in ball_tracker.get_children():
		i.set_owner(ball_tracker)
		for j in i.get_children():
			j.set_owner(ball_tracker)
		save.pack(ball_tracker);
		ResourceSaver.save(save, "res://golf/scenes/ball_tracker.tscn");
