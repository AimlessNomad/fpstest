extends CharacterBody3D


const JUMP_VELOCITY = 4.5
const SPEED_SCALE = 6.0 # Higher is faster
const SWAP_SCALE = 6.0 # See below, lower makes the player jerk the other direction faster
const DECEL_SCALE = 5.0 # Lower means player overmoves by less
const TIMESCALE = 0.3 # How long it should take for the player to go from 0 to max velocity
const DECEL_TIMESCALE = 0.35 # How long it should take for the player to go to a standstill


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var progress = Vector3()
var old_x_val = 0.0
var old_z_val = 0.0

var mouse_sensitivity = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
var lastDir = Vector3()

func easingMod(x: float):
	return [abs(x), x / abs(x)]

func easeInSine(x: float):
	var em = easingMod(x)
	return em[1] * (1 - cos((em[0] * PI) / 2))
	
func easeOutQuad(x: float):
	var em = easingMod(x)
	return em[1] * (1 - (1 - em[0]) * (1 - em[0]))

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
	
	if direction:
		print("Direction: " + str(direction)) # When moving with one movement key, direction = one of the bases
		print("Z Basis: " + str(transform.basis.z))
		print("X Basis: " + str(transform.basis.x))
		if snapped(abs(direction.x), 0.0001) != snapped(abs(transform.basis.x.x), 0.0001):
			progress.x = move_toward(progress.x, 1 * (direction.x / abs(direction.x)), delta / TIMESCALE)
			velocity.x = easeOutQuad(progress.x) * abs(direction.x)
			
			if abs(velocity.x * SPEED_SCALE) < abs(old_x_val):
				velocity.x *= SWAP_SCALE
			else:
				velocity.x *= SPEED_SCALE
			
		else:
			print("alternate x")
			progress.x = move_toward(progress.x, 0, delta / DECEL_TIMESCALE)
			if progress.x != 0:
				velocity.x = easeOutQuad(progress.x) * DECEL_SCALE * lastDir.x
			else:
				velocity.x = transform.basis.x.x * SPEED_SCALE * (direction.x / abs(direction.x))
			
		if snapped(abs(direction.z), 0.0001) != snapped(abs(transform.basis.z.z), 0.0001):
			progress.z = move_toward(progress.z, 1 * (direction.z / abs(direction.z)), delta / TIMESCALE)
			velocity.z = easeOutQuad(progress.z) * abs(direction.z)
			
			if abs(velocity.z * SPEED_SCALE) < abs(old_z_val):
				velocity.z *= SWAP_SCALE
			else:
				velocity.z *= SPEED_SCALE
			
		else:
			print("alternate z")
			progress.z = move_toward(progress.z, 0, delta / DECEL_TIMESCALE)
			if progress.z != 0:
				velocity.z = easeOutQuad(progress.z) * DECEL_SCALE * lastDir.z
			else:
				velocity.z = transform.basis.z.z * SPEED_SCALE * -(direction.z / abs(direction.z))
		
		lastDir = direction
		
	else:
		progress.x = move_toward(progress.x, 0, delta / DECEL_TIMESCALE)
		progress.z = move_toward(progress.z, 0, delta / DECEL_TIMESCALE)
		velocity.x = easeOutQuad(progress.x) * DECEL_SCALE * abs(lastDir.x)
		velocity.z = easeOutQuad(progress.z) * DECEL_SCALE * abs(lastDir.z)
		
	if is_nan(velocity.x): velocity.x = 0
	if is_nan(velocity.z): velocity.z = 0
	old_x_val = velocity.x
	old_z_val = velocity.z
	#print("velocity z: " + str(velocity.z))
	#print("velocity x: " + str(velocity.x))
	move_and_slide()
