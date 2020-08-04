extends Node2D

export(NodePath) var map_path
var _map

var _enabled = false

var _selection_color = Color(1.0, 1.0, 1.0, 1.0)
var _selection_color_faded = Color(1.0, 1.0, 1.0, 0.0)


func _ready():
	_map = get_node(map_path)
	set_enabled(true)

func _process(delta):
	if _enabled:
		if _map.is_valid_world_position(global_position):
			var tile = _map.get_tile_from_world(get_global_mouse_position())
			global_position = tile.global_position
		else:
			global_position = get_global_mouse_position()

func set_enabled(enabled):
	if enabled == _enabled:
		return
	
	_enabled = enabled
	while _enabled:
		$FlashTween.interpolate_property($Sprite, "modulate", _selection_color_faded, _selection_color, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$FlashTween.start()
		yield($FlashTween, "tween_all_completed")
		$FlashTween.interpolate_property($Sprite, "modulate", _selection_color, _selection_color_faded, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$FlashTween.start()
		yield($FlashTween, "tween_all_completed")
