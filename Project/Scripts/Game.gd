extends Node2D

func _ready():
	$Allies.init($Map)
	$Baddies.init($Map)
	$Pathfinder.init($Map)
