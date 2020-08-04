extends TileMap

var tile_scene = preload("res://Scenes/Tile.tscn")
export(Array, int) var blocker_tile_ids

var _map = []
var _map_size

func _ready():
	_map_size = get_used_rect().size
	var half_cell = cell_size / 2.0
	for y in range(_map_size.y):
		for x in range(_map_size.x):
			var cell_position = Vector2(x, y)
			var cell_index = get_cellv(cell_position)
			
			var tile = tile_scene.instance()
			
			var world_position = map_to_world(cell_position) + half_cell
			$Tiles.add_child(tile)
			tile.init(cell_position, world_position, cell_index in blocker_tile_ids)
			_map.push_back(tile)


func is_valid_map_position(map_position):
	var index = _get_map_index(map_position)
	return index in range(_map.size())

func is_valid_world_position(world_position):
	if world_position.x < 0 or world_position.x > _map_size.x * cell_size.x:
		return false
	if world_position.y < 0 or world_position.y > _map_size.y * cell_size.y:
		return false
	
	var map_position = world_to_map(world_position)
	return is_valid_map_position(map_position)


func get_tile_from_map(map_position):
	return _map[_get_map_index(map_position)]

func get_tile_from_world(world_position):
	var map_position = world_to_map(world_position)
	return get_tile_from_map(map_position)

func get_tiles():
	return $Tiles.get_children()

func get_allies():
	return $Allies.get_children()

func _get_map_index(map_position):
	return map_position.y * _map_size.x + map_position.x
