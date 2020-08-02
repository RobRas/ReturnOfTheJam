extends Node2D

signal reversal_completed

var _path
var _movement_node

func init(path, movement_node):
	_path = path
	_movement_node = movement_node

func can_reverse():
	return not _movement_node.is_moving()

func reverse():
	_movement_node.connect("destination_reached", self, "_on_movement_node_destination_reached")
	_path.invert()
	_movement_node.move_along_path(_path, false)

func _on_movement_node_destination_reached(_tile):
	_movement_node.disconnect("destination_reached", self, "_on_movement_node_destination_reached")
	emit_signal("reversal_completed")
