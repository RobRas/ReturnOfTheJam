extends Node2D

var _indicator_script = preload("res://Scripts/Indicator.gd")
var _tile_script = preload("res://Scripts/Tile.gd")

export(NodePath) var players_node_path
var _players_node

var _map

var movement_range = 4

var _starting_tile
var _current_tiles = []

enum DirectionType { STRAIGHT, DIAGONAL }

const _DIRECTIONS_TO_CHECK = [
	Vector2(0, 1),
	Vector2(0, -1),
	Vector2(-1, 0),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(1, -1),
	Vector2(-1, -1),
	Vector2(-1, 1)
]

const _DIRECTION_WEIGHT_VALUES = {
	DirectionType.STRAIGHT: 1,
	DirectionType.DIAGONAL: 2
}

const _DIRECTION_WEIGHTS = {
	_DIRECTIONS_TO_CHECK[0]: _DIRECTION_WEIGHT_VALUES[DirectionType.STRAIGHT],
	_DIRECTIONS_TO_CHECK[1]: _DIRECTION_WEIGHT_VALUES[DirectionType.STRAIGHT],
	_DIRECTIONS_TO_CHECK[2]: _DIRECTION_WEIGHT_VALUES[DirectionType.STRAIGHT],
	_DIRECTIONS_TO_CHECK[3]: _DIRECTION_WEIGHT_VALUES[DirectionType.STRAIGHT],
	_DIRECTIONS_TO_CHECK[4]: _DIRECTION_WEIGHT_VALUES[DirectionType.DIAGONAL],
	_DIRECTIONS_TO_CHECK[5]: _DIRECTION_WEIGHT_VALUES[DirectionType.DIAGONAL],
	_DIRECTIONS_TO_CHECK[6]: _DIRECTION_WEIGHT_VALUES[DirectionType.DIAGONAL],
	_DIRECTIONS_TO_CHECK[7]: _DIRECTION_WEIGHT_VALUES[DirectionType.DIAGONAL],
}

func _ready():
	_players_node = get_node(players_node_path)

func init(map):
	_map = map

func set_starting_tile(starting_tile):
	_starting_tile = starting_tile
	var clicked_tile_position = _starting_tile.map_position
	_current_tiles = get_moveable_tiles_in_range(clicked_tile_position, movement_range)
	for tile in _current_tiles:
		if tile.current_state != _tile_script.State.OPEN:
			continue
		tile.set_indicator_state(_indicator_script.State.REACHABLE)



func get_path_from_tile(tile):
	var path = []
	if not tile in _current_tiles:
		return path
	var path_data = tile.find_node("PathData")
	while path_data.previous_tile:
		path.push_front(tile)
		tile = path_data.previous_tile
		path_data = tile.find_node("PathData")
	
	path.push_front(tile)
	return path
	

func get_moveable_tiles_in_range(starting_map_position, max_distance):
	clear_search()
	var returned_tiles = []
	
	if not _map.is_valid_map_position(starting_map_position):
		return returned_tiles
	
	_starting_tile = _map.get_tile_from_map(starting_map_position)
	
	clear_search()
	var check_now = []
	var check_next = []
	
	_starting_tile.find_node("PathData").distance = 0
	check_now.push_back(_starting_tile)
	
	while (check_now.size() > 0):
		var current_tile = check_now.pop_front()
		
		var current_tile_path_data = current_tile.find_node("PathData")
		for direction in _DIRECTIONS_TO_CHECK:
			var check_direction = current_tile.map_position + direction
			if not _map.is_valid_map_position(check_direction):
				continue
			
			var next_tile = _map.get_tile_from_map(check_direction)
			var next_tile_path_data = next_tile.find_node("PathData")
			if next_tile_path_data.distance <= current_tile_path_data.distance + _DIRECTION_WEIGHTS[direction]:
				continue
			
			if not next_tile.current_state == _tile_script.State.OPEN:
				continue
			
			next_tile_path_data.distance = current_tile_path_data.distance + _DIRECTION_WEIGHTS[direction];
			next_tile_path_data.previous_tile = current_tile;
			
			returned_tiles.push_back(next_tile)
			
			if next_tile_path_data.distance >= max_distance:
				continue
			
			check_next.push_back(next_tile)
		
		if check_now.size() == 0:
			check_now = check_next.duplicate()
			check_next.clear()
	
	return returned_tiles

func display_path(path):
	if _current_tiles.size() > 0:
		for tile in _current_tiles:
			if tile.current_state != _tile_script.State.OPEN:
				continue
			tile.set_indicator_state(_indicator_script.State.REACHABLE)
		for tile in path:
			tile.set_indicator_state(_indicator_script.State.PATH)

func clear_search():
	for tile in _current_tiles:
		tile.find_node("PathData").clear()
		tile.set_indicator_to_default()
	_current_tiles.clear()
