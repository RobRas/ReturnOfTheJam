extends Node2D

signal animation_finished

func play(rot):
	rotation_degrees = rot
	visible = true
	$Flame.play("default")
	yield($Flame, "animation_finished")
	emit_signal("animation_finished")
	visible = false

func reverse(rot):
	rotation_degrees = rot
	visible = true
	$Flame.play("reverse")
	yield($Flame, "animation_finished")
	emit_signal("animation_finished")
	visible = false
