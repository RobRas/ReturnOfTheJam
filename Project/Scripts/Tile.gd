extends Node2D

var indicator_scene = preload("res://Scenes/Indicator.tscn")
var _indicator

var _indicator_script = preload("res://Scripts/Indicator.gd")

var map_position = Vector2()

enum State { OPEN, BLOCKED, UNIT_ALLY, UNIT_ENEMY }
var current_state = State.OPEN

func init(cell_position, world_position, tile_index):
	map_position = cell_position
	position = world_position
	
	match(tile_index): # MAKE 0 OPEN!!
		1:
			current_state = State.OPEN
		0:
			current_state = State.BLOCKED
	
	_indicator = indicator_scene.instance()
	add_child(_indicator)
	_indicator.global_position = world_position
	
	set_indicator_to_default()

func set_state(new_state):
	current_state = new_state
	set_indicator_to_default()

func set_indicator_state(new_state):
	_indicator.set_state(new_state)

func set_indicator_to_default():
	match (current_state):
		State.OPEN:
			_indicator.set_state(_indicator_script.State.OPEN)
		State.BLOCKED:
			_indicator.set_state(_indicator_script.State.DISABLED)
		State.UNIT_ALLY:
			_indicator.set_state(_indicator_script.State.ALLY)
		State.UNIT_ENEMY:
			_indicator.set_state(_indicator_script.State.ENEMY)
