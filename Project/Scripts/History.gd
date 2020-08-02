extends Node2D


func push_action(action_node):
	add_child(action_node)
	move_child(action_node, 0)

func can_pop():
	return get_child_count() > 0

func pop_action():
	var node = get_child(0)
	remove_child(node)
	return node
