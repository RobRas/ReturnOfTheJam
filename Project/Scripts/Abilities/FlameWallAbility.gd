extends Node2D

signal used

const flame_wall_ability_command_scene = preload("res://Scenes/Commands/FlameWallAbilityCommand.tscn")

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
		"""
		if _current_tile == _unit.current_tile:
			return
		
		var tiles = []
		var mouse_tile_position = _map.get_map_position_from_tile(_current_tile)
		var unit_tile_position = _map.get_map_position_from_tile(_unit.current_tile)
		var tile_displacement = mouse_tile_position - unit_tile_position
		if (abs(tile_displacement.x) >= abs(tile_displacement.y)):
			var middle_tile_position = unit_tile_position + Vector2(clamp(tile_displacement.x, -1, 1), 0)
			var tile_positions = [middle_tile_position]
			tile_positions.push_back(Vector2(middle_tile_position.x, middle_tile_position.y + 1))
			tile_positions.push_back(Vector2(middle_tile_position.x, middle_tile_position.y - 1))
			tile_positions.push_back(Vector2(unit_tile_position.x, unit_tile_position.y + 1))
			tile_positions.push_back(Vector2(unit_tile_position.x, unit_tile_position.y - 1))
			for tile_position in tile_positions:
				if not _map.is_valid_map_position(tile_position):
					continue
				var target_tile = _map.get_tile_from_map(tile_position)
				if target_tile.is_placeable():
					tiles.push_back(target_tile)
		else:
			var middle_tile_position = unit_tile_position + Vector2(0, clamp(tile_displacement.y, -1, 1))
			var tile_positions = [middle_tile_position]
			tile_positions.push_back(Vector2(middle_tile_position.x + 1, middle_tile_position.y))
			tile_positions.push_back(Vector2(middle_tile_position.x - 1, middle_tile_position.y))
			tile_positions.push_back(Vector2(unit_tile_position.x + 1, unit_tile_position.y))
			tile_positions.push_back(Vector2(unit_tile_position.x - 1, unit_tile_position.y))
			for tile_position in tile_positions:
				if not _map.is_valid_map_position(tile_position):
					continue
				var target_tile = _map.get_tile_from_map(tile_position)
				if target_tile.is_placeable():
					tiles.push_back(target_tile)
		
		var command = flame_wall_ability_command_scene.instance()
		command.init(_current_tile, _map)
		_history.execute_command(command)
		yield(_history, "execution_completed")
		using = false
		"""
		emit_signal("used")
