extends "res://systems/FSM/State.gd"
class_name StateStunFall

@export var PLAYER : Player
@export var STUN_FRICTION : float = 3
@export var SLIDE_ACCELERATION : float = 20.0 # How fast they pick up speed sliding down
@export var MAX_SLIDE_SPEED : float = 150.0    # Cap their sliding speed

var PREV_GRAVITY : float

@export var LAND_PARTICLE_PATH : PackedScene
var added_particles_flag : bool = false
var LAND_PARTICLE
@onready var DUST_PARTICLE = %Particle_Dust

func enterState():
	LAND_PARTICLE = LAND_PARTICLE_PATH.instantiate()
	added_particles_flag = false
	PREV_GRAVITY = PLAYER.GRAVITY

func updateState(_delta : float):
	var fall_speed_before_impact = abs(PLAYER.velocity.y)
	
	if PLAYER.is_on_floor():
		DUST_PARTICLE.emitting = true
		
		if !PLAYER.SFX_LAND.playing:
			PLAYER.SFX_LAND.pitch_scale = randf_range(0.8, 1.2)
			PLAYER.SFX_LAND.play()
		
		if not added_particles_flag:
			LAND_PARTICLE.global_position = PLAYER.global_position
			LAND_PARTICLE.global_position.y += 10 
			get_tree().get_first_node_in_group("world").add_child(LAND_PARTICLE)
			added_particles_flag = true
		
		PLAYER.GRAVITY = 200
		var floor_normal = PLAYER.get_floor_normal()
		if abs(floor_normal.x) > 0.1: # Player on slope, accelerate them
			PLAYER.velocity.x += floor_normal.x * SLIDE_ACCELERATION # floor_normal.x acts as direction (-1 to 1)
			PLAYER.velocity.x = clamp(PLAYER.velocity.x, -MAX_SLIDE_SPEED, MAX_SLIDE_SPEED) #To not accelerate infinitely
			
		else: # Player on flat ground, decelerate them
			DUST_PARTICLE.emitting = false
			if Input.is_action_pressed("charge"):
				transition.emit(self, "Charge")
			else: 
				transition.emit(self, "Idle")
				
			#PLAYER.velocity.x = move_toward(PLAYER.velocity.x, 0, STUN_FRICTION)
			#if abs(PLAYER.velocity.x) <= 5.0:
				#PLAYER.velocity.x = 0
				#DUST_PARTICLE.emitting = false
				#transition.emit(self, "Idle")
	else:
		DUST_PARTICLE.emitting = false
	var velocity_before_hit = PLAYER.velocity
	PLAYER.move_and_slide()
	
	if PLAYER.is_on_floor():
		determine_direction()
		
		var impact_force = fall_speed_before_impact
		if impact_force > 0:
			var intensity = impact_force * 0.1
			intensity = clamp(intensity, 0.0, 10.0) 
			GameManager.do_camera_shake(intensity, 0.3)
	
	#Wall Bounce
	if PLAYER.is_on_wall():
		# get_wall_normal() returns a vector pointing AWAY from the wall
		# If the wall is on the right, it points left (-1)
		var wall_normal = PLAYER.get_wall_normal()
		
		# Push them away from the wall
		var crash_speed = abs(velocity_before_hit.x)
		#PLAYER.velocity.x = wall_normal.x * crash_speed * 0.8
		PLAYER.velocity.x = wall_normal.x * PLAYER.BOUNCE_FORCE_X
		
		# Pop them slightly up into the air
		PLAYER.velocity.y = PLAYER.BOUNCE_FORCE_Y
		
		
		PLAYER.SFX_WALL_BUMP.pitch_scale = randf_range(0.8, 1.2)
		PLAYER.SFX_WALL_BUMP.play()

func exitState():
	PLAYER.GRAVITY = PREV_GRAVITY

func determine_direction():
	if Input.is_action_pressed("look_left"):
		%Sprite.flip_h = true
		PLAYER.direction = -1
	elif Input.is_action_pressed("look_right"):
		%Sprite.flip_h = false
		PLAYER.direction = 1
