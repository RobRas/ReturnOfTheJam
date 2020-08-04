extends Node2D

const _PASSIVE_ALPHA = 0.3
const _ACTIVE_ALPHA = 1.0

const _SELECT_GROWTH_DURATION = 0.5

enum State { DISABLED, OPEN, ALLY, BADDY, REACHABLE, PATH }
var state

var _selected = false
		

func set_state(new_state):
	state = new_state
	var color = modulate
	
	match(state):
		State.DISABLED:
			color = Color.white
			color.a = 0
		State.OPEN:
			color = Color.white
			color.a = _PASSIVE_ALPHA
		State.ALLY:
			color = Color.green
			color.a = _ACTIVE_ALPHA
		State.BADDY:
			color = Color.red
			color.a = _ACTIVE_ALPHA
		State.REACHABLE:
			color = Color.blue
			color.a = _ACTIVE_ALPHA
		State.PATH:
			color = Color.yellow
			color.a = _ACTIVE_ALPHA
	
	modulate = color

func clear_pathing():
	if state == State.REACHABLE or state == State.PATH:
		set_state(State.OPEN)
