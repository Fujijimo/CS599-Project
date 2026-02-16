extends CanvasLayer

func _process(_delta: float) -> void:
	update_labels()

func update_labels():
	$XP.text = "XP: " + str(saveload.data.player.xp)
	$Money.text = "Money: " + str(saveload.data.player.money)
