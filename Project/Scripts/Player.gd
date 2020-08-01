extends Node2D

signal destination_reached(tile)

var path
var next_tile

func move_along_path(path):
	self.path = path
	_run_next_tile()

func _run_next_tile():
	if path.size() > 0:
		next_tile = path.pop_front()
		var distance = global_position.distance_to(next_tile.global_position)
		$Tween.interpolate_property(self, "global_position", global_position, next_tile.global_position, distance / 64 * 0.2, Tween.TRANS_LINEAR)
		$Tween.start()
	else:
		emit_signal("destination_reached", next_tile)

func _on_Tween_tween_all_completed():
	_run_next_tile()
