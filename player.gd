extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_vector = Vector2(0,0)
var last_x_input = [0]

#GRAVITY AND HORIZONTAL MOVEMENT
const MAX_FALL_SPEED = 350.0
const MAX_WALK_SPEED = 300.0
#const acc = 50.0
#JUMP MECHANIC
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@export var dash_boost : Vector2

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var direction = 0

#dash variables
var is_dashing = false
var can_dash = true
var jump_timer = 0.0

func _process(delta):
	facing_vector = Input.get_vector("move_left","move_right","look_up","look_down")
	
	if Input.is_action_just_pressed("move_left"):
		if -1.0 not in last_x_input:
			last_x_input.append(-1.0)
	if Input.is_action_just_pressed("move_right"):
		if 1.0 not in last_x_input:
			last_x_input.append(1.0)
	
	if Input.is_action_just_released("move_left"):
		last_x_input.erase(-1.0)
	if Input.is_action_just_released("move_right"):
		last_x_input.erase(1.0)
	
func _physics_process(delta):
	print(position)
	#apply gravity 
	if velocity.y < MAX_FALL_SPEED:
		velocity.y += get_gravity() * delta
	
	#restart when floor
	if is_on_floor():
		can_dash = true
	
	#walk
	if not is_dashing:
		_walk(delta)
	else:
		#dashing movement
		velocity = dash_boost * facing_vector.sign() 
	
	#jump
	if Input.is_action_just_pressed("jump"):
		jump_timer = 0.1
	jump_timer -= delta
	if jump_timer > 0 and is_on_floor():
		_jump(delta)
		jump_timer = 0.0
		
	if Input.is_action_just_released("jump"):
		if velocity.y < MAX_FALL_SPEED:
			velocity.y = lerp(velocity.y,fall_gravity,0.05)
	
	#dash
	if Input.is_action_just_pressed("dash"):
		_dash(delta)
	move_and_slide()

func _walk(delta):
	var acc
	if is_on_floor(): #acceleration change ensure speed apex
		acc = 50
	else:
		acc = 100
	if last_x_input.back() == 1:
		velocity.x = min(velocity.x + acc,MAX_WALK_SPEED)	
	if last_x_input.back() == -1:
		velocity.x = max(velocity.x - acc,-MAX_WALK_SPEED)
	if last_x_input.back() == 0:
		velocity.x = lerp(velocity.x,0.0,0.4)	
	
func _jump(delta):
	velocity.y = jump_velocity
	
func _dash(delta):	
	if can_dash and not is_dashing:
		is_dashing = true
		can_dash = false
		$dash_time.start()
	
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func _on_dash_time_timeout():
	is_dashing = false


func _on_area_2d_body_entered(body):
	position = Vector2(0,0)


func _on_coyote_time_timeout():
	pass

