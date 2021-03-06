extends Node2D

export(NodePath) var rewind_state_path
var _rewind_state

export(NodePath) var map_node_path
var _map

var enabled = false

func _ready():
	_rewind_state = get_node(rewind_state_path)
	_map = get_node(map_node_path)

func enter(unit):
	enabled = true
	unit.reverse()
	yield(unit, "reverse_completed")
	enabled = false
	_rewind_state.enter()
