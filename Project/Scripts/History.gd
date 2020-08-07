extends Node2D

signal execution_completed(command)
signal reverse_completed(command)

func execute_command(command_node):
	add_child(command_node)
	move_child(command_node, 0)
	command_node.execute()
	yield(command_node, "execution_completed")
	emit_signal("execution_completed", command_node)

func can_reverse(remaining_rewinds):
	return has_reversable_command() and peek_command().can_reverse() and remaining_rewinds >= get_reverse_cost()

func get_reverse_cost():
	for command in get_children():
		if command.cost == 0:
			continue
		return command.cost

func reverse_command():
	# Written so poorly because of the way godot handles children
	var reverse_count = 0
	for i in range(get_child_count()):
		print(i)
		var child = get_child(i)
		if child.cost != 0:
			print("Breaks")
			reverse_count = i
			break
		child.reverse()
	
	while reverse_count > 0:
		pop_command()
		reverse_count -= 1
	
	var final_command = peek_command()
	final_command.reverse()
	yield(final_command, "reverse_completed")
	pop_command()
	emit_signal("reverse_completed", final_command)

func has_reversable_command():
	return get_child_count() > 0

func peek_command():
	return get_child(0)

func pop_command():
	var node = get_child(0)
	print("Popped: " + node.name)
	remove_child(node)
	return node
