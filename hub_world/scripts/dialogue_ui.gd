extends CanvasLayer

signal dialogue_finished
signal dialogue_advance

@onready var speaker_label: Label = $PanelContainer/VBoxContainer/SpeakerLabel
@onready var text_label: Label = $PanelContainer/VBoxContainer/TextLabel

var typing_timer: Timer = Timer.new()
var current_text: String = ""
var typing_speed: float = 0.05
var wait_for_input: bool = false
var dialogue_data: Dictionary = {}
var current_dialogue_id: String

func _ready():
	typing_timer.timeout.connect(_on_typing_timer_timeout)
	add_child(typing_timer)
	hide()

func start(data: Dictionary, start_id: String):
	self.dialogue_data = data
	show()
	_show_dialogue(start_id)

func _show_dialogue(id: String):
	if not dialogue_data.has(id):
		push_error("Dialogue ID not found: " + id)
		end_dialogue()
		return

	current_dialogue_id = id
	var entry = dialogue_data[id]
	
	speaker_label.text = entry.get("speaker", "")
	current_text = entry.get("text", "...")
	wait_for_input = true
	# Start typewriter effect
	text_label.text = current_text
	text_label.visible_characters = 0
	typing_timer.start(typing_speed)

func _on_typing_timer_timeout():
	if text_label.visible_characters < current_text.length():
		text_label.visible_characters += 1
	else:
		typing_timer.stop()
		var entry = dialogue_data[current_dialogue_id]
		# If next_id exists and no choices, auto-advance
		# Note: Long consecutive text will advance quickly.
		# Consider adding a "wait_for_input": true option
		# to data and checking here if needed
		if wait_for_input == true:
			print("poop")
			await dialogue_advance
			if entry.has("next_id"):
				_show_dialogue(entry["next_id"])
			else:
				end_dialogue()
			
func end_dialogue():
	hide()
	dialogue_finished.emit()

func _unhandled_input(event: InputEvent):
	if not is_visible():
		return

	if event.is_action_pressed("interact"):
		dialogue_advance.emit()
		"""if typing_timer.is_stopped():
			var entry = dialogue_data[current_dialogue_id]
			if not entry.has("next_id"):
				end_dialogue()
		else:
			typing_timer.stop()
			text_label.visible_characters = current_text.length()
			_on_typing_timer_timeout()
		get_viewport().set_input_as_handled()"""
