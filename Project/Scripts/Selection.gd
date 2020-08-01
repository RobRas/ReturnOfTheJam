extends Node2D

func _input(event):
	if event is InputEventMouseMotion:
		if get_parent().is_valid_world_position(event.position):
			global_position = get_parent().get_tile_from_world(event.position).position
