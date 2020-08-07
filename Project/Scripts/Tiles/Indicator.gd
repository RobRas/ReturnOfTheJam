extends Node2D

const _PASSIVE_ALPHA = 0.3
const _ACTIVE_ALPHA = 1.0

const _SELECT_GROWTH_DURATION = 0.5

enum State { NONE, OPEN, ALLY, BADDY, HAZARD }
var state

enum PathingData { NONE, REACHABLE, PATH }
var pathing_data = PathingData.NONE

var _selected = false
var _show_open = true

func set_show_open(show):
	if _show_open == show:
		return
	_show_open = show
	if pathing_data == PathingData.NONE:
		set_state(state)

func set_state(new_state):
	state = new_state
	
	match(state):
		State.NONE:
			modulate = Color.white
			modulate.a = 0
		State.OPEN:
			modulate = Color.white
			if _show_open:
				modulate.a = _PASSIVE_ALPHA
			else:
				modulate.a = 0
		State.ALLY:
			modulate = Color.green
			modulate.a = _ACTIVE_ALPHA
		State.BADDY:
			modulate = Color.red
			modulate.a = _ACTIVE_ALPHA
		State.HAZARD:
			modulate = Color.orange
			modulate.a = _ACTIVE_ALPHA

func set_pathing_data(data):
	pathing_data = data
	match(pathing_data):
		PathingData.NONE:
			set_state(state)
		PathingData.REACHABLE:
			modulate = Color.blue
			modulate.a = _ACTIVE_ALPHA
		PathingData.PATH:
			modulate = Color.yellow
			modulate.a = _ACTIVE_ALPHA
