extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_vector = Vector2(0,0)

const MAX_FALL_SPEED = 200
const MAX_WALK_SPEED = 300
const acc = 50.0


func _ready():
	print(gravity)

func _physics_process(delta):
	facing_vector = Input.get_vector("move_left","move_right","look_up","look_down")
	
	#apply gravity 
	if velocity.y <= MAX_FALL_SPEED:
		velocity.y += gravity * delta
	
	#walking acceleration
	if facing_vector[0] == 1:
		velocity.x = min(velocity.x + acc,MAX_WALK_SPEED)
	if facing_vector[0] == -1:
		velocity.x = max(velocity.x - acc,-MAX_WALK_SPEED)
	if facing_vector[0] == 0:
		velocity.x = lerp(velocity.x,0.0,0.4)	
	
	#jump

	move_and_slide()

func _walk(delta):
	pass
	
func _jump(delta):
	pass
	
func _dash(delta):
	pass
