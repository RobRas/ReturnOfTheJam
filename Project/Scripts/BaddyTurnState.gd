extends Node2D


export(NodePath) var map_path
var _map

export(NodePath) var player_select_state_path
var _player_select_state

var enabled = false

func _ready():
	_map = get_node(map_path)
	_player_select_state = get_node(player_select_state_path)

func enter():
	enabled = true

func _process(delta): #delay for now so we can go back to player_select_state without still triggering its _input
	if not enabled:
		return
	
	enabled = false
	var allies = _map.get_allies()
	for ally in allies:
		ally.make_selectable()
	_player_select_state.enter()
