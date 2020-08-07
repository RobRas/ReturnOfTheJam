extends Node2D

signal used

const knockback_grenade_command_scene = preload("res://Scenes/Commands/KnockbackGrenadeCommand.tscn")

var using = false

var _unit
var _map
var _current_tile
var _history

func init(unit, map, history):
	_unit = unit
	_map = map
	_current_tile = unit.current_tile
	_history = history

func start_using():
	using = true

func _input(event):
	if not using:
		return
	
	if event is InputEventMouseMotion:
		if not _map.is_valid_world_position(event.position):
			_current_tile = null
			return
		
		var tile = _map.get_tile_from_world(event.position)
		if tile == _current_tile:
			return
		
		_current_tile = tile
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and _current_tile:
		if _current_tile == _unit.current_tile:
			return
		
		if not _map.is_valid_world_position(event.position):
			return
		
		var tile = _map.get_tile_from_world(event.position)
		var command = knockback_grenade_command_scene.instance()
		command.init(_unit, tile, _map)
		_history.execute_command(command)
		yield(_history, "execution_completed")
		using = false
		emit_signal("used")
