extends Node2D

export(NodePath) var player_selected_state_path
var _player_selected_state

export(NodePath) var pathfinder_path
var _pathfinder

var _ally
var _path

var enabled = false

func _ready():
	_player_selected_state = get_node(player_selected_state_path)
	_pathfinder = get_node(pathfinder_path)

func enter(ally, path):
	enabled = true
	_ally = ally
	_path = path
	_ally.move_along_path(path)
	yield(_ally, "destination_reached")
	_pathfinder.clear_search()
	enabled = false
	_player_selected_state.enter()
