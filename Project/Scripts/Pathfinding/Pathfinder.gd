extends Node2D

var _indicator_script = preload("res://Scripts/Tiles/Indicator.gd")
var _tile_script = preload("res://Scripts/Tiles/Tile.gd")

var _map

var movement_range = 4

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

func init(map):
	_map = map

func set_starting_tile(starting_tile):
	_current_tiles = get_moveable_tiles_in_range(starting_tile, movement_range)
	for tile in _current_tiles:
		tile.set_pathing_data(_indicator_script.PathingData.REACHABLE)



func get_path_from_tile(tile, pathable_tiles = null):
	if not pathable_tiles:
		pathable_tiles = _current_tiles
	var path = []
	if not tile in pathable_tiles:
		return path
	var path_data = tile.find_node("PathData")
	while path_data.previous_tile:
		path.push_front(tile)
		tile = path_data.previous_tile
		path_data = tile.find_node("PathData")
	
	path.push_front(tile)
	return path
	

func get_moveable_tiles_in_range(starting_tile, max_distance):
	clear_search()
	var returned_tiles = []
	
	var check_now = []
	var check_next = []
	
	starting_tile.find_node("PathData").distance = 0
	check_now.push_back(starting_tile)
	
	while (check_now.size() > 0):
		var current_tile = check_now.pop_front()
		
		var current_tile_path_data = current_tile.find_node("PathData")
		for direction in _DIRECTIONS_TO_CHECK:
			var check_direction = current_tile.map_position + direction
			if not _map.is_valid_map_position(check_direction):
				continue
			
			if check_direction.x < 0 or check_direction.y < 0 or check_direction.x >= _map.map_size.x or check_direction.y >= _map.map_size.y:
				continue
			var next_tile = _map.get_tile_from_map(check_direction)
			var next_tile_path_data = next_tile.find_node("PathData")
			if next_tile_path_data.distance <= current_tile_path_data.distance + _DIRECTION_WEIGHTS[direction]:
				continue
			
			if not next_tile.filter_pathing():
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
	hide_path()
	for tile in path:
		tile.set_pathing_data(_indicator_script.PathingData.PATH)

func hide_path():
	for tile in _current_tiles:
		if tile.get_pathing_data() == _indicator_script.PathingData.PATH:
			tile.set_pathing_data(_indicator_script.PathingData.REACHABLE)

func clear_search():
	var tiles = _map.get_tiles()
	for tile in tiles:
		tile.set_pathing_data(_indicator_script.PathingData.NONE)
	_current_tiles.clear()
