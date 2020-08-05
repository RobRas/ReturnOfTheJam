extends Node2D

func init(map):
	for baddy in get_children():
		var tile = map.get_tile_from_world(baddy.global_position)
		baddy.init(tile, map)
