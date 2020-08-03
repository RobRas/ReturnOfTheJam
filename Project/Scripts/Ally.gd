extends Node2D

signal movement_began(path)
signal tile_reached(tile)
signal destination_reached(tile)

var current_tile
var selectable = true

const _tile_script = preload("res://Scripts/Tile.gd")


func _ready():
	$Movement.connect("movement_began", self, "_on_Movement_movement_began")
	$Movement.connect("tile_reached", self, "_on_Movement_tile_reached")
	$Movement.connect("destination_reached", self, "_on_Movement_destination_reached")

func init(tile):
	set_current_tile(tile)
	global_position = tile.global_position
	$Movement.init($History)

func _process(_delta):
	"""
	if enabled and Input.is_action_just_pressed("reverse"):
		if $History.can_reverse():
			$History.reverse()
	"""
	pass

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
	set_current_tile(tile)
	emit_signal("destination_reached", tile)

func _on_Movement_movement_began(path):
	emit_signal("movement_began", path)

func _on_Movement_tile_reached(tile):
	emit_signal("tile_reached", tile)
