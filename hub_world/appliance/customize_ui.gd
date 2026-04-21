class_name customization
extends Control

var accessory: Accessory
var ball_tracker_clone: Node3D
var unique_id: int = 0

@onready var accessory_selector: OptionButton = $AccessoryProperties/HBoxContainer/AccessorySelector
@onready var mesh_selector: OptionButton = $AccessoryProperties/MeshSelector
@onready var ball_tracker: Node3D = $"../BallTracker"
@onready var ball_model: MeshInstance3D = $"../BallTracker/BallModel"
@onready var accessory_dict: Dictionary = {
	0: { "name": "None", "mesh": %Accessories/None },
	1: { "name": "Monkey", "mesh": %Accessories/Monkey },
	2: { "name": "GorfCube", "mesh": %Accessories/GorfCube },
}

func _ready() -> void:
	$ColorProperties/RedSlider.value = ball_model.mesh.material.albedo_color.r
	$ColorProperties/GreenSlider.value = ball_model.mesh.material.albedo_color.g
	$ColorProperties/BlueSlider.value = ball_model.mesh.material.albedo_color.b
	
	if ball_model.get_child_count() == 0:
		accessory = Accessory.new()
		ball_model.add_child(accessory, true)
		accessory_selector.add_item(str("Accessory ", accessory.data.id + 1), accessory.data.id)
	else:
		unique_id = ball_model.get_child(ball_model.get_child_count() - 1).data.id
		accessory = ball_model.get_child(0)
		load_meshes()
		mesh_selector.select(accessory.data.mesh_id)
		load_accessories()
		restore_values()

func customize() -> void:
	set_values()
	
	accessory.position = accessory.data.position
	accessory.rotation = accessory.data.rotation
	accessory.scale = accessory.data.scale
	
	var new_color: Color = Color(
		$ColorProperties/RedSlider.value,
		$ColorProperties/GreenSlider.value,
		$ColorProperties/BlueSlider.value,
	)
	
	ball_model.mesh.material.albedo_color = Color(new_color.r,new_color.g,new_color.b)
	$AccessoryProperties/AccessoryPosition/XValueLabel.text = str("%0.2f" % (accessory.data.position.x*-1))
	$AccessoryProperties/AccessoryPosition/YValueLabel.text = str("%0.2f" % accessory.data.position.y)
	$AccessoryProperties/AccessoryPosition/ZValueLabel.text = str("%0.2f" % accessory.data.position.z)
	$AccessoryProperties/AccessoryRotation/XValueLabel.text = str("%0.2f" % accessory.data.rotation.x)
	$AccessoryProperties/AccessoryRotation/YValueLabel.text = str("%0.2f" % accessory.data.rotation.y)
	$AccessoryProperties/AccessoryRotation/ZValueLabel.text = str("%0.2f" % accessory.data.rotation.z)
	$AccessoryProperties/AccessoryScale/XValueLabel.text = str("%0.2f" % accessory.data.scale.x)
	$AccessoryProperties/AccessoryScale/YValueLabel.text = str("%0.2f" % accessory.data.scale.y)
	$AccessoryProperties/AccessoryScale/ZValueLabel.text = str("%0.2f" % accessory.data.scale.z)
	
	$ColorProperties/RedValueLabel.text = str("%0.2f" % new_color.r)
	$ColorProperties/GreenValueLabel.text = str("%0.2f" % new_color.g)
	$ColorProperties/BlueValueLabel.text = str("%0.2f" % new_color.b)
	
	if $Tabs/Categories.current_tab == 0:
		$ColorProperties.show()
		$AccessoryProperties.hide()
	else:
		$ColorProperties.hide()
		$AccessoryProperties.show()

func _on_add_pressed() -> void:
	unique_id += 1
	accessory = Accessory.new()
	ball_model.add_child(accessory, true)
	accessory.data.id = unique_id
	accessory_selector.add_item(str("Accessory ", accessory.data.id + 1), accessory.data.id)
	accessory_selector.select(accessory_selector.get_item_index(accessory.data.id))
	mesh_selector.select(0)
	restore_values()

func _on_remove_pressed() -> void:
	var index: int = accessory_selector.get_item_index(accessory_selector.get_selected_id())
	if accessory_selector.get_selected_id() != 0:
		accessory_selector.remove_item(index)
		accessory_selector.select(index - 1)
		var temp: Accessory = accessory.get_parent().get_child(accessory.get_index() - 1)
		accessory.queue_free()
		accessory = temp
		for i in range(1, accessory_selector.item_count):
			accessory_selector.set_item_text(i, str("Accessory ", i))
		mesh_selector.select(accessory.data.mesh_id)
		restore_values()

