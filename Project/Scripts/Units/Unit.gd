extends Node2D

const _modify_health_command = preload("res://Scenes/Commands/ModifyHealthCommand.tscn")

signal movement_began
signal tile_reached(tile)
signal destination_reached(tile)
signal reverse_completed

var current_tile
var selectable = true

var dead = false

var current_health setget _set_current_health, _get_current_health

const _tile_script = preload("res://Scripts/Tiles/Tile.gd")
export(int, "Ally", "Baddy") var faction

func _ready():
	$Movement.connect("movement_began", self, "_on_Movement_movement_began")
	$Movement.connect("tile_reached", self, "_on_Movement_tile_reached")
	$Movement.connect("destination_reached", self, "_on_Movement_destination_reached")
	$Health.connect("died", self, "_on_unit_died")
	$Health.connect("revived", self, "_on_unit_revived")

func init(tile, map):
	set_current_tile(tile)
	global_position = tile.global_position
	$Movement.init($History)
	for ability in $Abilities.get_children():
		ability.init(self, map, $History)

func damage(amount):
	var command = _modify_health_command.instance()
	command.init(self, -amount)
	$History.execute_command(command)

func can_rewind(remaining_rewinds):
	return $History.can_reverse(remaining_rewinds)

func get_rewind_cost():
	return $History.get_reverse_cost()

func reverse():
	$History.reverse_command()
	yield($History, "reverse_completed")
	emit_signal("reverse_completed")
	
func make_selectable():
	selectable = true

func move_along_path(path, reverse_cost = 1):
	$Movement.move_along_path(path, reverse_cost)

func set_current_tile(new_tile):
	if (current_tile):
		current_tile.remove_unit()
	current_tile = new_tile
	current_tile.add_unit(self)

func _set_current_health(value):
	$Health.current_health = value

func _get_current_health():
	return $Health.current_health


func _on_Movement_destination_reached(tile):
	emit_signal("destination_reached", tile)

func _on_Movement_movement_began():
	emit_signal("movement_began")

func _on_Movement_tile_reached(tile):
	set_current_tile(tile)
	emit_signal("tile_reached", tile)

func _on_unit_died():
	dead = true
	rotation_degrees = -90
	$Sprite.stop()
	$Health/Bar.visible = false

func _on_unit_revived():
	dead = false
	rotation_degrees = 0
	$Sprite.play()
	$Health/Bar.visible = true
