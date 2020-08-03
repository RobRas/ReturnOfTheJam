extends Node2D

const _PASSIVE_ALPHA = 0.3
const _ACTIVE_ALPHA = 1.0

const _SELECT_GROWTH = Vector2(1.05, 1.05)
const _SELECT_GROWTH_DURATION = 0.5

enum State { DISABLED, OPEN, ALLY, BADDY, REACHABLE, PATH }
var state

var _selected = false
var _color

func select(new_select):
	if new_select == _selected:
		return
	_selected = new_select
	if _selected:
		_run_selected()
	else:
		$HoveredIndicatorTween.stop_all()
		$HoveredIndicatorTween.remove_all()
		$HoveredIndicatorTween.interpolate_property(self, "scale", scale, Vector2(1,1), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		$HoveredIndicatorTween.interpolate_property(self, "modulate", modulate, _color, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		$HoveredIndicatorTween.start()

func set_state(new_state):
	state = new_state
	
	match(state):
		State.DISABLED:
			_color = Color.black
			_color.a = 0
		State.OPEN:
			_color = Color.white
			_color.a = _PASSIVE_ALPHA
		State.ALLY:
			_color = Color.green
			_color.a = _ACTIVE_ALPHA
		State.BADDY:
			_color = Color.red
			_color.a = _ACTIVE_ALPHA
		State.REACHABLE:
			_color = Color.blue
			_color.a = _ACTIVE_ALPHA
		State.PATH:
			_color = Color.yellow
			_color.a = _ACTIVE_ALPHA
	
	if not _selected:
		modulate = _color

func clear_pathing():
	if state == State.REACHABLE or state == State.PATH:
		set_state(State.OPEN)

func _run_selected():
	while _selected:
		$HoveredIndicatorTween.interpolate_property(self, "scale", Vector2(1,1), _SELECT_GROWTH, _SELECT_GROWTH_DURATION / 3.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$HoveredIndicatorTween.interpolate_property(self, "modulate", _color, Color.white, _SELECT_GROWTH_DURATION / 3.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$HoveredIndicatorTween.start()
		yield($HoveredIndicatorTween, "tween_all_completed")
		if _selected:
			$HoveredIndicatorTween.interpolate_property(self, "scale", _SELECT_GROWTH, Vector2(1,1), _SELECT_GROWTH_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
			$HoveredIndicatorTween.interpolate_property(self, "modulate", Color.white, _color, _SELECT_GROWTH_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
			$HoveredIndicatorTween.start()
			yield($HoveredIndicatorTween, "tween_all_completed")
	$HoveredIndicatorTween.interpolate_property(self, "scale", scale, Vector2(1,1), 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$HoveredIndicatorTween.interpolate_property(self, "modulate", modulate, _color, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$HoveredIndicatorTween.start()
