extends Node2D


func _on_Health_health_lost(amount, current):
	var sound_count = get_child_count()
	get_child(randi() % sound_count).play()
