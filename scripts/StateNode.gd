extends Control
class_name StateNode

@export var state_name := "A"
@export var radius := 40.0
@export var is_accept := false

func _ready():
	$Label.text = state_name
	custom_minimum_size = Vector2(radius * 2, radius * 2)
	$Label.position = custom_minimum_size / 2 - $Label.size / 2

func _draw():
	draw_circle(custom_minimum_size / 2, radius, Color.BLACK, false, 5.0)
	if is_accept:
		draw_circle(custom_minimum_size / 2, radius - 6, Color.BLACK)
