extends Node2D

const barbed_wire_scene = preload("res://Scenes/Hazards/BarbedWire.tscn")

var cost = 1

signal execution_completed(command)
signal reverse_completed(command)

var _target_tiles = []
var _map

func init(target_tiles, map):
	_target_tiles = target_tiles
	_map = map

func can_execute():
	return true

func execute():
	$AudioStreamPlayer.play()
	for tile in _target_tiles:
		var barbed_wire_node = barbed_wire_scene.instance()
		_map.get_node("YSort/Hazards").add_child(barbed_wire_node)
		barbed_wire_node.global_position = tile.global_position
		barbed_wire_node.init(tile)
		tile.add_hazard(barbed_wire_node)
	yield(get_tree(), "idle_frame")
	emit_signal("execution_completed", self)

func can_reverse():
	return true

func reverse():
	for tile in _target_tiles:
		if not tile:
			continue
		var wire = tile.hazard
		if not wire:
			continue
		wire.queue_free()
		tile.remove_hazard()
	yield(get_tree(), "idle_frame")
	emit_signal("reverse_completed", self)
