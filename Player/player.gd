extends CharacterBody3D
const Enemy = preload("res://enemy.gd")
const Constants = preload('res://Helper/player_constants.gd')

signal newPos
signal hit

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var buildup = Constants.SPEED

# Gun-related global variables
@export var bullet_scene: PackedScene
var weapon_selected = 0
var weapons = [Callable(gun_helper, "shotgun"), Callable(gun_helper, "shotgun"), Callable(gun_helper, "shotgun")]
var random: RandomNumberGenerator = RandomNumberGenerator.new()

# Used to aim and fire weapons
@onready var camera3d = $Head/Camera3D
@onready var screen_size = get_node("..").get_tree().root.get_visible_rect().size
@onready var origin = screen_size / 2
@onready var space_state = get_world_3d().direct_space_state
@onready var firingInfo = [hit, bullet_scene, get_node(".."), self.get_rid()]

# Mouse-related global variables
var mouse_sensitivity = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	random.randomize()

func _input(event):
	# Handles camera movement
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouse_sensitivity
		$Head/Camera3D.rotation.x -= event.relative.y / mouse_sensitivity
		$Head/Camera3D.rotation.x = clamp($Head/Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
	
	# Handles weapon selection
	if event.is_action_pressed("weapon_select"):
		weapon_selected = event.keycode - 49


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = Constants.JUMP_VELOCITY
	
	if Input.is_action_just_pressed("shoot"):
		weapons[weapon_selected].call(origin, random, space_state, camera3d, firingInfo)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Fanciful movement nonsense
	if Input.is_action_pressed("sprint"):
		buildup = move_toward(buildup, Constants.SPRINT_SPEED, 0.05)
		velocity.x += buildup * direction.x 
		velocity.z += buildup * direction.z
	else:
		buildup = Constants.SPEED
		velocity.x += Constants.SPEED * direction.x
		velocity.z += Constants.SPEED * direction.z

	velocity.x *= pow(1.0 - Constants.DAMPING, delta * 10)
	velocity.z *= pow(1.0 - Constants.DAMPING, delta * 10)

	move_and_slide()
	newPos.emit(position.x, position.z)

