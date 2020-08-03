extends Node2D

signal execution_completed(command)
signal reversal_completed(command)

var _current_command

func execute_command(command_node):
	add_child(command_node)
	move_child(command_node, 0)
	command_node.connect("execution_completed", self, "_on_command_execution_completed")
	command_node.execute()

func can_reverse():
	print(_current_command)
	return has_reversable_command() and peek_command().can_reverse()

func reverse_command():
	var command = pop_command()
	command.connect("execution_completed", self, "_on_command_reversal_completed")
	command.reverse()

func has_reversable_command():
	return get_child_count() > 0

func peek_command():
	return get_child(0)

func pop_command():
	var node = get_child(0)
	remove_child(node)
	return node

func _on_command_execution_completed(command):
	command.disconnect("execution_completed", self, "_on_command_execution_completed")
	emit_signal("execution_completed", command)

func _on_command_reversal_completed(command):
	command.disconnect("execution_completed", self, "_on_command_reversal_completed")
	emit_signal("reversal_completed", command)
