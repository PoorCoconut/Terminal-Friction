extends Trail

func _get_position():
	return get_tree().get_first_node_in_group("player").position
