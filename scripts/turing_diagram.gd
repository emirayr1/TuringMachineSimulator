extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StateNodeA.position = Vector2(100, 100)
	$StateNodeB.position = Vector2(300, 100)
	$StateNodeC.position = Vector2(500, 100)
	$StateNodeD.position = Vector2(500, 200)

	$TransitionLine.queue_redraw()
