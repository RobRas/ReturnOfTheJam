extends Node2D


func init(map):
	for ally in get_children():
		var tile = map.get_tile_from_world(ally.global_position)
		ally.init(tile)
