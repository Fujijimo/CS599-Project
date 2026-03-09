extends Node
class_name SaveGame

const SAVE_GAME_PATH = "user://save.json"

var character = Character.new()
var global_position : Vector3
var data: Dictionary = {
		"global_position":
		{
			"x": global_position.x,
			"y": global_position.y,
			"z": global_position.z
		},
		"player":
		{
			"character_name": character.character_name,
			"level": character.level,
			"xp": character.xp,
			"money": character.money
		}
	}

func write_savegame() -> void:
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	file.store_var(data.duplicate())
	file.close()
	
func load_savegame() -> void:
	if FileAccess.file_exists(SAVE_GAME_PATH):
		var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
		var load_data = file.get_var()
		file.close()
	
		var save_data = load_data.duplicate()
		data.global_position = Vector3(save_data.global_position.x, save_data.global_position.y, save_data.global_position.z)
		data.player.character_name = save_data.player.character_name
		data.player.level = save_data.player.level
		data.player.xp = save_data.player.xp
		data.player.money = save_data.player.money

func add_xp_money(xp_amount, money_amount) -> void:
	data.player.xp += xp_amount
	data.player.money += money_amount
