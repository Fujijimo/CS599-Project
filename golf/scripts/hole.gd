extends Node3D
@onready var result_display: Label = $"../HUD/Result"
@onready var level: Node3D = get_parent()

func _on_area_3d_body_entered(_body: RigidBody3D) -> void:
	if level.finish == false:
		result_display.visible = true
		result_display.text = level.score_terms()
		level.finish = true
