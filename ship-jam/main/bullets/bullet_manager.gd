extends Node

@export var bullet : PackedScene
@export var world : Node2D

const bullet_types = preload("res://main/bullets/bullet_types.gd")

func spawn_bullet(bullet_type, position, speed, rotation):
	var node = bullet.instantiate()
	node.bullet_type = bullet_type
	node.position = position
	node.speed = speed
	node.rotation = rotation
	world.add_child(node)
	return node
