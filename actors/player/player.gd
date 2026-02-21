extends CharacterBody2D
class_name Player

@export_category("PLAYER MOVEMENT")
@export var SPEED : float = 100.0
@export var ACCELERATION : float = 100.0
@export var FRICTION : float = 50.0
#@export var JUMP_VELOCITY : float = -100.0
@export var GRAVITY : float = 500.0

# JUMP VARIABLES
@export_category("JUMP")
@export var JUMP_MIN_VELOCITY : float = -50.0
@export var JUMP_MAX_VELOCITY : float = -300.0
@export var MAX_CHARGE_TIME : float = 1.0
var jump_charge_strength : float = 0.0

@export_category("WALL BOUNCE")
@export var WALL_JUMP_VELX : float = 70
@export var WALL_JUMP_VELY : float = -80
@export var BOUNCE_FORCE_X : float = 50.0 # How far they bounce back
@export var BOUNCE_FORCE_Y : float = -10.0 

#FALL
@export_category("FALL SETTINGS")
@export var STUN_FALL_SPEED : float = 200

#BREAK VARIABLES
@export_category("BREAK AND OVERHEAT")
@export var MAX_BRAKE_GAUGE : float = 100.0
@export var GAUGE_COOLDOWN_RATE : float = 25.0 # How much gauge recovers per second
@export var OVERHEAT_PUNISH_TIME : float = 3.0 # Seconds friction is set to 0

var current_brake_gauge : float = 0.0
var is_overheated : bool = false
var overheat_timer : float = 0.5

var direction : float = 1.0

#Helper Variables
var CURRENT_STATE
var previous_velocity : Vector2 = Vector2.ZERO

#PARTICLES [GLOBAL]
@onready var STEAM_PARTICLE := %Particle_Steam

#SFX
@onready var SFX_JUMP: AudioStreamPlayer = %sfx_jump
@onready var SFX_LAND: AudioStreamPlayer = %sfx_hardLand
@onready var SFX_CHARGE: AudioStreamPlayer = %sfx_charge
@onready var SFX_STEAM_SHORT: AudioStreamPlayer = %sfx_steamShort
@onready var SFX_STEAM_LONG: AudioStreamPlayer = %sfx_steamLong
@onready var SFX_WALL_BUMP: AudioStreamPlayer = %sfx_wallBump

func _physics_process(delta: float) -> void:
	# print("PLAYER VELOCITY X: ", velocity.x, ", Y: ", velocity.y)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	move_and_slide()
	
	previous_velocity = velocity
	#Overheat timer
	if is_overheated:
		overheat_timer -= delta
		if overheat_timer <= 0.0:
			is_overheated = false
			current_brake_gauge = 0.0 # Reset gauge when overheat ends
			print("Brakes recovered!")
	#Cooldown (Only if not braking or overheated)
	elif current_brake_gauge > 0 and not Input.is_action_pressed("break"):
		STEAM_PARTICLE.amount = 2
		STEAM_PARTICLE.emitting = true
		
		
		current_brake_gauge -= GAUGE_COOLDOWN_RATE * delta
		
		
		if current_brake_gauge <= 1:
			current_brake_gauge = 0
			STEAM_PARTICLE.emitting = false
		
		current_brake_gauge = max(current_brake_gauge, 0.0) # Don't let it go below 0
	Events.brake_gauge_updated.emit(current_brake_gauge, MAX_BRAKE_GAUGE)
