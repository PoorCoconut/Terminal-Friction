extends Node

func _ready() -> void:
	print("GAME MANAGER LOADED!")

##Camera Helper Functions
func do_camera_shake(intensity:float):
	if get_tree().get_first_node_in_group("camera"):
		var camera = get_tree().get_first_node_in_group("camera")
		camera.startCameraShake(intensity)

func move_camera_to_player(player_pos : Vector2):
	if get_tree().get_first_node_in_group("camera"):
		var camera = get_tree().get_first_node_in_group("camera")
		camera.moveCameraToEntity(player_pos)
