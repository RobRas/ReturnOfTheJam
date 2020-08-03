extends Node2D

signal execution_completed(command)

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
	_movement_node.connect("position_reached", self, "_on_movement_node_position_reached")
	_movement_node.move_to_tile(self, _target_tile)

func can_reverse():
	return _movement_node.can_move()

func reverse():
	_movement_node.connect("position_reached", self, "_on_movement_node_position_reached")
	_movement_node.move_to_tile(self, _starting_tile)

func _on_movement_node_position_reached():
	_movement_node.disconnect("position_reached", self, "_on_movement_node_position_reached")
	emit_signal("execution_completed", self)
