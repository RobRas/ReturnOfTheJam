extends Node2D

var _highlighted_tile

func _input(event):
	if event is InputEventMouseMotion:
		if get_parent().is_valid_world_position(event.position):
			var hovered_tile = get_parent().get_tile_from_world(event.position)
			if hovered_tile != _highlighted_tile:
				pass
				#_highlighted_tile.
