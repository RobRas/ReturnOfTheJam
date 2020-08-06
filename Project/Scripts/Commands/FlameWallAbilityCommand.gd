extends Node2D


const _EXPLOSION_DIRECTIONS = [
	Vector2(1,1),
	Vector2(1,0),
	Vector2(1,-1),
	Vector2(0,1),
	Vector2(0,-1),
	Vector2(-1,1),
	Vector2(-1,0),
	Vector2(-1,-1)
]

signal execution_completed(command)
signal reverse_completed(command)

var _target_tile_position
var _map

var _units_to_wait_for_path = 0

func init(target_tile, map):
	_map = map
	_target_tile_position = _map.get_map_position_from_tile(target_tile)

func can_execute():
	return true

func execute():
	for direction in _EXPLOSION_DIRECTIONS:
		var exploding_tile_position = _target_tile_position + direction
		if not _map.is_valid_map_position(exploding_tile_position):
			continue
			
		var exploding_tile = _map.get_tile_from_map(exploding_tile_position)
		
		if not exploding_tile.unit:
			continue
		
		var knock_to_tile_position = exploding_tile_position + direction
		if not _map.is_valid_map_position(knock_to_tile_position):
			continue
		
		var knock_to_tile = _map.get_tile_from_map(knock_to_tile_position)
		if not knock_to_tile.is_placeable(): # change this function to check for hazards/other units
			continue
		
		exploding_tile.unit.connect("destination_reached", self, "_on_unit_destination_reached")
		_units_to_wait_for_path += 1
		exploding_tile.unit.move_along_path([exploding_tile, knock_to_tile])


func can_reverse():
	return true

func reverse():
	for direction in _EXPLOSION_DIRECTIONS:
		var pull_from_tile_position = _target_tile_position + direction + direction
		if not _map.is_valid_map_position(pull_from_tile_position):
			continue
			
		var pull_from_tile = _map.get_tile_from_map(pull_from_tile_position)
		
		if not pull_from_tile.unit:
			continue
		
		var pull_to_tile_position = pull_from_tile_position - direction
		if not _map.is_valid_map_position(pull_to_tile_position):
			continue
		
		var pull_to_tile = _map.get_tile_from_map(pull_to_tile_position)
		if not pull_to_tile.is_placeable(): # change this function to check for hazards/other units
			continue
		
		pull_from_tile.unit.connect("destination_reached", self, "_on_unit_destination_reached")
		_units_to_wait_for_path += 1
		pull_from_tile.unit.move_along_path([pull_from_tile, pull_to_tile])


func _on_unit_destination_reached(tile):
	tile.unit.disconnect("destination_reached", self, "_on_unit_destination_reached")
	_units_to_wait_for_path -= 1
	if _units_to_wait_for_path == 0:
		emit_signal("execution_completed", self)
