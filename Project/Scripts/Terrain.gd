extends Node2D

export(Vector2) var map_size = Vector2()

var tile_scene = preload("res://Scenes/Tile.tscn")

var _map = []
onready var _tile_map = $TileMap

func _ready():
	for y in range(map_size.y):
		for x in range(map_size.x):
			var cell_position = Vector2(x, y)
			var cell_index = _tile_map.get_cellv(cell_position)
			var tile = tile_scene.instance()
			tile.init(cell_position, _tile_map.map_to_world(cell_position) + _tile_map.cell_size / 2.0, cell_index)
			$Tiles.add_child(tile)
			_map.push_back(tile)
	
	$Pathfinder.init()

func is_valid_map_position(map_position):
	var index = _get_map_index(map_position)
	return index in range(_map.size())

func is_valid_world_position(world_position):
	var map_position = _tile_map.world_to_map(world_position)
	return is_valid_map_position(map_position)

func get_tile_from_map(map_position):
	return _map[_get_map_index(map_position)]

func get_tile_from_world(world_position):
	var map_position = _tile_map.world_to_map(world_position)
	return get_tile_from_map(map_position)

func _get_map_index(map_position):
	return map_position.y * map_size.x + map_position.x
