extends Node2D

signal execution_completed(command)
signal reverse_completed(command)

var _movement_node
var _starting_tile
var _target_tile

func init(movement_node, starting_tile, target_tile):
	_movement_node = movement_node
	_starting_tile = starting_tile
	_target_tile = target_tile

func can_execute():
	return _movement_node.can_move()

func execute():
	_movement_node.move_to_tile(_target_tile)
	yield(_movement_node, "tile_reached")
	emit_signal("execution_completed", self)

func can_reverse():
	return _movement_node.can_move()

func reverse():
	_movement_node.move_to_tile(_starting_tile)
	yield(_movement_node, "tile_reached")
	emit_signal("reverse_completed", self)
