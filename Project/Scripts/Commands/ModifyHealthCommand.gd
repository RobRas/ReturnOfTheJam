extends Node2D

signal execution_completed(command)
signal reverse_completed(command)

var _unit
var _amount_to_modify

var cost = 1

func init(unit, amount_to_modify):
	_unit = unit
	_amount_to_modify = amount_to_modify

func can_execute():
	return true

func execute():
	_unit.current_health += _amount_to_modify
	yield(get_tree(), "idle_frame") # Need to yield for History
	emit_signal("execution_completed", self)

func can_reverse():
	return true

func reverse():
	_unit.current_health -= _amount_to_modify
	yield(get_tree(), "idle_frame") # Need to yield for History
	emit_signal("reverse_completed", self)
