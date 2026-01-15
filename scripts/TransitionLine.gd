extends Control
class_name TransitionLine

@export var from_node : Control
@export var to_node   : Control
@export var label := "1 → R"

func _draw():
	var startX = from_node.global_position.x + from_node.radius * 2
	var startY = from_node.global_position.y + from_node.radius
	
	var endX = to_node.global_position.x
	var endY = to_node.global_position.y + to_node.radius
	
	var p1 = Vector2(endX, endY)
	var p2 = Vector2(endX - 20, endY - 10)
	var p3 = Vector2(endX - 20, endY + 10)
	
	var label_pos = Vector2(startX + (endX - 20 - startX) / 2 - 20, startY - 10)
	
	if to_node.global_position.y > from_node.global_position.y:
		startX = from_node.global_position.x + from_node.radius
		startY = from_node.global_position.y + from_node.radius * 2
	
		endX = to_node.global_position.x + to_node.radius
		endY = to_node.global_position.y - 20
		
		p1 = Vector2(endX, endY + 20)
		p2 = Vector2(endX - 10, endY)
		p3 = Vector2(endX + 10, endY)
		
		label_pos = Vector2(startX + 10, startY + (endY - 10 - startY) / 2)
		draw_line(Vector2(startX, startY), Vector2(endX, endY), Color.RED, 5)
	else:
		draw_line(Vector2(startX, startY), Vector2(endX - 20, endY), Color.RED, 5)

	

	draw_polygon(
		PackedVector2Array([p1, p2, p3]),
		PackedColorArray([Color.BLACK])
	)
	## Label
	draw_string(
		get_theme_default_font(),
		label_pos,
		label
	)
