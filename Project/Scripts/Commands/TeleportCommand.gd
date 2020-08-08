extends Node2D

signal execution_completed(command)
signal reverse_completed(command)

var _unit
var _sprite
var _starting_tile
var _target_tile

var cost = 1

func init(unit, target_tile):
	_unit = unit
	_sprite = _unit.get_node("Sprite")
	_starting_tile = _unit.current_tile
	_target_tile = target_tile

func can_execute():
	return true

func execute():
	_unit.set_current_tile(_target_tile)
	$AudioStreamPlayer.play()
	_sprite.play("teleport-out")
	yield(_sprite, "animation_finished")
	_unit.global_position = _target_tile.global_position
	_sprite.play("teleport-in")
	yield(_sprite, "animation_finished")

	emit_signal("execution_completed", self)

func can_reverse():
	return true

func reverse():
	_unit.set_current_tile(_starting_tile)
	_sprite.play("teleport-out")
	yield(_sprite, "animation_finished")
	_unit.global_position = _starting_tile.global_position
	_sprite.play("teleport-in")
	yield(_sprite, "animation_finished")
	
	emit_signal("reverse_completed", self)
