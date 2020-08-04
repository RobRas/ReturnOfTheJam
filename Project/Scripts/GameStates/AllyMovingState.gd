extends Node2D

export(NodePath) var ally_ability_selection_state_path
var _ally_ability_selected_state

export(NodePath) var pathfinder_path
var _pathfinder

var enabled = false

func _ready():
	_ally_ability_selected_state = get_node(ally_ability_selection_state_path)
	_pathfinder = get_node(pathfinder_path)

func enter(ally, path):
	enabled = true
	ally.move_along_path(path)
	yield(ally, "destination_reached")
	_pathfinder.clear_search()
	enabled = false
	_ally_ability_selected_state.enter(ally)
