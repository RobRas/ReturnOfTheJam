extends Node2D

signal movement_began
signal position_reached
signal tile_reached(tile)
signal destination_reached(tile)

const _TILE_SIZE = 16

export(float) var tiles_per_second = 0.2

var _movement_command = preload("res://Scenes/MovementCommand.tscn")

var _path = []

var _moving = false
var _move_to_tile

var _history

func init(history):
	_history = history

func can_move():
	return not _moving

func move_along_path(path):
	_path = path.duplicate()
	if _path.size() == 0: # Outside movement range
		return

	if _path.size() == 1: # Same tile as unit
		emit_signal("movement_began")
		emit_signal("position_reached", _path[0])
		emit_signal("tile_reached", _path[0])
		emit_signal("destination_reached", _path[0])
		return

	_execute_next_path_tile()

func _execute_next_path_tile():
	var command = _movement_command.instance()
	command.init(self, _path.pop_front(), _path[0])
	_history.execute_command(command)

func move_to_tile(command, tile):
	command.connect("execution_completed", self, "_on_command_execution_completed")
	emit_signal("movement_began")
	_move_to_tile = tile
	_moving = true
	var distance = global_position.distance_to(tile.global_position)
	$Tween.interpolate_property(get_parent(), "global_position", global_position, tile.global_position, distance / _TILE_SIZE * tiles_per_second, Tween.TRANS_LINEAR)
	$Tween.start()

func _on_Tween_tween_all_completed():
	emit_signal("position_reached")


func _on_command_execution_completed(command):
	command.disconnect("execution_completed", self, "_on_command_execution_completed")
	_moving = false
	emit_signal("tile_reached", _move_to_tile)
	if _path.size() > 1:
		_execute_next_path_tile()
	else:
		_path.clear()
		emit_signal("destination_reached", _move_to_tile)
