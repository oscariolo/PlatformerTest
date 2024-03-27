extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_vector = Vector2(0,0)

#GRAVITY AND HORIZONTAL MOVEMENT
const MAX_FALL_SPEED = 200
const MAX_WALK_SPEED = 300
const acc = 50.0
#JUMP MECHANIC
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0


func _physics_process(delta):
	facing_vector = Input.get_vector("move_left","move_right","look_up","look_down")
	
	#apply gravity 
	#if velocity.y <= MAX_FALL_SPEED: #base 1
		#velocity.y += gravity * delta
	velocity.y += get_gravity() * delta
	
	#walking
	if facing_vector[0] == 1:
		velocity.x = min(velocity.x + acc,MAX_WALK_SPEED)
	if facing_vector[0] == -1:
		velocity.x = max(velocity.x - acc,-MAX_WALK_SPEED)
	if facing_vector[0] == 0:
		velocity.x = lerp(velocity.x,0.0,0.4)	
	#jump
	if Input.is_action_just_pressed("jump"):
		_jump(delta)

	move_and_slide()

func _walk(delta):
	pass
	
func _jump(delta):
	velocity.y = jump_velocity
	
func _dash(delta):
	pass

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
