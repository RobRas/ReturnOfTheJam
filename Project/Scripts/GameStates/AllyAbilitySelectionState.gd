extends Node2D

export(NodePath) var player_select_state_path
var _player_select_state

var _ally

var enabled = false

func _ready():
	_player_select_state = get_node(player_select_state_path)

func _process(delta):
	if not enabled:
		return
	
	if Input.is_action_just_pressed("skip_ability"):
		enabled = false
		_player_select_state.enter()

func enter(ally):
	_ally = ally
	enabled = true
