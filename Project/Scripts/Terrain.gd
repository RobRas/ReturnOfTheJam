extends Node2D

var tile_scene = preload("res://Scenes/Tile.tscn")
var tile_script = preload("res://Scripts/Tile.gd")

var _map = []
onready var _tile_map = $TileMap
var _map_size

func _ready():
	_map_size = _tile_map.get_used_rect().size
	for y in range(_map_size.y):
		for x in range(_map_size.x):
			var cell_position = Vector2(x, y)
			var cell_index = _tile_map.get_cellv(cell_position)
			var tile = tile_scene.instance()
			
			var world_position = _tile_map.map_to_world(cell_position) + _tile_map.cell_size / 2.0
			$Tiles.add_child(tile)
			tile.init(cell_position, world_position, cell_index)
			_map.push_back(tile)
	
	for player in $Allies.get_children():
		var tile = get_tile_from_world(player.global_position)
		player.init(tile)
	
	for baddy in $Baddies.get_children():
		var tile = get_tile_from_world(baddy.global_position)
		baddy.set_current_tile(tile)
		baddy.global_position = tile.global_position
	
	$Pathfinder.init()

func is_valid_map_position(map_position):
	var index = _get_map_index(map_position)
	return index in range(_map.size())

func is_valid_world_position(world_position):
	if world_position.x < 0 or world_position.x > _map_size.x * _tile_map.cell_size.x:
		return false
	if world_position.y < 0 or world_position.y > _map_size.y * _tile_map.cell_size.y:
		return false
	
	var map_position = _tile_map.world_to_map(world_position)
	return is_valid_map_position(map_position)

func get_tile_from_map(map_position):
	return _map[_get_map_index(map_position)]

func get_tile_from_world(world_position):
	var map_position = _tile_map.world_to_map(world_position)
	return get_tile_from_map(map_position)

func _get_map_index(map_position):
	return map_position.y * _map_size.x + map_position.x
