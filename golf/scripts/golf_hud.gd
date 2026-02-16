extends CanvasLayer

#@onready var hit_strength = $Control/ProgressBar
#@onready var hit_strength2 = $Control/ProgressBar2
@onready var hit_strength: ProgressBar = $ProgressBar
@onready var hit_timer: AnimationPlayer = $AnimationPlayer
@onready var ball: RigidBody3D = $"../Ball"
#var tween_loop
#var tween_reset

func _physics_process(_delta: float) -> void:
	update_labels()
	rotate_wind_arrow()

func hit_timer_play(animation_name):
	hit_timer.play(animation_name)
	
func hit_timer_stop():
	hit_timer.stop(true)
#
func hit_timer_reset():
	hit_strength.value = 0
	#hit_strength2.value = 0
	
#func set_curve_timer_value():
	#hit_timer.get_animation("curve_meter").track_set_key_value(0, 0, hit_strength.value)
	#hit_timer.get_animation("curve_meter").track_set_key_time(0, 1, hit_strength.value / 100)
	#hit_timer.get_animation("curve_meter").track_set_key_time(1, 0, hit_strength.value / 100)
	#hit_timer.get_animation("curve_meter").track_set_key_time(1, 1, hit_timer.get_animation("curve_meter").track_get_key_time(1, 0) + 0.1)

func update_labels():
	$Stroke.text = "Stroke: " + str(ball.stroke)
	$Club.text = "Club: " + ball.club
	$XP.text = "XP: " + str(saveload.data.player.xp)
	$Money.text = "Money: " + str(saveload.data.player.money)
	$WindSpeed.text = "Wind Speed: " + str("%0.1f" % ball.wind_speed)
	$AirControl.text = "Air Control: " + str(abs(ball.ability_used.air_control)).pad_decimals(2)
	$Jump.text = "Jump: " + str(ball.ability_used.jump)
	$Drop.text = "Drop: " + str(ball.ability_used.drop)

func rotate_wind_arrow():
	$SubViewportContainer/SubViewport/UICam.global_rotation = $"../Origin/SpringArm3D/PlayerCam".global_rotation
	$SubViewportContainer/SubViewport/UICam/Arrow.global_rotation.y = atan2(-ball.wind_direction.x, -ball.wind_direction.z)
