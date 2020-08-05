extends Node2D

var _tile

func init(tile):
	_tile = tile

func filter_pathing():
	return false

func on_collision(unit):
	pass
