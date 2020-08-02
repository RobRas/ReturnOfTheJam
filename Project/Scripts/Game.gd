extends Node2D

func _ready():
	$Map/Allies.init($Map)
	$Map/Baddies.init($Map)
	$Map/Pathfinder.init($Map)
