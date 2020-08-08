extends Node2D

var cost = 1

const _fire_wall_scene = preload("res://Scenes/Hazards/FireWall.tscn")

signal execution_completed(command)
signal reverse_completed(command)

var dir_to_rot = {
	Vector2( 1,  0): 0,
	Vector2( 1,  1): 45,
	Vector2( 0,  1): 90,
	Vector2(-1,  1): 135,
	Vector2(-1,  0): 180,
	Vector2(-1, -1): 225,
	Vector2( 0, -1): 270,
	Vector2( 1, -1): 315
}
var _flames = {}

var _flame_pivot
var _rotation
var _target_tiles
var _map
var _unit
var _sprite

func init(flame_pivot, direction, target_tiles, map,unit):
	_flame_pivot = flame_pivot
	_rotation = dir_to_rot[direction]
	_target_tiles = target_tiles
	_map = map
	_unit=unit
	_sprite=unit.get_node("Sprite")

func can_execute():
	return true

func execute():
	print("EXE")
	$AudioStreamPlayer.play()
	_flame_pivot.play(_rotation)
	_sprite.play("attack")
	yield(_flame_pivot, "animation_finished")
	print("Yielded")
	_sprite.play("idle")
	for tile in _target_tiles:
		var fire_wall_node = _fire_wall_scene.instance()
		_map.get_node("YSort/Hazards").add_child(fire_wall_node)
		fire_wall_node.global_position = tile.global_position
		fire_wall_node.init(tile)
		tile.add_hazard(fire_wall_node)
		_flames[tile] = fire_wall_node
	emit_signal("execution_completed", self)


func can_reverse():
	return true

func reverse():
	_flame_pivot.reverse(_rotation)
	$ReversedAudioStreamPlayer.play()
	
	_sprite.play("attack",true)
	_sprite.play("idle")
	for tile in _target_tiles:
		if not tile:
			continue
		if not _flames.has(tile):
			continue
		var flame = _flames[tile]
		tile.remove_hazard(flame)
		flame.queue_free()
	yield($ReversedAudioStreamPlayer,"finished")
	_sprite.play("idle")
	emit_signal("reverse_completed", self)
