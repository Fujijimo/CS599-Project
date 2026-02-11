extends CanvasLayer

func _process(_delta: float) -> void:
	update_labels()

func update_labels():
	$XPCount.text = str(saveload.data.player.xp)
	$MoneyCount.text = str(saveload.data.player.money)
