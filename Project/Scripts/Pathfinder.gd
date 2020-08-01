extends Node2D

export(NodePath) var player_node
var player

var _indicator_scene = preload("res://Scenes/PathfindingIdicator.tscn")
var _indicator_pool = []
var _active_indicators = {}

export(NodePath) var tiles_scene
var _tiles

var _starting_tile
var _current_tiles = []

onready var _map = get_parent()

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
	player = get_node(player_node)
	for _i in range(30):
		_indicator_pool.push_back(_indicator_scene.instance())
	_tiles = get_node(tiles_scene)
	clear_search()

func init():
	set_starting_tile(player.global_position)

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if not _map.is_valid_world_position(event.position):
			return
			
		var tile = _map.get_tile_from_world(event.position)
		if not _active_indicators.has(tile):
			return
		
		var path = get_path_from_tile(tile)
		if path.size() > 0:
			player.move_along_path(path)
			clear_search()
		
	if event is InputEventMouseMotion:
		if _map.is_valid_world_position(event.position):
			for indicator in _active_indicators.values():
				indicator.modulate = Color.blue
				
			var current_tile = _map.get_tile_from_world(event.position)
			var current_tile_path_data = current_tile.find_node("PathData")
			
			if _current_tiles.size() > 0:
				if _active_indicators.has(current_tile):
					if current_tile_path_data.previous_tile:
						_active_indicators[current_tile].modulate = Color.yellow
						while current_tile_path_data.previous_tile:
							_active_indicators[current_tile].modulate = Color.yellow
							current_tile = current_tile_path_data.previous_tile
							current_tile_path_data = current_tile.find_node("PathData")
					_active_indicators[current_tile].modulate = Color.yellow
			

func set_starting_tile(world_position):
	if _map.is_valid_world_position(world_position):
		_starting_tile = _map.get_tile_from_world(world_position)
		var clicked_tile_position = _starting_tile.map_position
		_current_tiles = get_moveable_tiles_in_range(clicked_tile_position, 3)
		if _indicator_pool.size() < _current_tiles.size():
			for _i in range(_current_tiles.size() - _indicator_pool.size()):
				_indicator_pool.push_back(_indicator_scene.instance())
		for i in range(_current_tiles.size()):
			var tile = _current_tiles[i]
			var indicator = _indicator_pool[i]
			add_child(indicator)
			_active_indicators[tile] = indicator
			indicator.global_position = tile.global_position
			indicator.modulate = Color.blue

func get_path_from_tile(tile):
	var path = []
	var path_data = tile.find_node("PathData")
	while path_data.previous_tile:
		path.push_front(tile)
		tile = path_data.previous_tile
		path_data = tile.find_node("PathData")
	
	return path
	

func get_moveable_tiles_in_range(starting_map_position, max_distance):
	var returned_tiles = []
	
	if not _map.is_valid_map_position(starting_map_position):
		return returned_tiles
	
	_starting_tile = _map.get_tile_from_map(starting_map_position)
	returned_tiles.push_back(_starting_tile)
	
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
			
			if not next_tile.current_state == next_tile.State.OPEN:
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

func clear_search():
	_current_tiles.clear()
	_active_indicators.clear()
	for child_tiles in get_children():
		remove_child(child_tiles)
	for tile in _tiles.get_children():
		tile.find_node("PathData").clear()


func _on_Player_destination_reached(tile):
	set_starting_tile(tile.global_position)
