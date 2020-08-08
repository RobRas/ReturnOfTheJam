extends Node2D

export(NodePath) var rewind_state_path
var _rewind_state


export(NodePath) var map_path
var _map

export(NodePath) var pathfinder_path
var _pathfinder

var enabled = false
var _baddy_count = 0

func _ready():
	_map = get_node(map_path)
	_pathfinder = get_node(pathfinder_path)
	_rewind_state = get_node(rewind_state_path)

func enter():
	enabled = true
	_baddy_count = _map.get_baddies().size()
	$AudioStreamPlayer.play()
	_map.set_show_open_tiles(false)
	for baddy in _map.get_baddies():
		if baddy.dead:
			_baddy_count -= 1
			continue
		
		var ai = baddy.get_node("AI")
		ai.connect("movement_finished", self, "_on_baddy_movement_finished")
		ai.movement(_map)

func _on_baddy_movement_finished(ai):
	ai.disconnect("movement_finished", self, "_on_baddy_movement_finished")
	_baddy_count -= 1
	if _baddy_count == 0:
		$AudioStreamPlayer.stop()
		use_abilities()

func use_abilities():
	var baddies = _map.get_baddies()
	for baddy in baddies:
		if baddy.dead:
			continue
		
		var ai = baddy.get_node("AI")
		ai.ability(_map)
		yield(ai, "ability_used")
	
	enabled = false
	_rewind_state.refresh()
	_rewind_state.enter()
	

"""
func _on_baddy_destination_reached(tile, baddy):
	baddy.disconnect("destination_reached", self, "_on_baddy_destination_reached")
	_baddies.erase(baddy)
	if _baddies.size() == 0:
		$AudioStreamPlayer.stop()
		enabled = false
		_rewind_state.refresh()
		_rewind_state.enter()
"""
