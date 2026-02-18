extends CharacterBody2D
class_name Player

@export_category("PLAYER MOVEMENT")
@export var SPEED : float = 100.0
@export var ACCELERATION : float = 100.0
@export var FRICTION : float = 50.0
#@export var JUMP_VELOCITY : float = -100.0
@export var GRAVITY : float = 500.0

# JUMP VARIABLES
@export var JUMP_MIN_VELOCITY : float = -50.0
@export var JUMP_MAX_VELOCITY : float = -300.0
@export var MAX_CHARGE_TIME : float = 1.0
var jump_charge_strength : float = 0.0

var direction : float = 1.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	move_and_slide()

#Calls the GameManager to move the camera
func _on_screen_notifier_screen_exited() -> void:
	GameManager.move_camera_to_player(global_position)
