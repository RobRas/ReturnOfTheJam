extends Node2D

signal movement_finished(ai)
signal ability_used(ai)

const _teleport_command = preload("res://Scenes/Commands/TeleportCommand.tscn")

export(NodePath) var _unit_sprite_path
var _unit_sprite

var _teleport_cooldown = 3
var _current_teleport_cooldown = 0
var _teleport_distance_from_ally = 2

var _attack_damage = 2

var _unit
var _target

var offsets = [
	Vector2(1,1),
	Vector2(1,0),
	Vector2(1,-1),
	Vector2(0,1),
	Vector2(0,-1),
	Vector2(-1,1),
	Vector2(-1,0),
	Vector2(-1,-1)
]

func _ready():
	_unit_sprite = get_node(_unit_sprite_path)

func init(unit):
	_unit = unit

func movement(map):
	print("TeleportAlien Movement")
	if _current_teleport_cooldown <= 0:
		teleport(map)
	elif not in_melee_range(map):
		_current_teleport_cooldown -= 1
		approach_target(map)
	

func teleport(map):
	var allies = map.get_allies()
	var farthest_distance = 0
	for ally in allies:
		var distance = map.distance(ally.current_tile, _unit.current_tile)
		if distance > farthest_distance:
			_target = ally
			farthest_distance = distance
	
	if not _target:
		yield(get_tree(), "idle_frame")
		emit_signal("movement_finished")
		return
	
	var pathfinder = map.get_pathfinder()
	var tiles_in_ally_range = pathfinder.get_moveable_tiles_in_range(_target.current_tile, _teleport_distance_from_ally)
	for i in range(tiles_in_ally_range.size()-1, -1, -1):
		var target_pos = map.get_map_position_from_tile(tiles_in_ally_range[i])
		var target_unit_pos = map.get_map_position_from_tile(_target.current_tile)
		var distance = (target_pos - target_unit_pos).abs()
		print(distance)
		if distance.x < _teleport_distance_from_ally and distance.y < _teleport_distance_from_ally:
			tiles_in_ally_range.remove(i)
			continue
		if (tiles_in_ally_range[i].enemy_target):
			tiles_in_ally_range.remove(i)
			continue
	
	if tiles_in_ally_range.size() == 0:
		emit_signal("movement_finished", self)
		return
	
	var tile_index = randi() % tiles_in_ally_range.size()
	var tile = tiles_in_ally_range[tile_index]
	tile.enemy_target = true
	_current_teleport_cooldown = _teleport_cooldown
	
	var command = _teleport_command.instance()
	command.init(_unit, tile)
	var history = _unit.get_node("History")
	history.execute_command(command)
	yield(history, "execution_completed")
	tile.enemy_target = false
	emit_signal("movement_finished", self)
	

func approach_target(map):
	var pathfinder = map.get_pathfinder()
	var moveable_tiles = pathfinder.get_moveable_tiles_in_range(_unit.current_tile, 7)
	var paths = []
	var target_tile_pos = map.get_map_position_from_tile(_target)
	for offset in offsets:
		var pos = target_tile_pos + offset
		if not map.is_valid_map_position(pos):
			continue
		var offset_tile = map.get_tile_from_map(pos)
		paths.push_back(pathfinder.get_path_from_tile(offset_tile, moveable_tiles))
	
	if paths.size() == 0:
		teleport(map)
	
	var shortest_path = null
	for path in paths:
		if path.size() == 0:
			continue
		if shortest_path == null:
			shortest_path = path
		if path.size() < shortest_path.size():
			shortest_path = path
	
	if shortest_path == null:
		teleport(map)
	else:
		_unit.move_along_path(shortest_path)
		yield(_unit, "destination_reached")
		emit_signal("movement_finished", self)
	

func ability(map):
	print("TeleportAlien Ability")
	if not _target:
		yield(get_tree(), "idle_frame")
		emit_signal("ability_used", self)
		return
	
	var target_pos = map.get_map_position_from_tile(_target.current_tile)
	var self_pos = map.get_map_position_from_tile(_unit.current_tile)
	
	var diff = target_pos - self_pos
	
	if abs(diff.x) > 1 or abs(diff.y) > 1:
		yield(get_tree(), "idle_frame")
		emit_signal("ability_used", self)
		return
	
	_target.damage(_attack_damage)
	_unit_sprite.animation = "attack"
	_unit_sprite.play()
	yield(_unit_sprite, "animation_finished")
	_unit_sprite.animation = "idle"
	_unit_sprite.play()
	emit_signal("ability_used", self)
	

func in_melee_range(map):
	var target_pos = map.get_map_position_from_tile(_target.current_tile)
	var self_pos = map.get_map_position_from_tile(_unit.current_tile)
	
	var diff = target_pos - self_pos
	
	return abs(diff.x) <= 1 and abs(diff.y) <= 1
