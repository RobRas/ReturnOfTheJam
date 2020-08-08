extends Node2D

signal execution_completed(command)
signal reverse_completed(command)

signal new_tile_reached(tile)

var _movement_node
var _starting_tile
var _target_tile

var _unit

var collision_damage = 1

var cost = 1

func init(unit, movement_node, starting_tile, target_tile):
	_unit = unit
	_movement_node = movement_node
	_starting_tile = starting_tile
	_target_tile = target_tile

func can_execute():
	return _movement_node.can_move()

func execute():
	if _target_tile.unit:
		_target_tile.unit.damage(collision_damage)
		_unit.damage(collision_damage)
		yield(get_tree(), "idle_frame")
		emit_signal("execution_completed", self)
		return
	_movement_node.move_to_tile(_target_tile)
	yield(_movement_node, "movement_tween_completed")
	emit_signal("new_tile_reached", _target_tile)
	emit_signal("execution_completed", self)

func can_reverse():
	return _movement_node.can_move()

func reverse():
	if _starting_tile.unit:
		_unit.damage(collision_damage)
		_starting_tile.unit.damage(collision_damage)
		yield(get_tree(), "idle_frame")
		emit_signal("reverse_completed", self)
		return
	_movement_node.move_to_tile(_starting_tile)
	yield(_movement_node, "movement_tween_completed")
	emit_signal("new_tile_reached", _starting_tile)
	emit_signal("reverse_completed", self)
