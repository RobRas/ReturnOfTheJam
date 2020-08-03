extends Node2D

export(NodePath) var player_select_state_path
var _player_select_state

var enabled = false

func _ready():
	_player_select_state = get_node(player_select_state_path)

func enter(ally):
	_player_select_state.enter()
