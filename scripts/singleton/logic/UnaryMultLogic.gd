extends Node
class_name UNARYSUM

enum States{q0,q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, Accept, Reject}

var current_state = States.q11

func transition_function(state: States, symbol: String):
	print("Multiply transition")
	if state == States.q0:
		if symbol == "0":
			return ["-", 1, States.q9] # notation is -> symbol, move left or right, next state
		elif symbol == "1":
			return ["-", 1, States.q1]
			
	# it should be q0 but ı did wrong placement
	# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	elif state == States.q11:
		if symbol == "-":
			return ["-", 1, States.q11]
		elif symbol == "1":
			return ["1", 0, States.q0]

	elif state == States.q1:
		if symbol == "1":
			return ["1", 1, States.q1]
		elif symbol == "0":
			return ["0", 1, States.q2]
	
	elif state == States.q2:
		if symbol == "1":
			return ["x", 1, States.q3] 
		elif symbol == "0":
			return ["0", -1, States.q7]
	
	elif state == States.q3:
		if symbol == "1":
			return ["1", 1, States.q3]
		elif symbol == "0":
			return ["0", 1, States.q4]
	
	elif state == States.q4:
		if symbol == "1":
			return ["1", 1, States.q4]
		elif symbol == "-":
			return ["1", -1, States.q5]
	
	elif state == States.q5:
		if symbol == "1":
			return ["1", -1, States.q5]
		elif symbol == "0":
			return ["0", -1, States.q6]
	
	elif state == States.q6:
		if symbol == "1":
			return ["1", -1, States.q6]
		elif symbol == "x":
			return ["x", 1, States.q2]
	
	elif state == States.q7:
		if symbol == "x":
			return ["1", -1, States.q7]
		elif symbol == "0":
			return ["0", -1, States.q8]
	
	elif state == States.q8:
		if symbol == "1":
			return ["1", -1, States.q8]
		elif symbol == "-":
			return ["-", 1, States.q0]
	
	elif state == States.q9:
		if symbol == "1":
			return ["-", 1, States.q9]
		elif symbol == "0":
			return ["-", 1, States.q10]
			
	elif state == States.q10:
		return [symbol, 0, States.Accept]

	return [symbol, 0, States.Reject]

func get_start_state() -> States:
	return current_state
