extends "res://systems/FSM/State.gd"
class_name StateIdle

@export var PLAYER : Player

func enterState():
	pass

func updateState(_delta : float):
	PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, PLAYER.FRICTION)
	determine_direction()
	
	if Input.is_action_pressed("charge"):
		transition.emit(self, "Charge")
	
	PLAYER.move_and_slide()

func determine_direction():
	if Input.is_action_pressed("look_left"):
		%Sprite.flip_h = true
		PLAYER.direction = -1
	elif Input.is_action_pressed("look_right"):
		%Sprite.flip_h = false
		PLAYER.direction = 1
