extends Node2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func write():
	animation_player.play("write")

func move(target_x, target_y, duration=0.3) -> void:
	var tween := create_tween()
	tween.tween_property(
		self,
		"position",
		Vector2(target_x + 7, target_y - 40),
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished
