extends Node2D

func _ready():
	$Map.init()


"""
	TESTING

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		var unit = $Map.get_tile_from_world(event.position).unit
		unit.damage(1)
"""
