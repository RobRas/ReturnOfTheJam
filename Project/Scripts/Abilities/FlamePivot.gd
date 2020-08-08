extends Node2D

signal animation_finished

func play(rot):
	rotation_degrees = rot
	visible = true
	$Flame.animation = "default"
	$Flame.frame = 0
	$Flame.play()
	yield($Flame, "animation_finished")
	emit_signal("animation_finished")
	visible = false

func reverse(rot):
	rotation_degrees = rot
	visible = true
	$Flame.animation = "reverse"
	$Flame.frame = 0
	$Flame.play()
	yield($Flame, "animation_finished")
	emit_signal("animation_finished")
	visible = false
