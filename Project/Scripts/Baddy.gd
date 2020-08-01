extends Node2D

signal movement_began(tile)
signal tile_reached(tile)
signal destination_reached(tile)

var _tile_script = preload("res://Scripts/Tile.gd")

var path
var next_tile

var current_tile

func move_along_path(path):
	self.path = path
	if path.size() > 0:
		emit_signal("movement_began", current_tile)
	_run_next_tile()

func set_current_tile(new_tile):
	if (current_tile):
		current_tile.set_state(_tile_script.State.OPEN)
	current_tile = new_tile
	current_tile.set_state(_tile_script.State.UNIT_ENEMY)

func _run_next_tile():
	if path.size() > 0:
		next_tile = path.pop_front()
		var distance = global_position.distance_to(next_tile.global_position)
		$Tween.interpolate_property(self, "global_position", global_position, next_tile.global_position, distance / 64 * 0.2, Tween.TRANS_LINEAR)
		$Tween.start()
	else:
		set_current_tile(next_tile)
		emit_signal("destination_reached", next_tile)

func _on_Tween_tween_all_completed():
	emit_signal("tile_reached", next_tile)
	_run_next_tile()
