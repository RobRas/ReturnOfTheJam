extends Node2D

var _previous_tile

func _input(event):
	if event is InputEventMouseMotion:
		if get_parent().is_valid_world_position(event.position):
			var hovered_tile = get_parent().get_tile_from_world(event.position)
			if not _previous_tile:
				_previous_tile = hovered_tile
				_previous_tile.select_indicator(true)
			elif _previous_tile != hovered_tile:
				_previous_tile.select_indicator(false)
				_previous_tile = hovered_tile
				_previous_tile.select_indicator(true)
