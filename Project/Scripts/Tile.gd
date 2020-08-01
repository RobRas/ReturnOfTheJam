extends Node2D


var map_position = Vector2()

enum State { OPEN, BLOCKED, UNIT_ALLY, UNIT_ENEMY }
var current_state = State.OPEN

func init(cell_position, tile_index):
	map_position = cell_position
	
	match(tile_index):
		0:
			current_state = State.OPEN
		1:
			current_state = State.BLOCKED
	
	print(current_state)
