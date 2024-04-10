extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_x_input = [0]
var last_y_input = [0]

#GRAVITY AND HORIZONTAL MOVEMENT
const MAX_FALL_SPEED = 350.0
const MAX_WALK_SPEED = 300.0
#const acc = 50.0
#JUMP MECHANIC
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
var direction = 0
#dash variables
var is_dashing = false
var can_dash = true
var dash_vector = Vector2()
var dash_vector_frame_window : int
@export var dash_height : float
@export var dash_time_to_peak : float
@onready var dash_gravity : float = ((-2.0 * dash_height) / (dash_time_to_peak * dash_time_to_peak)) * -1.0
#@export var dash_boost : Vector2
@onready var dash_speed_on_y: float = ((2.0 * dash_height) / dash_time_to_peak) 
@export var dash_speed_on_x : float 
#jump buffer timer
var jump_timer_buffer = 0.0
#coyote time


func _process(delta):	
	if Input.is_action_just_pressed("move_left"):
		if -1.0 not in last_x_input:
			last_x_input.append(-1.0)
	if Input.is_action_just_pressed("move_right"):
		if 1.0 not in last_x_input:
			last_x_input.append(1.0)
	
	if Input.is_action_just_pressed("look_up"):
		if -1.0 not in last_y_input:
			last_y_input.append(-1.0)
	if Input.is_action_just_pressed("look_down"):
		if 1.0 not in last_y_input:
			last_y_input.append(1.0)
	
	if Input.is_action_just_released("move_left"):
		last_x_input.erase(-1.0)
	if Input.is_action_just_released("move_right"):
		last_x_input.erase(1.0)
	if Input.is_action_just_released("look_up"):
		last_y_input.erase(-1.0)
	if Input.is_action_just_released("look_down"):
		last_y_input.erase(1.0)
	
func _physics_process(delta):
	#print(position)
	#apply gravity 
	if velocity.y < MAX_FALL_SPEED:
		velocity.y += get_gravity() * delta
	
	#restart when floor
	if is_on_floor() and not is_dashing:
		can_dash = true
		
	#walk
	var threshold = 100
	if not is_dashing:
		_walk(delta)
	
	if is_dashing:
		if dash_vector_frame_window > 0:
			dash_vector = Vector2(last_x_input.back(),last_y_input.back())
			dash_vector_frame_window -= 1
		if dash_vector_frame_window == 0:
			velocity.x = dash_speed_on_x * dash_vector[0]
			velocity.y = dash_speed_on_y * dash_vector[1]
			dash_vector_frame_window = -1
	
	#jump
	if Input.is_action_just_pressed("jump"):
		jump_timer_buffer = 0.1
	jump_timer_buffer -= delta
	if jump_timer_buffer > 0:
		if is_on_floor() or $coyote_time.time_left > 0.0:
			_jump(delta)
	if Input.is_action_just_released("jump") and not is_dashing:
		if velocity.y < MAX_FALL_SPEED:
			velocity.y = lerp(velocity.y,fall_gravity,0.05)
	#dash
	if Input.is_action_just_pressed("dash"):
		_dash(delta)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >=0
	if just_left_ledge:
		$coyote_time.start()

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
	jump_timer_buffer = 0.0
	
func _dash(delta):	
	if can_dash and not is_dashing:
		dash_vector_frame_window = 3
		is_dashing = true
		can_dash = false
		$dash_time.start()
	
func get_gravity() -> float:
	if not is_dashing:
		return jump_gravity if velocity.y < 0.0 else fall_gravity
	else:
		if dash_vector.y == 0:
			return 0
		else:
			return dash_gravity
	

func _on_dash_time_timeout():
	is_dashing = false


func _on_area_2d_body_entered(body):
	position = Vector2(0,0)

func _on_coyote_time_timeout():
	pass

