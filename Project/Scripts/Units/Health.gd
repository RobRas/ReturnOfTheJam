extends Node2D

signal health_lost(amount, current)
signal health_gained(amount, current)
signal died
signal revived

export(int) var max_health = 5
var current_health setget _set_current_health, _get_current_health
var _dead = false

func _ready():
	$Bar.max_value = max_health
	$Bar.value = max_health
	current_health = max_health

func _set_current_health(new_value):
	var diff = new_value - current_health
	var old_health = current_health
	
	current_health = min(new_value, max_health)
	$Bar.value = max(current_health, 0)
	if diff > 0:
		emit_signal("health_gained", current_health - old_health, current_health)
		if _dead and current_health > 0:
			_dead = false
			emit_signal("revived")
	else:
		emit_signal("health_lost", current_health - old_health, current_health)
		if not _dead and current_health <= 0:
			_dead = true
			emit_signal("died")

func _get_current_health():
	return current_health
