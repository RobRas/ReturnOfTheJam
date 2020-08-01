extends Node

const _INT_MAX = 9223372036854775807

var previous_tile
var distance

func _ready():
	clear()

func clear():
	previous_tile = null
	distance = _INT_MAX
