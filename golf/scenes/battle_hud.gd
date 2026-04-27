extends CanvasLayer

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://golf/scenes/in_progress.tscn")
