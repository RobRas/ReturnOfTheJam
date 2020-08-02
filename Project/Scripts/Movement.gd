extends Node2D

signal movement_began(path)
signal tile_reached(tile)
signal destination_reached(tile)

const _TILE_SIZE = 16

export(float) var tiles_per_second = 0.2

var _tile_script = preload("res://Scripts/Tile.gd")
var _movement_action = preload("res://Scenes/MovementAction.tscn")

var _path
var _current_tile
var _next_tile

var _moving = false
var _record = true

var _history

func init(history):
	_history = history

func move_along_path(path, record = true):
	if _moving:
		return
	
	if path.size() <= 1:
		return
	
	_path = path
	_moving = true
	_record = record
	
	emit_signal("movement_began", _path)
	
	_current_tile = _path.pop_front()
	_next_tile = _path.pop_front()
	_add_record([_current_tile, _next_tile])
	_start_movement_tween()

func is_moving():
	return _moving

func _run_next_tile():
	_add_record([_current_tile, _next_tile])
	if _path.size() > 0:
		_current_tile = _next_tile
		_next_tile = _path.pop_front()
		_start_movement_tween()
	else:
		_moving = false
		emit_signal("destination_reached", _next_tile)

func _start_movement_tween():
	var distance = global_position.distance_to(_next_tile.global_position)
	$Tween.interpolate_property(get_parent(), "global_position", global_position, _next_tile.global_position, distance / _TILE_SIZE * tiles_per_second, Tween.TRANS_LINEAR)
	$Tween.start()
	
func _add_record(path):
	if _record:
		var movement_action = _movement_action.instance()
		movement_action.init(path, self)
		_history.add_action(movement_action)

func _on_Tween_tween_all_completed():
	emit_signal("tile_reached", _next_tile)
	_run_next_tile()
