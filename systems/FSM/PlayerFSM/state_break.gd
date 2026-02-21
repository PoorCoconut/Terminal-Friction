extends "res://systems/FSM/State.gd"
class_name StateBreak

@export var PLAYER : Player
@export var BRAKE_FRICTION : float = 500.0 # Huge friction to stop fast
@export var HEAT_MULTIPLIER : float = 2.5 # How fast speed converts to heat

@onready var FRICTIONSPARK_PARTICLE := %Particle_FrictionSpark

func enterState():
	PLAYER.SFX_CHARGE.pitch_scale = randf_range(0.8, 1.2)
	PLAYER.SFX_CHARGE.play()
	FRICTIONSPARK_PARTICLE.emitting = true

func updateState(delta : float):
	if PLAYER.is_on_floor():
		var floor_normal = PLAYER.get_floor_normal()
		
		# If the floor normal is tilted then the player is on a slope
		if abs(floor_normal.x) > 0.1:
			transition.emit(self, "StunFall")
			return
	
	#OVERHEAT
	if PLAYER.is_overheated:
		
		if !PLAYER.SFX_STEAM_LONG.playing:
			PLAYER.SFX_STEAM_LONG.pitch_scale = randf_range(0.9, 1.2)
			PLAYER.SFX_STEAM_LONG.play()
		
		PLAYER.STEAM_PARTICLE.amount = 30
		PLAYER.STEAM_PARTICLE.emitting = true
		
		
		if PLAYER.velocity.length() <= 10.0:
			
			transition.emit(self, "Idle")
			
	#NORMAL BREAK
	else:
		if Input.is_action_pressed("break"):
			if !PLAYER.SFX_STEAM_SHORT.playing:
				PLAYER.SFX_STEAM_SHORT.pitch_scale = randf_range(0.8, 1.2)
				PLAYER.SFX_STEAM_SHORT.play()
			
			
			var current_speed = abs(PLAYER.velocity.x)
			
			#Fill the gauge based on how fast they are currently sliding
			PLAYER.current_brake_gauge += (current_speed * HEAT_MULTIPLIER) * delta
			
			#Tell the rest of the game the gauge changed!
			Events.brake_gauge_updated.emit(PLAYER.current_brake_gauge, PLAYER.MAX_BRAKE_GAUGE)
			
			#Check for Overheat
			if PLAYER.current_brake_gauge >= PLAYER.MAX_BRAKE_GAUGE:
				PLAYER.is_overheated = true
				PLAYER.overheat_timer = PLAYER.OVERHEAT_PUNISH_TIME
				print("BRAKES OVERHEATED! ZERO FRICTION!")
			
			#Decelerate
			PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, BRAKE_FRICTION * delta)
			PLAYER.move_and_slide()
			
			if abs(PLAYER.velocity.x) <= 0:
				PLAYER.velocity.x = 0
				transition.emit(self, "Idle")
				return
			
		else:
			if abs(PLAYER.velocity.x) > 0:
				transition.emit(self, "Fall")
			else:
				transition.emit(self, "Idle")

func exitState():
	PLAYER.SFX_CHARGE.stop()
	PLAYER.STEAM_PARTICLE.emitting = false
	FRICTIONSPARK_PARTICLE.emitting = false
