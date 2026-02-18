extends "res://systems/FSM/State.gd"
class_name StateCharge

@export var PLAYER : Player
var current_charge_timer : float = 0.0

func enterState():
	current_charge_timer = 0.0
	PLAYER.jump_charge_strength = 0.0

func updateState(delta : float):
	current_charge_timer += delta
	PLAYER.jump_charge_strength = clamp(current_charge_timer / PLAYER.MAX_CHARGE_TIME, 0.0, 1.0)
	
	if Input.is_action_pressed("charge"):
		PLAYER.velocity.x = move_toward(PLAYER.velocity.x, PLAYER.direction * PLAYER.SPEED, PLAYER.ACCELERATION)
	else:
		transition.emit(self, "Jump")
		#PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, PLAYER.FRICTION)
	PLAYER.move_and_slide()
	
	if PLAYER.velocity.length() <= 0.5 or PLAYER.is_on_wall():
		transition.emit(self, "Idle")
	
	if not PLAYER.is_on_floor():
		transition.emit(self, "Fall")
