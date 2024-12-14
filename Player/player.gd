extends CharacterBody3D
const Enemy = preload("res://enemy.gd")
const Constants = preload('res://Helper/player_constants.gd')

signal newPos
signal hit

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var buildup = Constants.SPEED

var random = RandomNumberGenerator.new()

# Gun-related global variables
@export var bullet_scene: PackedScene
var weapon_selected = 0
var weapons = [Callable(self, "shotgun"), Callable(self, "shotgun"), Callable(self, "shotgun")]
@onready var camera3d = $Head/Camera3D
@onready var screen_size = get_node("..").get_tree().root.get_visible_rect().size
@onready var origin = screen_size / 2

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
		weapons[weapon_selected].call()
	
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

#Handles shooting behavior shared between weapons
func generic_gun(query):
	var space_state = get_world_3d().direct_space_state
	
	var result = space_state.intersect_ray(query)
	if(result):
		if(result.collider is Enemy):
			hit.emit(result, Constants.SHOTGUN_DAMAGE)
		else:
			var bulletInst = bullet_scene.instantiate() as Node3D
			bulletInst.set_as_top_level(true)
			get_parent().add_child(bulletInst)
			bulletInst.global_transform.origin = result.position
			if(result.normal != Vector3.BACK && result.normal != Vector3.FORWARD): 
				bulletInst.look_at((result.position + result.normal),Vector3.BACK)
	else:
		print("Missed")


# Unique shotgun behavior: fires 8 bullets in a spread within the shotgun crosshair
func shotgun():
	var destination = Vector2()
	var query
	
	for i in range(0, 8):
		destination.x = origin.x + random.randi_range(-screen_size.x / 64, screen_size.x / 64)
		destination.y = origin.y + random.randi_range(-screen_size.y / 36, screen_size.y / 36)
		
		query = gun_helper.create_ray(origin, destination, camera3d, 30, [self])
		generic_gun(query)
