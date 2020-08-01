extends Node2D

const _PASSIVE_ALPHA = 0.7
const _ACTIVE_ALPHA = 1.0

enum State { DISABLED, OPEN, ALLY, ENEMY, REACHABLE, PATH }
var state

func set_state(new_state):
	state = new_state
	
	match(state):
		State.DISABLED:
			var color = Color.black
			color.a = 0
			$Sprite.modulate = color
		State.OPEN:
			var color = Color.white
			color.a = _PASSIVE_ALPHA
			$Sprite.modulate = color
		State.ALLY:
			var color = Color.green
			color.a = _ACTIVE_ALPHA
			$Sprite.modulate = color
		State.ENEMY:
			var color = Color.red
			color.a = _ACTIVE_ALPHA
			$Sprite.modulate = color
		State.REACHABLE:
			var color = Color.blue
			color.a = _ACTIVE_ALPHA
			$Sprite.modulate = color
		State.PATH:
			var color = Color.yellow
			color.a = _ACTIVE_ALPHA
			$Sprite.modulate = color
