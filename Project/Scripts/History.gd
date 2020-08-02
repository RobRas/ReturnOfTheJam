extends Node2D

signal reversal_completed

var _reversing = false
var _current_action

func add_action(action_node):
	add_child(action_node)
	move_child(action_node, 0)

func can_reverse():
	return not _reversing and has_reversable_action() and peek_action().can_reverse()

func reverse():
	_current_action = pop_action()
	_reversing = true
	_current_action.connect("reversal_completed", self, "_on_action_reversal_completed")
	_current_action.reverse()

func has_reversable_action():
	return get_child_count() > 0

func peek_action():
	return get_child(0)

func pop_action():
	var node = get_child(0)
	remove_child(node)
	return node

func _on_action_reversal_completed():
	_current_action.disconnect("reversal_completed", self, "_on_action_reversal_completed")
	_reversing = false
	emit_signal("reversal_completed")
