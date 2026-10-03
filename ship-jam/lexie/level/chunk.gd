extends Node2D

var current_world_position : Vector2
var current_chunk_offset : Vector2i

func initialize_at(world_position : Vector2, chunk_offset : Vector2i):
	$Label.text = str(chunk_offset)
	current_chunk_offset = chunk_offset
	current_world_position = world_position


func move_to(world_position : Vector2, chunk_offset : Vector2i):
	$RigidBody2D.teleport_by(world_position - current_world_position)
	current_chunk_offset = chunk_offset
	current_world_position = world_position
