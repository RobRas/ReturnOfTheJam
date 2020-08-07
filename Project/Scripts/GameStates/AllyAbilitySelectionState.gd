extends Node2D

export(NodePath) var map_node_path
var _map

export(NodePath) var player_select_state_path
var _player_select_state

var _ally

var enabled = false

func _ready():
	_player_select_state = get_node(player_select_state_path)
	_map = get_node(map_node_path)


func enter(ally):
	print("AllyAbilitySelectionState: Abilities not yet implemented - press 'space' to continue")
	_ally = ally
	_map.set_show_open_tiles(true)
	for ability in _ally.get_node("Abilities").get_children():
		ability.connect("used", self, "_on_ability_used")
		ability.start_using()
	enabled = true

func _process(delta):
	if not enabled:
		return
	
	if Input.is_action_just_pressed("skip_ability"):
		enabled = false
		_player_select_state.enter()

func _on_ability_used():
	for ability in _ally.get_node("Abilities").get_children():
		ability.stop_using()
		ability.disconnect("used", self, "_on_ability_used")
		enabled = false
		_player_select_state.enter()
