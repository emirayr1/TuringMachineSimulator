extends Node2D

@onready var symbol_label = $Box/ColorRect/symbol
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_width_height() -> Vector2:
	return $Box.size
	
func set_symbol(symbol: String) -> void:
	symbol_label.text = symbol
