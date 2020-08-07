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

func init(flame_pivot, direction, target_tiles, map):
	_flame_pivot = flame_pivot
	_rotation = dir_to_rot[direction]
	_target_tiles = target_tiles
	_map = map

func can_execute():
	return true

func execute():
	$AudioStreamPlayer.play()
	_flame_pivot.play(_rotation)
	yield(_flame_pivot, "animation_finished")
	for tile in _target_tiles:
		var fire_wall_node = _fire_wall_scene.instance()
		_map.get_node("YSort/Hazards").add_child(fire_wall_node)
		fire_wall_node.global_position = tile.global_position
		fire_wall_node.init(tile)
		tile.add_hazard(fire_wall_node)
		_flames[tile] = fire_wall_node
	yield(get_tree(), "idle_frame")
	emit_signal("execution_completed", self)


func can_reverse():
	return true

func reverse():
	_flame_pivot.reverse(_rotation)
	for tile in _target_tiles:
		if not tile:
			continue
		if not _flames.has(tile):
			continue
		var flame = _flames[tile]
		tile.remove_hazard(flame)
		flame.queue_free()
	yield(get_tree(), "idle_frame")
	emit_signal("reverse_completed", self)
