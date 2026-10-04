extends Node2D

var current_world_position : Vector2
var current_chunk_offset : Vector2i

func initialize_at(world_position : Vector2, chunk_offset : Vector2i):
	#$Label.text = str(chunk_offset)
	current_chunk_offset = chunk_offset
	current_world_position = world_position


func move_to(world_position : Vector2, chunk_offset : Vector2i):
	for node in get_children():
		if node is PlayerShip:
			pass
		if node is RigidBody2D:
			current_chunk_offset = chunk_offset
			current_world_position = world_position
