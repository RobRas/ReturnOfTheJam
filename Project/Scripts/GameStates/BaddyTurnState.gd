extends Node2D

export(NodePath) var rewind_state_path
var _rewind_state


export(NodePath) var map_path
var _map

export(NodePath) var pathfinder_path
var _pathfinder

var enabled = false
var _baddies = []

func _ready():
	_map = get_node(map_path)
	_pathfinder = get_node(pathfinder_path)
	_rewind_state = get_node(rewind_state_path)

func enter():
	enabled = true
	_baddies = _map.get_baddies()
	$AudioStreamPlayer.play()
	_map.set_show_open_tiles(false)
	print(_baddies.size())
	for baddy in _baddies:
		if baddy.dead:
			continue
		
		var ai = baddy.get_node("AI")
		ai.connect("movement_finished", self, "_on_baddy_movement_finished")
		print(baddy.name + " Connect")
		ai.movement(_map)

func _on_baddy_movement_finished(ai):
	print(ai._unit.name + " Disconnect")
	ai.disconnect("movement_finished", self, "_on_baddy_movement_finished")
	_baddies.erase(ai._unit)
	if _baddies.size() == 0:
		$AudioStreamPlayer.stop()
		use_abilities()

func use_abilities():
	var baddies = _map.get_baddies()
	for baddy in baddies:
		if baddy.dead:
			continue
		
		var ai = baddy.get_node("AI")
		ai.ability()
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
