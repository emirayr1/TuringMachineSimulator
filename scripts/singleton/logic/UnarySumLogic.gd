extends Node
class_name UNARYMULT

enum States {q0, q1, q2, q3, Accept, Reject}

var current_state = States.q0

func transition_function(state: States, symbol: String):
	if state == States.q0:
		if symbol == "0":
			return ["1", 1, States.q1] # notation is -> symbol, move left or right, next state
		elif symbol == "1":
			return ["1", 1, States.q0]
		elif symbol == "-":
			return ["-", 1, States.q0]
	
	elif state == States.q1:
		if symbol == "1":
			return ["1", 1, States.q1]
		elif symbol == "-":
			return ["-", -1, States.q2]
		elif symbol == "0":
			return [symbol, 0, States.Reject]
	
	elif state == States.q2:
		if symbol == "1":
			return ["-", -1, States.q3]
		else:
			return [symbol, 0, States.Reject]
	
	elif state == States.q3:
		if symbol == "1":
			return ["1", -1, States.q3]
		elif symbol == "-":
			return ["-", 1, States.Accept]
	
	return [symbol, 0, States.Reject]

func get_start_state() -> States:
	return current_state