func _on_accessory_selector_item_selected(index: int) -> void:
	accessory = accessory.get_parent().get_child(index)
	accessory.data.id = accessory_selector.get_item_id(index)
	if accessory.get_child_count() != 0:
		accessory.remove_child(accessory.get_child(0))
	if accessory_dict[accessory.data.mesh_id].mesh != null:
		var new_mesh: MeshInstance3D = accessory_dict[accessory.data.mesh_id].mesh.duplicate()
		accessory.add_child(new_mesh)
	mesh_selector.select(accessory.data.mesh_id)
	restore_values()

func _on_mesh_selector_pressed() -> void:
	load_meshes()
	
func _on_mesh_selector_item_selected(index: int) -> void:
	var id: int = mesh_selector.get_item_id(index)
	accessory.data.mesh_id = id
	if accessory.get_child_count() != 0:
		accessory.get_child(0).queue_free()
	if accessory_dict[id].mesh != null:
		var new_mesh: MeshInstance3D = accessory_dict[id].mesh.duplicate()
		accessory.add_child(new_mesh)

func _on_save_button_pressed() -> void:
	save_accessories()

func save_accessories() -> void:
	var save: PackedScene = PackedScene.new()
	for i in ball_tracker.find_children("*", "", true, false):
		i.set_owner(ball_tracker)
		for j in i.find_children("*", "", true, false):
			j.set_owner(ball_tracker)
		save.pack(ball_tracker);
		ResourceSaver.save(save, "res://golf/scenes/ball_tracker.tscn");

func load_accessories() -> void:
	for i in ball_model.get_children():
		accessory = i
		accessory_selector.add_item(str("Accessory ", accessory.data.id + 1), accessory.data.id)
	accessory = ball_model.get_child(0)

func load_meshes() -> void:
	var index: int = mesh_selector.get_item_index(mesh_selector.get_selected_id())
	mesh_selector.clear()
	for i in range(accessory_dict.keys().size()):
		mesh_selector.add_item(accessory_dict[i].name, accessory_dict.keys()[i])
	mesh_selector.select(index)

func set_values() -> void:
	accessory.data.position.x = -$AccessoryProperties/AccessoryPosition/XSlider.value
	accessory.data.position.y = $AccessoryProperties/AccessoryPosition/YSlider.value
	accessory.data.position.z = $AccessoryProperties/AccessoryPosition/ZSlider.value
	accessory.data.rotation.x = $AccessoryProperties/AccessoryRotation/XSlider.value
	accessory.data.rotation.y = $AccessoryProperties/AccessoryRotation/YSlider.value
	accessory.data.rotation.z = $AccessoryProperties/AccessoryRotation/ZSlider.value
	accessory.data.scale.x = $AccessoryProperties/AccessoryScale/XSlider.value
	accessory.data.scale.y = $AccessoryProperties/AccessoryScale/YSlider.value
	accessory.data.scale.z = $AccessoryProperties/AccessoryScale/ZSlider.value

func restore_values() -> void:
	$AccessoryProperties/AccessoryPosition/XSlider.value = -accessory.data.position.x
	$AccessoryProperties/AccessoryPosition/YSlider.value = accessory.data.position.y
	$AccessoryProperties/AccessoryPosition/ZSlider.value = accessory.data.position.z
	$AccessoryProperties/AccessoryRotation/XSlider.value = accessory.data.rotation.x
	$AccessoryProperties/AccessoryRotation/YSlider.value = accessory.data.rotation.y
	$AccessoryProperties/AccessoryRotation/ZSlider.value = accessory.data.rotation.z
	$AccessoryProperties/AccessoryScale/XSlider.value = accessory.data.scale.x
	$AccessoryProperties/AccessoryScale/YSlider.value = accessory.data.scale.y
	$AccessoryProperties/AccessoryScale/ZSlider.value = accessory.data.scale.z

func _on_reset_button_pressed() -> void:
	$ColorProperties/RedSlider.value = 1
	$ColorProperties/GreenSlider.value = 1
	$ColorProperties/BlueSlider.value = 1
	
	for i in ball_model.get_children():
		ball_model.remove_child(i)
		i.queue_free()
	
	if ball_model.get_child_count() == 0:
		accessory = Accessory.new()
		ball_model.add_child(accessory, true)
		accessory_selector.clear()
		accessory_selector.add_item(str("Accessory ", accessory.data.id + 1), accessory.data.id)
		mesh_selector.select(0)
		restore_values()
