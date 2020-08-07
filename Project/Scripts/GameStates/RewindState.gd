extends Node2D

export(NodePath) var map_path
var _map

export(NodePath) var player_select_state_path
var _player_select_state

export(NodePath) var rewinding_state_path
var _rewinding_state

var _current_rewinds = 5
var _total_rewinds = 5

var enabled = false

func _ready():
	_map = get_node(map_path)
	_player_select_state = get_node(player_select_state_path)
	_rewinding_state = get_node(rewinding_state_path)

func enter():
	print("RewindState: Click a unit to rewind it's action")
	print(str(_current_rewinds) + " rewinds remaining")
	enabled = true
	if _current_rewinds == 0:
		enabled = false
		_player_select_state.refresh()
		_player_select_state.enter()
		return

func refresh():
	_current_rewinds = _total_rewinds

func _input(event):
	if not enabled:
		return
	
	if Input.is_action_just_pressed("rewind"):
		if not _map.is_valid_world_position(event.position):
			return
		
		var tile = _map.get_tile_from_world(event.position)
		if tile.unit == null:
			return
		
		var unit = tile.unit
		if not unit.can_rewind(_current_rewinds):
			return
		
		_current_rewinds -= unit.get_rewind_cost()
		enabled = false
		_rewinding_state.enter(unit)
