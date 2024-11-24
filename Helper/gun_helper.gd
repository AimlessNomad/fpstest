extends Node
class_name gun_helper
const Enemy = preload("res://enemy.gd")

static func create_ray(origin, destination, camera3d, length, player):
	var from = camera3d.project_ray_origin(origin)
	var to = from + camera3d.project_ray_normal(destination) * length
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = player
	return query
