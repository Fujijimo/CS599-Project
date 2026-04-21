extends Node3D

var course_selection = 0
var course_name = [
	"Retro Course",
	"Standard Course",
	"Clover Course",
]
var course_scene = [
	"res://golf/scenes/course_watchman_play.tscn",
	"res://golf/scenes/course_standard_play.tscn",
	"res://golf/scenes/course_clover_play.tscn",
]

func level_select_input(delta):
	if Input.is_action_just_pressed("ui_left") and course_selection > 0:
		position.x += 10
		course_selection -= 1
		update_label()
		$AudioStreamPlayer.play()
	if Input.is_action_just_pressed("ui_right") and course_selection < course_name.size() - 1:
		position.x -= 10
		course_selection += 1
		update_label()
		$AudioStreamPlayer.play()
	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file(course_scene[course_selection])
	
	get_child(course_selection).rotate_y(delta)

func update_label():
	$Label.text = course_name[course_selection]
