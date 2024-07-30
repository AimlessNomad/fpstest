extends CharacterBody3D


const JUMP_VELOCITY = 4.5
const SPEED = 1.2
const SPRINT_SPEED = 2
const DAMPING = 0.7

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var buildup = SPEED

var mouse_sensitivity = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouse_sensitivity
		$Head/Camera3D.rotation.x -= event.relative.y / mouse_sensitivity
		$Head/Camera3D.rotation.x = clamp($Head/Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed("sprint"):
		buildup = move_toward(buildup, SPRINT_SPEED, 0.05)
		velocity.x += buildup * direction.x
		velocity.z += buildup * direction.z
	else:
		buildup = SPEED
		velocity.x += SPEED * direction.x
		velocity.z += SPEED * direction.z

	velocity.x *= pow(1.0 - DAMPING, delta * 10)
	velocity.z *= pow(1.0 - DAMPING, delta * 10)
	
	
	move_and_slide()
