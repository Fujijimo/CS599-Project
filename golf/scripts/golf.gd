extends Node3D

var par: int = 0
var condor: int
var albatross: int
var eagle: int
var birdie: int
var bogey: int
var double_bogey: int
var triple_bogey: int
var quadruple_bogey: int
var finish: bool = false

@onready var result_display: Label = $HUD/Result

func _ready() -> void:
	Engine.time_scale = 1.0
	match self.get_name():
		"CourseStandardPlay":
			set_par(4)
		"CourseCloverPlay":
			set_par(6)
		"CourseWatchmanPlay":
			set_par(6)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("return_to_hub"):
		get_tree().change_scene_to_file("res://hub_world/scenes/hub_world.tscn")

	if has_node("Enemies"):
		if $Enemies.get_child_count() == 0:
			if finish == false:
				result_display.visible = true
				result_display.text = score_terms()
				finish = true

func score_terms():
	var strokes: int = $"Ball".stroke
	if par >= 7:
		for n in range(2, condor - 1):
			if strokes == n:
				return "Phoenix"
	match strokes:
		1:
			saveload.data.player.xp += 1000
			return "Hole in One"
		condor:
			saveload.data.player.xp += 500
			return "Condor"
		albatross:
			saveload.data.player.xp += 400
			return "Albatross"
		eagle:
			saveload.data.player.xp += 300
			return "Eagle"
		birdie:
			saveload.data.player.xp += 200
			return "Birdie"
		par:
			saveload.data.player.xp += 100
			return "Par"
		bogey:
			saveload.data.player.xp += 50
			return "Bogey"
		double_bogey:
			saveload.data.player.xp += 40
			return "Double Bogey"
		triple_bogey:
			saveload.data.player.xp += 30
			return "Triple Bogey"
		quadruple_bogey:
			saveload.data.player.xp += 20
			return "Quadruple Bogey"
		_:
			saveload.data.player.xp += 1
			return "You stink"

func set_par(num):
	par = num
	condor = par - 4
	albatross = par - 3
	eagle = par - 2
	birdie = par - 1
	bogey = par + 1
	double_bogey = par + 2
	triple_bogey = par + 3
	quadruple_bogey = par + 4
