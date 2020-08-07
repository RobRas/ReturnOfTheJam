extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


func _on_RewindState_entered():
	visible = true


func _on_RewindState_exited():
	visible = false


func _on_RewindState_current_changed(new_value):
	$Label.text = str(new_value)
	
