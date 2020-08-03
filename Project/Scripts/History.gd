extends Node2D

signal execution_completed(command)
signal reverse_completed(command)

func execute_command(command_node):
	add_child(command_node)
	move_child(command_node, 0)
	command_node.execute()
	yield(command_node, "execution_completed")
	emit_signal("execution_completed", command_node)

func can_reverse():
	return has_reversable_command() and peek_command().can_reverse()

func reverse_command():
	var command = pop_command()
	command.reverse()
	yield(command, "reverse_completed")
	emit_signal("reverse_completed", command)

func has_reversable_command():
	return get_child_count() > 0

func peek_command():
	return get_child(0)

func pop_command():
	var node = get_child(0)
	remove_child(node)
	return node
