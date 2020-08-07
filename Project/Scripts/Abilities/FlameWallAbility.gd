extends Node2D

signal used

const flame_wall_ability_command_scene = preload("res://Scenes/Commands/FlameWallAbilityCommand.tscn")

var using = false

var _unit
var _map
var _current_tile
var _history

const _TILE_COUNT = 3

func init(unit, map, history):
	_unit = unit
	_map = map
	_current_tile = unit.current_tile
	_history = history

func start_using():
	using = true

func stop_using():
	using = false

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
		
		var _unit_position = _map.get_map_position_from_tile(_unit.current_tile)
		var _tile_position = _map.get_map_position_from_tile(_current_tile)
		
		var offset = _tile_position - _unit_position
		if offset.x != 0 and offset.y != 0 and abs(offset.x) != abs(offset.y):
			return
		
		offset.x = clamp(offset.x, -1, 1)
		offset.y = clamp(offset.y, -1, 1)
		
		var tiles = []
		for i in range(_TILE_COUNT):
			var tile_position = _unit_position + (i + 1) * offset
			if not _map.is_valid_map_position(tile_position):
				continue
			var target_tile = _map.get_tile_from_map(tile_position)
			if target_tile.is_placeable():
				tiles.push_back(target_tile)
		
		if tiles.size() == 0:
			return
		
		var command = flame_wall_ability_command_scene.instance()
		command.init(_unit.get_node("FlamePivot"), offset, tiles, _map)
		_history.execute_command(command)
		yield(_history, "execution_completed")
		using = false
		emit_signal("used")
