extends Node2D

var indicator_scene = preload("res://Scenes/Indicator.tscn")
var _indicator

var _indicator_script = preload("res://Scripts/Tiles/Indicator.gd")

enum PathingData { NONE, REACHABLE, PATH }
var pathingData = PathingData.NONE

var map_position = Vector2()

var permanent_blocked = false
var unit = null
var hazards = []

var enemy_target = false

func init(cell_position, world_position, blocked):
	map_position = cell_position
	position = world_position
	
	permanent_blocked = blocked
	
	_indicator = indicator_scene.instance()
	add_child(_indicator)
	_indicator.global_position = world_position
	
	_set_indicator_state()

func filter_pathing():
	if permanent_blocked:
		return false
	if unit:
		return false
	if hazards.size() > 0:
		for hazard in hazards:
			if not hazard.allow_pathing():
				return false
		return true
	return true

func is_placeable():
	return (not permanent_blocked and
			not unit and
			not hazards.size() == 0)

func add_unit(new_unit):
	for i in range(hazards.size()-1, -1, -1):
		hazards[i].collide(new_unit)
	unit = new_unit
	_set_indicator_state()

func remove_unit():
	unit = null
	_set_indicator_state()

func add_hazard(new_hazard):
	if unit:
		new_hazard.collide(unit)
	hazards.push_back(new_hazard)
	_set_indicator_state()

func remove_hazard(hazard):
	hazards.erase(hazard)
	_set_indicator_state()

func has_hazard_type(type):
	for hazard in hazards:
		if hazard is type:
			return true
	return false

func get_pathing_data():
	return _indicator.pathing_data

func set_pathing_data(pathing_data):
	if (pathing_data == _indicator_script.PathingData.NONE):
		$PathData.clear()
	_indicator.set_pathing_data(pathing_data)

func set_show_open_areas(show):
	_indicator.set_show_open(show)

func _set_indicator_state():
	if permanent_blocked:
		_indicator.set_state(_indicator_script.State.NONE)
	elif unit:
		if unit.dead:
			_indicator.set_state(_indicator_script.NONE)
			return
		if unit.faction == 0:
			_indicator.set_state(_indicator_script.State.ALLY)
		else:
			_indicator.set_state(_indicator_script.State.BADDY)
	elif hazards.size() > 0:
		_indicator.set_state(_indicator_script.State.HAZARD)
	else:
		_indicator.set_state(_indicator_script.State.OPEN)
