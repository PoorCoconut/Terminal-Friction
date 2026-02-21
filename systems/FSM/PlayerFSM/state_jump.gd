extends "res://systems/FSM/State.gd"
class_name StateJump

@export var PLAYER : Player

func enterState():
	PLAYER.SFX_JUMP.pitch_scale = randf_range(0.8, 1.2)
	PLAYER.SFX_JUMP.play()
	var jump_velocity = lerp(PLAYER.JUMP_MIN_VELOCITY, PLAYER.JUMP_MAX_VELOCITY, PLAYER.jump_charge_strength)
	PLAYER.velocity.y = jump_velocity

func updateState(_delta : float):
	PLAYER.previous_velocity = PLAYER.velocity
	
	#Ceiling Bump
	if PLAYER.is_on_ceiling():
		PLAYER.velocity.y = 1
	PLAYER.move_and_slide()
	
	if PLAYER.is_on_wall():
		var wall_normal = PLAYER.get_wall_normal()
		PLAYER.velocity.x = wall_normal.x * PLAYER.WALL_JUMP_VELX
		PLAYER.velocity.y = PLAYER.WALL_JUMP_VELY
		
		PLAYER.SFX_WALL_BUMP.pitch_scale = randf_range(0.8, 1.2)
		PLAYER.SFX_WALL_BUMP.play()
		
		transition.emit(self, "StunFall")
		return
	
	#Fall
	if PLAYER.velocity.y > 0 and not PLAYER.is_on_floor():
		transition.emit(self, "Fall")
	
	#FALLBACK TO IDLE WHEN THIS BUG HAPPENS
	if PLAYER.is_on_floor():
		transition.emit(self, "Idle")
