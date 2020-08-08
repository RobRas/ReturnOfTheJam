extends Node2D

signal movement_finished(ai)
signal ability_used(ai)

const _teleport_command = preload("res://Scenes/Commands/TeleportCommand.tscn")

export(NodePath) var _unit_sprite_path
var _unit_sprite

var _teleport_cooldown = 3
var _current_teleport_cooldown = 0
var _teleport_distance_from_ally = 4

var _unit

func _ready():
	_unit_sprite = get_node(_unit_sprite_path)

func init(unit):
	_unit = unit

func movement(map):
	print("TeleportAlien Movement")
	var allies = map.get_allies()
	var farthest_ally = null
	var farthest_distance = 0
	for ally in allies:
		var distance = map.distance(ally.current_tile, _unit.current_tile)
		if distance > farthest_distance:
			farthest_ally = ally
			farthest_distance = distance
	
	if not farthest_ally:
		yield(get_tree(), "idle_frame")
		return
	
	var pathfinder = map.get_pathfinder()
	var tiles_in_ally_range = pathfinder.get_moveable_tiles_in_range(farthest_ally.current_tile, _teleport_distance_from_ally)
	for i in range(tiles_in_ally_range.size()-1, -1, -1):
		if (map.distance(farthest_ally, tiles_in_ally_range[i]) < _teleport_distance_from_ally):
			tiles_in_ally_range.remove(i)
			continue
		if (tiles_in_ally_range[i].enemy_target):
			tiles_in_ally_range.remove(i)
			continue
	
	
	var tile_index = randi() % tiles_in_ally_range.size()
	var tile = tiles_in_ally_range[tile_index]
	tile.enemy_target = true
	
	var command = _teleport_command.instance()
	command.init(_unit, tile)
	var history = _unit.get_node("History")
	history.execute_command(command)
	yield(history, "execution_completed")
	tile.enemy_target = false
	emit_signal("movement_finished", self)
	
func ability():
	print("TeleportAlien Ability")
	yield(get_tree(), "idle_frame")
	emit_signal("ability_used", self)
