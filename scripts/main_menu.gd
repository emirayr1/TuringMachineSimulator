extends Control

signal play_pressed(mode : String, inputs: Array)

@onready var settings = $ButtonContainer/Settings
@onready var text_edit1 = $TextEdit
@onready var text_edit2 = $TextEdit2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	var selected_index = settings.get_selected()
	var mode : String = settings.get_item_text(selected_index)
	if text_edit1.text == "" or text_edit2.text == "":
		print("You Have To Pass Numbers To Sum")
	else:
		var inputs = [int(text_edit1.text), int(text_edit2.text)]
		emit_signal("play_pressed", mode, inputs)
