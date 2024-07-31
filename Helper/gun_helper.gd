extends Node
class_name gun_helper

static func create_ray(origin, destination, camera3d, length):
	var from = camera3d.project_ray_origin(origin)
	var to = from + camera3d.project_ray_normal(destination) * length
	var query = PhysicsRayQueryParameters3D.create(from, to)
	return query
