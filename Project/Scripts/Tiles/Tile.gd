extends Node2D

var indicator_scene = preload("res://Scenes/Indicator.tscn")
var _indicator

var _indicator_script = preload("res://Scripts/Tiles/Indicator.gd")

var map_position = Vector2()

enum State { OPEN, BLOCKED, UNIT_ALLY, UNIT_BADDY }
var current_state = State.OPEN
var unit = null

func init(cell_position, world_position, block):
	map_position = cell_position
	position = world_position
	
	if block:
		current_state = State.BLOCKED
	else:
		current_state = State.OPEN
	
	_indicator = indicator_scene.instance()
	add_child(_indicator)
	_indicator.global_position = world_position
	
	set_indicator_to_default()

func set_state(new_state):
	current_state = new_state
	set_indicator_to_default()

func select_indicator(new_select):
	_indicator.select(new_select)

func set_indicator_state(new_state):
	_indicator.set_state(new_state)

func set_indicator_to_default():
	match (current_state):
		State.OPEN:
			_indicator.set_state(_indicator_script.State.OPEN)
		State.BLOCKED:
			_indicator.set_state(_indicator_script.State.DISABLED)
		State.UNIT_ALLY:
			if unit.selectable:
				_indicator.set_state(_indicator_script.State.ALLY)
			else:
				_indicator.set_state(_indicator_script.State.DISABLED)
		State.UNIT_BADDY:
			_indicator.set_state(_indicator_script.State.BADDY)
