extends Node2D

@onready var menu = $CanvasLayer/MainMenu
@onready var background = $CanvasLayer/Background
@onready var tape = $Tape
@onready var diagram = $CanvasLayer/TuringDiagram

var cell_scene := preload("res://scenes/cell.tscn")
var play_head_scene := preload("res://scenes/play_head.tscn")
var cell_array = []

enum States{
	A,
	B,
	C,
	D,
	Reject,
	Accept
}

var current_state = States.A
var head_position = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.play_pressed.connect(_on_play_pressed)
	
func _on_play_pressed(mode : String, inputs: Array):
	menu.hide()
	background.visible = 1
	diagram.visible = 1
	start_game(mode, inputs)

func start_game(mode : String, inputs: Array) -> void:
	if mode == "Unary Addition":
		unary_addition(inputs)
	elif mode == "Binary Addition":
		binary_addition()

func unary_addition(inputs: Array):
	var x = inputs[0]
	var y = inputs[1]
	var symbol_array = create_symbol_array(x, y)
	var play_head_scene = play_head_scene.instantiate()
	create_tape(x, y, symbol_array, play_head_scene)
	await start_calculation(symbol_array, play_head_scene)
	print(symbol_array)
	
func binary_addition():
	print("Binary Addition")

func create_tape(x:int, y:int, symbol_array, play_head_scene):
	var cell_size = cell_scene.instantiate().get_width_height()
	var origin_x = get_window().size.x / 2
	var origin_y = get_window().size.y / 2
	var cell_count = x + y + 5
	# 2 + 3 (+4 + 1) ise 10 tane cell gerekiyor _ _ 1 1 0 1 1 1 _ _
	var cell_start_x = origin_x - (int(cell_count / 2) * cell_size.x)
	play_head_scene.position = Vector2(cell_start_x + 7, origin_y - 40)
	add_child(play_head_scene)
	
	for i in range(cell_count):
		var cell_scene = cell_scene.instantiate()
		cell_scene.position = Vector2(cell_start_x + (cell_size.x * i) + (i * 2), origin_y)
		cell_array.append(cell_scene)
		tape.add_child(cell_scene)
		cell_scene.set_symbol(symbol_array[i])
		

func create_symbol_array(x: int, y: int) -> Array:
	var symbol_array := []
	for i in range(x + y + 5):
		symbol_array.append("-")
	
	var start = 2
	var count = x
	for i in range(start, start + count):
		symbol_array[i] = "1"
	start = start + count
	count = y
	symbol_array[start] = "0"
	for i in range(start + 1, start + count + 1):
		symbol_array[i] = "1"
		
	return symbol_array

func transition_function(state: States, symbol: String):
	if state == States.A:
		if symbol == "0":
			return ["1", 1, States.B] # notation is -> symbol, move left or right, next state
		elif symbol == "1":
			return ["1", 1, States.A]
		elif symbol == "-":
			return ["-", 1, States.A]
	
	elif state == States.B:
		if symbol == "1":
			return ["1", 1, States.B]
		elif symbol == "-":
			return ["-", -1, States.C]
		elif symbol == "0":
			return [symbol, 0, States.Reject]
	
	elif state == States.C:
		if symbol == "1":
			return ["-", -1, States.D]
		else:
			return [symbol, 0, States.Reject]
	
	elif state == States.D:
		if symbol == "1":
			return ["1", -1, States.D]
		elif symbol == "-":
			return ["-", 1, States.Accept]
	
	return [symbol, 0, States.Reject]

func start_calculation(symbol_array, play_head_scene):
	var step = 0
	while current_state not in [States.Accept, States.Reject]:
		await run_step(symbol_array, play_head_scene, step)
		step += 1

func run_step(symbol_array, play_head_scene, step) -> void:
	
	var current_symbol = symbol_array[head_position]
	var result = transition_function(current_state, current_symbol)
	var new_symbol = result[0]
	var direction = result[1]
	var new_state = result[2]
	
	print("Step %s: State=%s, Pos=%s, Read=%s -> Write=%s, Move=%d, NewState=%s"
	% [step,
		current_state,
		head_position,
		current_symbol,
		new_symbol,
		direction,
		new_state])
	
	# write symbol
	var anim = play_head_scene.get_node("AnimationPlayer")
	anim.play("write")
	await anim.animation_finished
	cell_array[head_position].set_symbol(new_symbol)
	symbol_array[head_position] = new_symbol
		
	# Move Head
	head_position += direction
	await play_head_scene.move(cell_array[head_position].position.x)
		
	# Change State
	current_state = new_state
