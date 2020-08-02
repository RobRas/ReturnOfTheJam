extends Node2D

var tile_script = preload("res://Scripts/Tile.gd")

export(NodePath) var map_node_path
var _map

export(NodePath) var ally_selected_state_path
var _ally_selected_state

var enabled = false

func _ready():
	_map = get_node(map_node_path)
	_ally_selected_state = get_node(ally_selected_state_path)

func enter():
	enabled = true
	
	var allies = _map.get_allies()
	var selectable_count = allies.size()
	for ally in allies:
		if not ally.selectable:
			selectable_count -= 1
	
	if selectable_count == 0:
		print("Baddy's turn")
	
	

func _input(event):
	if not enabled:
		return
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if not _map.is_valid_world_position(event.position):
			return
			
		var tile = _map.get_tile_from_world(event.position)
		
		if tile.current_state == tile_script.State.UNIT_ALLY:
			var ally = tile.unit
			if ally.selectable:
				enabled = false
				_ally_selected_state.enter(ally)
