extends Node2D

const _x_attack_command = preload("res://Scenes/Commands/XAttackCommand.tscn")

signal movement_finished(ai)
signal ability_used(ai)

var damage = 2

var pattern = [
	Vector2(0,0),
	Vector2(1,1),
	Vector2(1,-1),
	Vector2(-1,-1),
	Vector2(-1,1)
]

var _unit

func init(unit):
	_unit = unit

func movement(map):
	print("XAlien Movement")
	yield(get_tree(), "idle_frame")
	emit_signal("movement_finished", self)
	
func ability(map):
	var allies = map.get_allies()
	if allies.size() == 0:
		yield(get_tree(), "idle_frame")
		emit_signal("ability_used", self)
		return
	
	var chosen_ally_index = randi() % allies.size()
	var ally = allies[chosen_ally_index]
	var tile_position = map.get_map_position_from_tile(ally.current_tile)
	
	var target_tiles = []
	for offset in pattern:
		var target_position = tile_position + offset
		var tile = map.get_tile_from_map(target_position)
		target_tiles.push_back(tile)
	
	var command = _x_attack_command.instance()
	command.init(ally.current_tile, target_tiles, map, _unit)
	_unit.get_node("History").execute_command(command)
	yield(command, "execution_completed")
	emit_signal("ability_used", self)
