extends Node2D

const _EXPLOSION_ANIMATION = preload("res://Scenes/Explosion.tscn")
const _MOVE_COMMAND = preload("res://Scenes/Commands/MovementCommand.tscn")

var cost = 1

const _EXPLOSION_DIRECTIONS = [
	Vector2(1,1),
	Vector2(1,0),
	Vector2(1,-1),
	Vector2(0,1),
	Vector2(0,-1),
	Vector2(-1,1),
	Vector2(-1,0),
	Vector2(-1,-1)
]

const _PULL_TILES = {
	Vector2(-2,-2): Vector2(-1,-1),
	Vector2(-2,-1): Vector2(-1, 0),
	Vector2(-2, 0): Vector2(-1, 0),
	Vector2(-2, 1): Vector2(-1, 0),
	Vector2(-2, 2): Vector2(-1, 1),
	
	Vector2(-1,-2): Vector2( 0,-1),
	Vector2( 0,-2): Vector2( 0,-1),
	Vector2( 1,-2): Vector2( 0,-1),
	
	Vector2( 2,-2): Vector2( 1,-1),
	Vector2( 2,-1): Vector2( 1, 0),
	Vector2( 2, 0): Vector2( 1, 0),
	Vector2( 2, 1): Vector2( 1, 0),
	Vector2( 2, 2): Vector2( 1, 1),
	
	Vector2(-1, 2): Vector2( 0, 1),
	Vector2( 0, 2): Vector2( 0, 1),
	Vector2( 1, 2): Vector2( 0, 1),
}

const _COLLISION_DAMAGE = 1

signal execution_completed(command)
signal reverse_completed(command)

var _target_tile_position
var _map
var _user

var _units_to_wait_for_path = 0

var _explosion_animation

func init(user, target_tile, map):
	_user = user
	_map = map
	_target_tile_position = _map.get_map_position_from_tile(target_tile)

func can_execute():
	return true

func execute():
	_user.get_node("Sprite").play("attack")
	$AudioStreamPlayer.play()
	_explosion_animation = _EXPLOSION_ANIMATION.instance()
	_explosion_animation.animation = "default"
	_explosion_animation.connect("animation_finished", self, "_on_explosion_animation_finished")
	_map.add_child(_explosion_animation)
	_explosion_animation.global_position = _map.get_tile_from_map(_target_tile_position).global_position
	_explosion_animation.play()
	
	_units_to_wait_for_path = 0
	for direction in _EXPLOSION_DIRECTIONS:
		var push_from_tile_position = _target_tile_position + direction
		if not _map.is_valid_map_position(push_from_tile_position):
			continue
			
		var push_from_tile = _map.get_tile_from_map(push_from_tile_position)
		
		var push_to_tile_position = push_from_tile_position + direction
		if not _map.is_valid_map_position(push_to_tile_position):
			continue
		
		if not push_from_tile.unit:
			continue
		
		var pushed_unit = push_from_tile.unit
		var push_to_tile = _map.get_tile_from_map(push_to_tile_position)
		if push_to_tile.permanent_blocked:
			pushed_unit.damage(_COLLISION_DAMAGE)
			continue
		
		if push_to_tile.unit:
			pushed_unit.damage(_COLLISION_DAMAGE)
			push_to_tile.unit.damage(_COLLISION_DAMAGE)
			continue
		
		_units_to_wait_for_path += 1
		pushed_unit.connect("destination_reached", self, "_on_unit_destination_reached")
		
		if pushed_unit == _user:
			pushed_unit.move_along_path([push_from_tile, push_to_tile], 0)
		else:
			pushed_unit.move_along_path([push_from_tile, push_to_tile])
	
	if _units_to_wait_for_path == 0:
		yield(get_tree(), "idle_frame") # Needed for History's yield
		emit_signal("execution_completed")
	


func can_reverse():
	return true

func reverse():
	_map.add_child(_explosion_animation)
	_explosion_animation.animation = "reverse"
	_explosion_animation.play()
	print_debug("Here")
	$ReversedAudioStreamPlayer.play()
	_units_to_wait_for_path = 0
	for pull_tile in _PULL_TILES.keys():
		var pull_from_tile_position = _target_tile_position + pull_tile
		if not _map.is_valid_map_position(pull_from_tile_position):
			continue
			
		var pull_from_tile = _map.get_tile_from_map(pull_from_tile_position)
		
		if not pull_from_tile.unit:
			continue
		var pulled_unit = pull_from_tile.unit
		
		var pull_to_tile_position = _target_tile_position + _PULL_TILES[pull_tile]
		if not _map.is_valid_map_position(pull_to_tile_position):
			continue
		
		var pull_to_tile = _map.get_tile_from_map(pull_to_tile_position)
		if pull_to_tile.permanent_blocked:
			pulled_unit.damage(_COLLISION_DAMAGE)
			continue
		
		if pull_to_tile.unit:
			pulled_unit.damage(_COLLISION_DAMAGE)
			pull_to_tile.unit.damage(_COLLISION_DAMAGE)
			continue
		
		if pulled_unit == _user:
			continue
		
		_units_to_wait_for_path += 1
		pulled_unit.connect("destination_reached", self, "_on_unit_destination_reached_reverse")
		pulled_unit.move_along_path([pull_from_tile, pull_to_tile])
		
	if _units_to_wait_for_path == 0:
		yield($ReversedAudioStreamPlayer,"finished")
		yield(get_tree(), "idle_frame")
		emit_signal("reverse_completed")


func _on_unit_destination_reached(tile):
	tile.unit.disconnect("destination_reached", self, "_on_unit_destination_reached")
	_units_to_wait_for_path -= 1
	if _units_to_wait_for_path == 0:
		emit_signal("execution_completed", self)

func _on_unit_destination_reached_reverse(tile):
	tile.unit.disconnect("destination_reached", self, "_on_unit_destination_reached_reverse")
	_units_to_wait_for_path -= 1
	if _units_to_wait_for_path == 0:
		emit_signal("reverse_completed", self)

func _on_explosion_animation_finished():
	_explosion_animation.stop()
	_map.remove_child(_explosion_animation)
