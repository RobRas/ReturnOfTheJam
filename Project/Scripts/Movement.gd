extends Node2D

signal movement_began(path)
signal tile_reached(tile)
signal destination_reached(tile)

const _TILE_SIZE = 16

var _tiles_per_second

var _tile_script = preload("res://Scripts/Tile.gd")
var _movement_action = preload("res://Scenes/MovementAction.tscn")

var path
var next_tile

var current_tile

var _enabled = false
var _moving = false

func init(tiles_per_second, enabled):
	_tiles_per_second = tiles_per_second
	_enabled = enabled

func move_along_path(path_to_follow, record = true):
	if _moving:
		return
	
	path = path_to_follow
	if record:
		var movement_action = _movement_action.instance()
		movement_action.path = path.duplicate()
		$History.push_action(movement_action)
	
	if path.size() > 0:
		_moving = true
		emit_signal("movement_began", path)
	_run_next_tile()

func reverse():
	if not _enabled or _moving:
		return

	if not $History.can_pop():
		return
	
	var action = $History.pop_action()
	action.path.invert()
	move_along_path(action.path, false)

func _run_next_tile():
	if path.size() > 0:
		next_tile = path.pop_front()
		var distance = global_position.distance_to(next_tile.global_position)
		$Tween.interpolate_property(get_parent(), "global_position", global_position, next_tile.global_position, distance / _TILE_SIZE * _tiles_per_second, Tween.TRANS_LINEAR)
		$Tween.start()
	else:
		_moving = false
		emit_signal("destination_reached", next_tile)

func _on_Tween_tween_all_completed():
	emit_signal("tile_reached", next_tile)
	_run_next_tile()
