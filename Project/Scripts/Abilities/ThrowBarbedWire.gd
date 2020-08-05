extends Node2D

signal used

const barbed_wire_scene = preload("res://Scenes/BarbedWire.tscn")

var tiles = []
var using = false

var _unit
var _map
var _current_tile

func init(unit, map):
	_unit = unit
	_map = map
	_current_tile = unit.current_tile

func start_using():
	using = true

func _input(event):
	if not using:
		return
	
	if event is InputEventMouseMotion:
		if tiles.size() > 0:
			for tile in tiles:
				var barbed_wire_node = barbed_wire_scene.instance()
				_map.get_node("YSort/Hazards").add_child(barbed_wire_node)
				barbed_wire_node.global_position = tile.global_position
				tile.hazard = barbed_wire_node
			tiles.clear()
			using = false
			emit_signal("used")
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if not _map.is_valid_world_position(event.position):
			tiles.clear()
			return
		
		var tile = _map.get_tile_from_world(event.position)
		if tile == _current_tile:
			return
		
		_current_tile = tile
		if tile == _unit.current_tile:
			return
		
		tiles.clear()
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
			
