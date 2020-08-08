extends Node2D

var cost = 1

signal execution_completed(command)
signal reverse_completed(command)

var _target_tile
var _tiles
var _map
var _caster

var _damage = 2

func init(target_tile, tiles, map, caster):
	_target_tile = target_tile
	_tiles = tiles
	_map = map
	_caster = caster

func can_execute():
	return true

func execute():
	$AudioStreamPlayer.play()
	global_position = _target_tile.global_position
	$AnimatedSprite.visible = true
	$AnimatedSprite.animation = "default"
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play()
	var caster_sprite = _caster.get_node("Sprite")
	caster_sprite.animation = "attack"
	caster_sprite.frame = 0
	caster_sprite.play()
	yield($AnimatedSprite, "animation_finished")
	for tile in _tiles:
		if not tile.unit:
			continue
		tile.unit.damage(_damage)
	$AnimatedSprite.visible = false
	caster_sprite.animation = "idle"
	caster_sprite.play()
	emit_signal("execution_completed", self)


func can_reverse():
	return true

func reverse():
	$ReverseAudio.play()
	global_position = _target_tile.global_position
	$AnimatedSprite.visible = true
	$AnimatedSprite.animation = "reverse"
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play()
	var caster_sprite = _caster.get_node("Sprite")
	caster_sprite.animation = "attack-reverse"
	caster_sprite.frame = 0
	caster_sprite.play()
	yield($AnimatedSprite, "animation_finished")
	""" Need to figure out how to record who got damaged and if they can be healed"""
	$AnimatedSprite.visible = false
	caster_sprite.animation = "idle"
	caster_sprite.play()
	emit_signal("reverse_completed", self)
