extends Node2D

signal movement_finished(ai)
signal ability_used(ai)

var _unit

func init(unit):
	_unit = unit

func movement(map):
	print("Floaty Movement")
	yield(get_tree(), "idle_frame")
	emit_signal("movement_finished", self)
	
func ability():
	print("Floaty Ability")
	yield(get_tree(), "idle_frame")
	emit_signal("ability_used", self)
