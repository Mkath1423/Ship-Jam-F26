extends Node

@export var bullet : PackedScene
@export var railgun_beam : PackedScene
@export var world : Node2D

const teams = preload("res://main/teams.gd")

func spawn_bullet(bullet_team, position, speed, rotation):
	var node = bullet.instantiate()
	node.team = bullet_team
	node.position = position
	node.speed = speed
	node.rotation = rotation
	world.add_child(node)
	return node

func spawn_railgun_beam(beam_team, position, speed, rotation):
	var node = railgun_beam.instantiate()
	node.team = beam_team
	node.position = position
	node.speed = speed
	node.rotation = rotation
	world.add_child(node)
	return node
