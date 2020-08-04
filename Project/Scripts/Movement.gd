extends Node2D

signal movement_began
signal tile_reached(tile)
signal destination_reached(tile)

signal movement_tween_completed

const _TILE_SIZE = 16

export(float) var tiles_per_second = 0.2

var _movement_command = preload("res://Scenes/MovementCommand.tscn")

var _history
var _moving = false

func init(history):
	_history = history

func can_move():
	return not _moving

func move_along_path(path):
	if path.size() == 0:
		return
	_moving = true
	emit_signal("movement_began")
	_execute_next_path_tile(path.duplicate())

func _execute_next_path_tile(path):
	if path.size() == 0:
		return
	if path.size() == 1:
		_moving = false
		emit_signal("destination_reached", path[0])
		return
	
	var command = _movement_command.instance()
	command.init(self, path.pop_front(), path[0])
	command.connect("new_tile_reached", self, "_on_command_new_tile_reached")
	command.connect("reverse_completed", self, "_on_command_reverse_completed")
	_history.execute_command(command)
	
	var tile = yield(command, "new_tile_reached")
	_execute_next_path_tile(path)

func move_to_tile(tile):
	var distance = global_position.distance_to(tile.global_position)
	$Tween.interpolate_property(get_parent(), "global_position", global_position, tile.global_position, distance / _TILE_SIZE * tiles_per_second, Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("movement_tween_completed")

func _on_command_new_tile_reached(tile):
	emit_signal("tile_reached", tile)

func _on_command_reverse_completed(command):
	command.disconnect("new_tile_reached", self, "_on_command_new_tile_reached")
	command.disconnect("reverse_completed", self, "_on_command_reverse_completed")
