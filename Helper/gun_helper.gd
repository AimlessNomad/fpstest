extends Node
class_name gun_helper
const Enemy = preload("res://enemy.gd")
const PlayerConstants = preload("res://Helper/player_constants.gd")


static func create_ray(origin: Vector2, destination: Vector2, camera3d: Camera3D, length: int, playerRID: RID):
	var from: Vector3 = camera3d.project_ray_origin(origin)
	var to: Vector3 = from + camera3d.project_ray_normal(destination) * length
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [playerRID];
	return query

# handles shooting behavior shared between weapons
static func generic_gun(query: PhysicsRayQueryParameters3D, space_state: PhysicsDirectSpaceState3D, firingInfo: Array, damage: int):
	
	var result = space_state.intersect_ray(query)
	if(result):
		if(result.collider is Enemy):
			firingInfo[0].emit(result, damage)
		else:
			var bulletInst = firingInfo[1].instantiate() as Node3D
			bulletInst.set_as_top_level(true)
			firingInfo[2].add_child(bulletInst)
			bulletInst.global_transform.origin = result.position
			if(result.normal != Vector3.BACK && result.normal != Vector3.FORWARD): 
				bulletInst.look_at((result.position + result.normal),Vector3.BACK)
	else:
		print("Missed")


# fires 8 bullets in a spread within the shotgun crosshair
static func shotgun(origin: Vector2, random: RandomNumberGenerator, space_state: PhysicsDirectSpaceState3D, camera3d: Camera3D, firingInfo: Array):
	var destination = Vector2()
	var query
	
	for i in range(0, 8):
		destination.x = origin.x + random.randi_range(-origin.x / 32, origin.x / 32)
		destination.y = origin.y + random.randi_range(-origin.y / 18, origin.y / 18)
		
		query = gun_helper.create_ray(origin, destination, camera3d, 30, firingInfo[3])
		generic_gun(query, space_state, firingInfo, PlayerConstants.SHOTGUN_DAMAGE)
