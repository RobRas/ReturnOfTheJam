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
			tile.init(cell_position, cell_index)
			_map.push_back(tile)
	
	print(get_tile(Vector2(5, 2)).current_state)
	print(get_tile(Vector2(4, 2)).current_state)
	print(get_tile(Vector2(2, 5)).current_state)

func get_tile(tile_position):
	var index = tile_position.y * map_size.x + tile_position.x
	return _map[index]
