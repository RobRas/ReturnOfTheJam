extends Node2D

signal entered
signal exited
signal current_changed(new_value)

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
	_map.set_show_open_tiles(false)
	print(str(_current_rewinds) + " rewinds remaining")
	enabled = true
	emit_signal("entered")
	if _current_rewinds == 0:
		enabled = false
		_player_select_state.refresh()
		_player_select_state.enter()
		emit_signal("exited")
		return
	for ally in _map.get_node("YSort/Allies").get_children():
		if ally.can_rewind(_current_rewinds):
			return
	for baddy in _map.get_node("YSort/Baddies").get_children():
		if baddy.can_rewind(_current_rewinds):
			return
	
	enabled = false
	_player_select_state.refresh()
	_player_select_state.enter()
	emit_signal("exited")

func refresh():
	_current_rewinds = _total_rewinds
	emit_signal("current_changed", _current_rewinds)

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
		emit_signal("current_changed", _current_rewinds)
		enabled = false
		_rewinding_state.enter(unit)
