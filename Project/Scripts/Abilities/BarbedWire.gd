extends Node2D

const DAMAGE_VALUE = 2

var _tile

func init(tile):
	_tile = tile

func filter_pathing():
	return false

func collide(unit):
	unit.damage(DAMAGE_VALUE)
	_tile.remove_hazard()
	queue_free()
