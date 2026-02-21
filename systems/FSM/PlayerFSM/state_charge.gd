extends "res://systems/FSM/State.gd"
class_name StateCharge

@export var PLAYER : Player
var current_charge_timer : float = 0.0

func enterState():
	PLAYER.SFX_CHARGE.pitch_scale = randf_range(0.8, 1.2)
	PLAYER.SFX_CHARGE.play()
	current_charge_timer = 0.0
	PLAYER.jump_charge_strength = 0.0

func updateState(delta : float):
	current_charge_timer += delta
	PLAYER.jump_charge_strength = clamp(current_charge_timer / PLAYER.MAX_CHARGE_TIME, 0.0, 1.0)
	
	if Input.is_action_pressed("charge"):
		var current_speed = abs(PLAYER.velocity.x)
		var is_moving_forward = sign(PLAYER.velocity.x) == sign(PLAYER.direction)
		
		# THE OVERSPEED CHECK (Coasting)
		if is_moving_forward and current_speed > PLAYER.SPEED:
			# If we are going faster than base speed, we slowly bleed speed 
			# back down to PLAYER.SPEED. We use a tiny fraction of acceleration 
			# so they keep their slope momentum for a long time!
			var coast_friction = PLAYER.ACCELERATION * 0.05 
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, PLAYER.direction * PLAYER.SPEED, coast_friction)
			
		else:
			# NORMAL CHARGE
			# Accelerate normally up to the base speed limit
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, PLAYER.direction * PLAYER.SPEED, PLAYER.ACCELERATION)
			
	else:
		# THE MISSING JUMP TRANSITION!
		# If they let go of the button, jump immediately.
		transition.emit(self, "Jump")
		return # Stop running the rest of the code so we don't trigger Idle/Fall!
	PLAYER.move_and_slide()
	
	if PLAYER.velocity.length() <= 0.5 or PLAYER.is_on_wall():
		transition.emit(self, "Idle")
	
	if not PLAYER.is_on_floor():
		transition.emit(self, "Fall")
	
	if Input.is_action_just_pressed("break"):
		transition.emit(self, "Break")

func exitState():
	PLAYER.SFX_CHARGE.stop()
