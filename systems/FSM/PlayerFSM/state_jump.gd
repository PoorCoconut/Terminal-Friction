extends "res://systems/FSM/State.gd"
class_name StateJump

@export var PLAYER : Player

func enterState():
	var jump_velocity = lerp(PLAYER.JUMP_MIN_VELOCITY, PLAYER.JUMP_MAX_VELOCITY, PLAYER.jump_charge_strength)
	PLAYER.velocity.y = jump_velocity

func updateState(_delta : float):
	#Ceiling Bump
	if PLAYER.is_on_ceiling():
		PLAYER.velocity.y = 1
	PLAYER.move_and_slide()
	
	#Fall
	if PLAYER.velocity.y > 0 and not PLAYER.is_on_floor():
		transition.emit(self, "Fall")
	
	#FALLBACK TO IDLE WHEN THIS BUG HAPPENS
	if PLAYER.is_on_floor():
		transition.emit(self, "Idle")
