extends Node2D

const DAMAGE_VALUE = 1

var _tile

func init(tile):
	_tile = tile

func filter_pathing():
	return false

func collide(unit):
	unit.damage(DAMAGE_VALUE)
