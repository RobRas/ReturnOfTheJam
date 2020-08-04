extends Node2D

signal movement_began
signal tile_reached(tile)
signal destination_reached(tile)
signal reverse_completed

var current_tile
var selectable = true

const _tile_script = preload("res://Scripts/Tiles/Tile.gd")


func _ready():
	$Movement.connect("movement_began", self, "_on_Movement_movement_began")
	$Movement.connect("tile_reached", self, "_on_Movement_tile_reached")
	$Movement.connect("destination_reached", self, "_on_Movement_destination_reached")

func init(tile):
	set_current_tile(tile)
	global_position = tile.global_position
	$Movement.init($History)

func can_rewind():
	return $History.can_reverse()

func reverse():
	if $History.can_reverse():
		$History.reverse_command()
		yield($History, "reverse_completed")
		emit_signal("reverse_completed")
	
func make_selectable():
	selectable = true
	current_tile.set_state(_tile_script.State.UNIT_ALLY)

func move_along_path(path):
	$Movement.move_along_path(path)

func set_current_tile(new_tile):
	if (current_tile):
		current_tile.unit = null
		current_tile.set_state(_tile_script.State.OPEN)
	current_tile = new_tile
	current_tile.unit = self
	current_tile.set_state(_tile_script.State.UNIT_ALLY)


func _on_Movement_destination_reached(tile):
	emit_signal("destination_reached", tile)

func _on_Movement_movement_began():
	emit_signal("movement_began")

func _on_Movement_tile_reached(tile):
	set_current_tile(tile)
	emit_signal("tile_reached", tile)
