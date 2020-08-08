extends Node2D

signal movement_finished(ai)
signal ability_used(ai)

var _distance_until_flee = 6
var _move_speed = 3
var _unit

func init(unit):
	_unit = unit

func movement(map):
	var allies = map.get_allies()
	if allies.size() == 0:
		yield(get_tree(), "idle_frame")
		emit_signal("movement_finished", self)
		return
	var closest = allies[0]
	var closest_distance = map.distance(allies[0].current_tile, _unit.current_tile)
	for ally in map.get_allies():
		var distance = map.distance(ally.current_tile, _unit.current_tile)
		if distance < closest_distance:
			closest_distance = distance
			closest = ally
	
	if closest_distance <= _distance_until_flee:
		flee(map, closest)
		return
	
	yield(get_tree(), "idle_frame")
	emit_signal("movement_finished", self)

func flee(map, ally):
	var starting_position = map.get_map_position_from_tile(_unit.current_tile)
	var running_from_position = map.get_map_position_from_tile(ally.current_tile)
	var direction = running_from_position - starting_position
	direction.x = clamp(direction.x, -1, 1)
	direction.y = clamp(direction.y, -1, 1)
	
	var pathfinder = map.get_pathfinder()
	var pathable_tiles = pathfinder.get_moveable_tiles_in_range(_unit.current_tile, _move_speed)
	
	for i in range(pathable_tiles.size()-1, -1, -1):
		var tile_position = map.get_map_position_from_tile(pathable_tiles[i])
		var offset = tile_position - starting_position
		if sign(offset.x) == sign(direction.x) and sign(offset.y) == sign(direction.y):
			pathable_tiles.remove(i)
	
	var tiles_random_index = randi() % pathable_tiles.size()
	var path = pathfinder.get_path_from_tile(pathable_tiles[tiles_random_index], pathable_tiles)
	_unit.move_along_path(path)
	yield(_unit, "destination_reached")
	emit_signal("movement_finished", self)

func ability(map):
	print("Floaty Ability")
	yield(get_tree(), "idle_frame")
	emit_signal("ability_used", self)
