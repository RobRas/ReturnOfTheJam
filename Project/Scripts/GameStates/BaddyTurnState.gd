extends Node2D

export(NodePath) var rewind_state_path
var _rewind_state


export(NodePath) var map_path
var _map

export(NodePath) var pathfinder_path
var _pathfinder

var enabled = false
var _baddies

func _ready():
	_map = get_node(map_path)
	_pathfinder = get_node(pathfinder_path)
	_rewind_state = get_node(rewind_state_path)

func enter():
	enabled = true
	_baddies = _map.get_baddies()
	$AudioStreamPlayer.play()
	_map.set_show_open_tiles(false)
	for baddy in _baddies:
		if baddy.dead:
			continue
		var starting_tile = baddy.current_tile
		var pathable_tiles = _pathfinder.get_moveable_tiles_in_range(starting_tile, 5)
		var tile_index = randi() % pathable_tiles.size()
		var target_tile = pathable_tiles[tile_index]
		var path = _pathfinder.get_path_from_tile(target_tile, pathable_tiles)
		baddy.connect("destination_reached", self, "_on_baddy_destination_reached", [baddy])
		baddy.move_along_path(path)

func _on_baddy_destination_reached(tile, baddy):
	baddy.disconnect("destination_reached", self, "_on_baddy_destination_reached")
	_baddies.erase(baddy)
	if _baddies.size() == 0:
		$AudioStreamPlayer.stop()
		enabled = false
		_rewind_state.refresh()
		_rewind_state.enter()
