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

enum Modes{
	UNARYSUM,
	UNARYMULT,
}

var current_state = States.A
var head_position = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.play_pressed.connect(_on_play_pressed)
	
func _on_play_pressed(modeIdx : int, inputs: Array):
	menu.hide()
	background.visible = 1
	diagram.visible = 1
	
	var mode = null
	if modeIdx == 0:
		mode = Modes.UNARYSUM
	elif modeIdx == 1:
		mode = Modes.UNARYMULT
		
	start_game(inputs, mode)

func start_game(inputs: Array, mode: Modes) -> void:
	modeInit(inputs, mode)

func modeInit(inputs: Array, mode: Modes):
	var x = inputs[0]
	var y = inputs[1]
	var symbol_array = create_symbol_array(x, y, mode)
	var play_head_scene = play_head_scene.instantiate()
	create_tape(x, y, symbol_array, play_head_scene, mode)
	await start_calculation(symbol_array, play_head_scene)
	print(symbol_array)

func create_symbol_array(x: int, y: int, mode: Modes) -> Array:
	var symbol_array := []
	for i in range(x + y + 5):
		symbol_array.append("-")
	
	var blank_count = null
	if mode == Modes.UNARYSUM:
		blank_count = 2
	elif mode == Modes.UNARYMULT:
		blank_count = x * y
	
	var start = 2
	var count = x
	for i in range(start, start + count):
		symbol_array[i] = "1"
	start = start + count
	count = y
	symbol_array[start] = "0"
	for i in range(start + 1, start + count + 1):
		symbol_array[i] = "1"
	if mode == Modes.UNARYMULT:
		# change this pos
		symbol_array[start + count + 1] = "0"
		var blank_array = []
		for i in range (blank_count):
			blank_array.append("-")
		print(blank_array)
		symbol_array.append_array(blank_array)

	return symbol_array
	
func create_tape(x:int, y:int, symbol_array, play_head_scene, mode: Modes):
	var cell_size = cell_scene.instantiate().get_width_height()
	var window_x = get_window().size.x
	var origin_x = window_x / 2
	var origin_y = get_window().size.y / 2
	var first_x_pos = 0.0
	var first_y_pos = origin_y
	var pad = 10.0
	var pad_y = 50.0
	var maximum_cell = floor(window_x / (cell_size.x + pad)) 
	
	var rows = []
	var cont_rows = []
	
	var cell_count = null
	if mode == Modes.UNARYSUM:
		cell_count = x + y + 5
	elif mode == Modes.UNARYMULT:
		cell_count = x + y + 4 + (x*y)
	
	for i in range(cell_count):
		cont_rows.append(i)
		if cont_rows.size() >= maximum_cell:
			rows.append(cont_rows)
			cont_rows = []
			
	if cont_rows.size() > 0:
		rows.append(cont_rows)
		
	for row in rows:
		var row_cell_count = row.size()
		var row_length = (row_cell_count * cell_size.x) + ((row_cell_count - 1) * pad)
		
		var start_x = (window_x - row_length) / 2
		
		for j in range(row_cell_count):
			var cell_scene = cell_scene.instantiate()
			var pos_x = start_x + (j * (cell_size.x + pad))
			cell_scene.position = Vector2(pos_x, first_y_pos)
			tape.add_child(cell_scene)
			cell_array.append(cell_scene)
			cell_scene.set_symbol(symbol_array[0])
		first_y_pos += cell_size.y + pad_y
		
	play_head_scene.position = Vector2(cell_array[0].position.x, origin_y - 40)
	add_child(play_head_scene)
		
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
		States.keys()[new_state]])
	
	# write symbol
	var anim : AnimationPlayer = play_head_scene.get_node("AnimationPlayer")
	var base_duration : float = 0.4
	var speed_coef : float = max(cell_array.size() * 0.17, 1.0)
	
	var second : float = base_duration / speed_coef

	anim.play("write", -1, speed_coef)
	await anim.animation_finished
	cell_array[head_position].set_symbol(new_symbol)
	symbol_array[head_position] = new_symbol
		
	# Move Head
	head_position += direction
	await play_head_scene.move(cell_array[head_position].position.x, cell_array[head_position].position.y
								, second)
		
	# Change State
	current_state = new_state
	
func start_calculation(symbol_array, play_head_scene):
	var step = 0
	while current_state not in [States.Accept, States.Reject]:
		await run_step(symbol_array, play_head_scene, step)
		step += 1
