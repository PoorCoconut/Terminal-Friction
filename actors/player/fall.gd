extends "res://systems/FSM/State.gd"
class_name StateFall

@export var PLAYER : Player

func enterState():
	pass

func updateState(_delta : float):
	if PLAYER.is_on_floor():
		transition.emit(self, "Idle")
	
	PLAYER.move_and_slide()
